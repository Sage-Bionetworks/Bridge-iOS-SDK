//
//  SBBUploadManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
//
//	Copyright (c) 2014-2016 Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBUploadManagerInternal.h"
#import "NSData+SBBAdditions.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBNetworkManagerInternal.h"
#import "SBBObjectManager.h"
#import "SBBUploadSession.h"
#import "SBBUploadRequest.h"
#import "NSError+SBBAdditions.h"
#import "SBBErrors.h"
#import "BridgeSDK+Internal.h"
#import "NSDate+SBBAdditions.h"
#import "NSString+SBBAdditions.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define UPLOAD_API V3_API_PREFIX @"/uploads"
#define UPLOAD_STATUS_API V3_API_PREFIX @"/uploadstatuses"

static NSString * const uuidPrefixRegexPattern =  @"^" UUID_REGEX_PATTERN @"_";

NSString * const kSBBUploadAPI =                 UPLOAD_API;
NSString * const kSBBUploadCompleteAPIFormat =   UPLOAD_API @"/%@/complete";
NSString * const kSBBUploadStatusAPIFormat =     UPLOAD_STATUS_API @"/%@";

NSString * const keysUpdatedKey = @"SBBUploadManagerKeysUpdatedKey2";
NSString * const kUploadFilesKey = @"SBBUploadFilesKey";
NSString * const kUploadRequestsKey = @"SBBUploadRequestsKey";
NSString * const kUploadSessionsKey = @"SBBUploadSessionsKey";
NSString * const kSBBUploadRetryAfterDelayKey = @"SBBUploadRetryAfterDelayKey";

NSTimeInterval kSBBDelayForRetries = 5. * 60.; // at least 5 minutes, actually whenever we get to it after that

#pragma mark - SBBUploadCompletionWrapper

@interface SBBUploadCompletionWrapper : NSObject

@property (nonatomic, copy) SBBUploadManagerCompletionBlock completion;

- (instancetype)initWithBlock:(SBBUploadManagerCompletionBlock)block;

@end

@implementation SBBUploadCompletionWrapper

- (instancetype)initWithBlock:(SBBUploadManagerCompletionBlock)block
{
    if (self = [super init]) {
        self.completion = block;
    }
    
    return self;
}

@end

#pragma mark - SBBUploadManager

@implementation SBBUploadManager
@synthesize uploadDelegate = _uploadDelegate;

+ (instancetype)defaultComponent
{
    static SBBUploadManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
        shared.networkManager.backgroundTransferDelegate = shared;
        [shared migrateKeysIfNeeded];
        
        // check if any uploads that got 503 status codes from S3 or Bridge errors are due for a retry
        // whenever the app comes to the foreground
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [shared checkAndRetryOrphanedUploads];
            [shared retryUploadsAfterDelay];
        }];
        
        // also check right away
        [shared retryUploadsAfterDelay];
    });
    
    return shared;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.uploadCompletionHandlers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (SBBObjectManager *)cleanObjectManager
{
    static SBBObjectManager *om = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        om = [SBBObjectManager objectManager];
    });
    
    return om;
}

- (SBBObjectManager *)cleanObjectManager
{
    return self.class.cleanObjectManager;
}

- (void)migrateKeysIfNeeded
{
    // In olden times we used full file paths as keys. Then we discovered the UUID of the app sandbox (which is part
    // of the full file paths) can change between runs. Possibly only when a new version is installed, but still. Yikes.
    // So we need to check if that's been updated and fix if not--on the background delegate queue, to serialize access.
    [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{

        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        BOOL keysUpgraded = [defaults boolForKey:keysUpdatedKey];
        
        if (!keysUpgraded) {
            // upgrade the files for temp files list keys
            NSDictionary *filesForTempFiles = [defaults dictionaryForKey:kUploadFilesKey];
            NSMutableDictionary *upgradedFilesForTempFiles = [NSMutableDictionary dictionary];
            for (NSString *oldKey in filesForTempFiles.allKeys) {
                NSString *oldKeyNormalized = [[NSURL fileURLWithPath:oldKey] URLByResolvingSymlinksInPath].path;
                NSString *newKey = [oldKeyNormalized sandboxRelativePath];
                
                // normalize the file it points at as well, since we're now storing the sandbox-relative part of that, too
                NSString *oldFile = filesForTempFiles[oldKey];
                oldFile = [[NSURL fileURLWithPath:oldFile] URLByResolvingSymlinksInPath].path;
                upgradedFilesForTempFiles[newKey] = [oldFile sandboxRelativePath];
            }
            [defaults setObject:upgradedFilesForTempFiles forKey:kUploadFilesKey];

            // upgrade the upload request keys
            NSDictionary *uploadRequests = [defaults dictionaryForKey:kUploadRequestsKey];
            NSMutableDictionary *upgradedUploadRequests = [NSMutableDictionary dictionary];
            for (NSString *oldKey in uploadRequests.allKeys) {
                NSString *oldKeyNormalized = [[NSURL fileURLWithPath:oldKey] URLByResolvingSymlinksInPath].path;
                NSString *newKey = [oldKeyNormalized sandboxRelativePath];
                upgradedUploadRequests[newKey] = uploadRequests[oldKey];
            }
            [defaults setObject:upgradedUploadRequests forKey:kUploadRequestsKey];
            
            // upgrade the upload session keys
            NSDictionary *uploadSessions = [defaults dictionaryForKey:kUploadSessionsKey];
            NSMutableDictionary *upgradedUploadSessions = [NSMutableDictionary dictionary];
            for (NSString *oldKey in uploadSessions.allKeys) {
                NSString *oldKeyNormalized = [[NSURL fileURLWithPath:oldKey] URLByResolvingSymlinksInPath].path;
                NSString *newKey = [oldKeyNormalized sandboxRelativePath];
                upgradedUploadSessions[newKey] = uploadSessions[oldKey];
            }
            [defaults setObject:upgradedUploadSessions forKey:kUploadSessionsKey];
            
            // upgrade the retry-after-delay keys
            NSDictionary *retryUploads = [defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey];
            NSMutableDictionary *upgradedRetryUploads = [NSMutableDictionary dictionary];
            for (NSString *oldKey in retryUploads.allKeys) {
                NSString *oldKeyNormalized = [[NSURL fileURLWithPath:oldKey] URLByResolvingSymlinksInPath].path;
                NSString *newKey = [oldKeyNormalized sandboxRelativePath];
                upgradedRetryUploads[newKey] = retryUploads[oldKey];
            }
            [defaults setObject:upgradedRetryUploads forKey:kSBBUploadRetryAfterDelayKey];
            
            // mark the keys as updated and synchronize defaults
            [defaults setBool:YES forKey:keysUpdatedKey];
            [defaults synchronize];
        }
    }];
}

- (NSURL *)tempUploadDirURL
{
    static NSURL *uploadDirURL = nil;
    if (!uploadDirURL) {
        NSURL *baseDirURL;
        NSString *appGroupIdentifier = SBBBridgeInfo.shared.appGroupIdentifier;
        if (appGroupIdentifier.length > 0) {
            baseDirURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupIdentifier];
        } else {
            NSURL *appSupportDir = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
            NSString *bundleName = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
            // for unit tests, the main bundle infoDictionary is empty, so...
            baseDirURL = [[appSupportDir URLByAppendingPathComponent:bundleName ?: @"__test__"] URLByAppendingPathComponent:@"SBBUploadManager"];
        }
        uploadDirURL = [baseDirURL URLByAppendingPathComponent:@"SBBUploadManager"];
        NSError *error;
        
        if (![[NSFileManager defaultManager] createDirectoryAtURL:uploadDirURL withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error attempting to create uploadDir at path %@:\n%@", uploadDirURL.absoluteURL, error);
            uploadDirURL = nil;
        }
    }
    
    return uploadDirURL;
}

- (NSURL *)tempFileForFileURL:(NSURL *)fileURL
{
    // normalize the file url--i.e. /private/var-->/var (see docs for URLByResolvingSymlinksInPath, which removes /private as a special case
    // even though /var is actually a symlink to /private/var in this case)
    fileURL = [fileURL URLByResolvingSymlinksInPath];
    
    // don't stack UUIDs in front of the base filename--replace any number of them with one new one; one UUID is enough to guarantee uniqueness
    NSString *baseFileName = [fileURL lastPathComponent];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:uuidPrefixRegexPattern options:0 error:nil];
    NSTextCheckingResult *match;
    while ((match = [regex firstMatchInString:baseFileName options:0 range:NSMakeRange(0, baseFileName.length)])) {
        baseFileName = [baseFileName substringFromIndex:match.range.length];
    }
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSUUID UUID] UUIDString], baseFileName];
    NSURL *tempFileURL = [[self tempUploadDirURL] URLByAppendingPathComponent:fileName];
    __block NSError *error;
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *fileCoordinatorError = nil;
    [fileCoordinator coordinateReadingItemAtURL:fileURL options:0 writingItemAtURL:tempFileURL options:0 error:&fileCoordinatorError byAccessor:^(NSURL * _Nonnull newReadingURL, NSURL * _Nonnull newWritingURL) {
        [fileMan copyItemAtURL:newReadingURL toURL:newWritingURL error:&error];
    }];
    
    NSString *errorMessage;
    if (fileCoordinatorError) {
        errorMessage = [NSString stringWithFormat:@"File coordinator error copying file %@ to temp file %@:\n%@", [[fileURL path] sandboxRelativePath], [[tempFileURL path] sandboxRelativePath], fileCoordinatorError];
    } else if (error) {
        errorMessage = [NSString stringWithFormat:@"Error copying file %@ to temp file %@:\n%@", [[fileURL path] sandboxRelativePath], [[tempFileURL path] sandboxRelativePath], error];
    }
    if (errorMessage.length > 0) {
        NSLog(@"%@", errorMessage);
        tempFileURL = nil;
    }
    
    if (tempFileURL) {
        // give the copy a fresh modification date for retry accounting purposes
        [fileCoordinator coordinateWritingItemAtURL:tempFileURL options:0 error:nil byAccessor:^(NSURL * _Nonnull newURL) {
            [fileMan setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:tempFileURL.path error:nil];
        }];
        
        // keep track of what file it's a copy of
        [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
            NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
            NSMutableDictionary *filesForTempFiles = [[defaults dictionaryForKey:kUploadFilesKey] mutableCopy];
            if (!filesForTempFiles) {
                filesForTempFiles = [NSMutableDictionary dictionary];
            }
            [filesForTempFiles setObject:[[fileURL path] sandboxRelativePath] forKey:[[tempFileURL path] sandboxRelativePath]];
            [defaults setObject:filesForTempFiles forKey:kUploadFilesKey];
            [defaults synchronize];
        }];
    }
    
    return tempFileURL;
}

- (NSString *)fileForTempFile:(NSString *)tempFilePath
{
    NSString *file = nil;
    if (tempFilePath.length) {
        file = [[BridgeSDK sharedUserDefaults] dictionaryForKey:kUploadFilesKey][[tempFilePath sandboxRelativePath]];
    }
    
    return file;
}

- (void)removeFileForTempFile:(NSString *)tempFilePath
{
    NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
    NSMutableDictionary *files = [[defaults dictionaryForKey:kUploadFilesKey] mutableCopy];
    [files removeObjectForKey:[tempFilePath sandboxRelativePath]];
    [defaults setObject:files forKey:kUploadFilesKey];
    [defaults synchronize];
}

- (void)removeTempFilesWithOriginalFile:(NSString *)filePath exceptFile:(NSString *)saveFilePath
{
    NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
    NSMutableDictionary *files = [[defaults dictionaryForKey:kUploadFilesKey] mutableCopy];
    for (NSString *tempFilePath in files.allKeys) {
        NSString *key = [tempFilePath sandboxRelativePath];
        NSString *thisFile = files[key];
        if ([thisFile isEquivalentToPath:filePath]) {
            [files removeObjectForKey:key];
            
            if (![tempFilePath isEquivalentToPath:saveFilePath]) {
                // also delete any other temp files which were copies of the same original file
                [self deleteTempFile:tempFilePath];
            }
        }
    }
    [defaults setObject:files forKey:kUploadFilesKey];
    [defaults synchronize];
}

// use the fully qualified path
- (void)deleteTempFile:(NSString *)tempFilePath
{
    NSURL *tempFile = [NSURL fileURLWithPath:[tempFilePath fullyQualifiedPath]];
    if  (!tempFile) {
        NSLog(@"Could not create NSURL for temp file %@", tempFilePath);
    }
    __block NSError *error;
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *fileCoordinatorError = nil;
    [fileCoordinator coordinateWritingItemAtURL:tempFile options:NSFileCoordinatorWritingForDeleting error:&fileCoordinatorError byAccessor:^(NSURL * _Nonnull newURL) {
        if (![[NSFileManager defaultManager] removeItemAtURL:tempFile error:&error]) {
            NSLog(@"Failed to remove temp file %@, error:\n%@", tempFile.path, error);
        }
    }];
    if (fileCoordinatorError != nil) {
        NSLog(@"Failed to coordinate removal of temp file %@, error:\n%@", tempFile.path, error);
    }
}

// use the fully qualified path
- (void)cleanUpTempFile:(NSString *)tempFilePath
{
    if (tempFilePath.length) {
        // remove it from the upload files map
        [self removeFileForTempFile:tempFilePath];
        
        // delete the temp file
        [self deleteTempFile:tempFilePath];
    }
}

- (SBBUploadManagerCompletionBlock)completionBlockForFile:(NSString *)file
{
    SBBUploadCompletionWrapper *wrapper = [_uploadCompletionHandlers objectForKey:file];
    return wrapper.completion;
}

- (void)setCompletionBlock:(SBBUploadManagerCompletionBlock)completion forFile:(NSString *)file
{
    if (!completion) {
        [self removeCompletionBlockForFile:file];
        return;
    }
    SBBUploadCompletionWrapper *wrapper = [[SBBUploadCompletionWrapper alloc] initWithBlock:completion];
    [_uploadCompletionHandlers setObject:wrapper forKey:file];
}

- (void)removeCompletionBlockForFile:(NSString *)file
{
    [_uploadCompletionHandlers removeObjectForKey:file];
}

- (void)setUploadRequestJSON:(id)json forFile:(NSString *)fileURLString
{
    NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
    
    NSMutableDictionary *uploadRequests = [[defaults dictionaryForKey:kUploadRequestsKey] mutableCopy];
    if (!uploadRequests) {
        uploadRequests = [NSMutableDictionary dictionary];
    }
    if (json) {
        [uploadRequests setObject:json forKey:[fileURLString sandboxRelativePath]];
    } else {
        [uploadRequests removeObjectForKey:[fileURLString sandboxRelativePath]];
    }
    [defaults setObject:uploadRequests forKey:kUploadRequestsKey];
    [defaults synchronize];
}

- (NSDictionary *)uploadRequestJSONForFile:(NSString *)fileURLString
{
    return [[BridgeSDK sharedUserDefaults] dictionaryForKey:kUploadRequestsKey][[fileURLString sandboxRelativePath]];
}

- (SBBUploadRequest *)uploadRequestForFile:(NSString *)fileURLString
{
    SBBUploadRequest *uploadRequest = nil;
    id json = [self uploadRequestJSONForFile:fileURLString];
    if (json) {
        uploadRequest = [self.cleanObjectManager objectFromBridgeJSON:json];
    }
    
    return uploadRequest;
}

- (void)setUploadSessionJSON:(id)json forFile:(NSString *)fileURLString
{
    NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
    
    NSMutableDictionary *uploadSessions = [[defaults dictionaryForKey:kUploadSessionsKey] mutableCopy];
    if (!uploadSessions) {
        uploadSessions = [NSMutableDictionary dictionary];
    }
    if (json) {
        [uploadSessions setObject:json forKey:[fileURLString sandboxRelativePath]];
    } else {
        [uploadSessions removeObjectForKey:[fileURLString sandboxRelativePath]];
    }
    [defaults setObject:uploadSessions forKey:kUploadSessionsKey];
    [defaults synchronize];
}

- (SBBUploadSession *)uploadSessionForFile:(NSString *)fileURLString
{
    SBBUploadSession *uploadSession = nil;
    id json = [[BridgeSDK sharedUserDefaults] dictionaryForKey:kUploadSessionsKey][[fileURLString sandboxRelativePath]];
    if (json) {
        uploadSession = [self.cleanObjectManager objectFromBridgeJSON:json];
    }
    
    return uploadSession;
}

- (NSDate *)retryTimeForFile:(NSString *)fileURLString
{
    NSDate *retryTime = nil;
    NSString *jsonDate = [[BridgeSDK sharedUserDefaults] dictionaryForKey:kSBBUploadRetryAfterDelayKey][[fileURLString sandboxRelativePath]];
    if (jsonDate) {
        retryTime = [NSDate dateWithISO8601String:jsonDate];
    }
    
    return retryTime;
}

- (void)setRetryAfterDelayForFile:(NSString *)fileURLString
{
    NSTimeInterval delay = kSBBDelayForRetries;
#if DEBUG
    NSLog(@"Will retry upload of file %@ after %lf seconds.", fileURLString, delay);
#endif
    NSDate *retryTime = [NSDate dateWithTimeIntervalSinceNow:delay];
    
    [self setRetryTime:retryTime forFile:fileURLString];
}

- (void)setRetryTime:(NSDate *)retryTime forFile:(NSString *)fileURLString {
    NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
    
    NSMutableDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
    if (!retryUploads) {
        retryUploads = [NSMutableDictionary dictionary];
    }
    if (retryTime) {
        retryUploads[[fileURLString sandboxRelativePath]] = [retryTime ISO8601String];
    } else {
        [retryUploads removeObjectForKey:[fileURLString sandboxRelativePath]];
    }
    [defaults setObject:retryUploads forKey:kSBBUploadRetryAfterDelayKey];
    [defaults synchronize];
}

- (void)retryUploadsAfterDelay
{
    [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        
        NSMutableDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
        for (NSString *fileURLString in retryUploads.allKeys) {
            NSString *filePath = [fileURLString fullyQualifiedPath];
            NSDate *retryTime = [self retryTimeForFile:filePath];
            if ([retryTime timeIntervalSinceNow] <= 0.) {
                [self setRetryTime:nil forFile:filePath];
                NSDictionary *uploadRequestJSON = [self uploadRequestJSONForFile:filePath];
                SBBUploadManagerCompletionBlock completion = [self completionBlockForFile:filePath];
                
                if (completion && uploadRequestJSON.allKeys.count) {
                    [self kickOffUploadForFile:filePath uploadRequestJSON:uploadRequestJSON];
                } else {
                    [self retryOrphanedUploadFromScratch:filePath];
                }
            }
        }
    }];
}

// When uploading a file to Bridge, first we use background download to get an SBBUploadSession object from Bridge.
// Then we use the pre-signed URL in that SBBUploadSession to upload our file to S3.
// When that finishes, we tell Bridge that the requested upload is completed.
// To avoid having multiple layers of nested completion handlers in one method, they're broken out by step:

// --- Here's the completion handler for the step where we tell Bridge the upload completed:
- (void)toldBridgeFileUploadedWithTask:(NSURLSessionUploadTask *)uploadTask forBridgeSession:(SBBUploadSession *)uploadSession error:(NSError *)error
{
#if DEBUG
    if (error) {
        NSLog(@"Error calling upload complete for upload ID %@:\n%@", uploadSession.id, error);
    } else {
        NSString* uploadStatusUrlString = nil;
        if ([self.networkManager isKindOfClass:[SBBNetworkManager class]]) {
            NSString* relativeUrl = [NSString stringWithFormat:kSBBUploadStatusAPIFormat, uploadSession.id];
            NSURL* url = [(SBBNetworkManager*) self.networkManager URLForRelativeorAbsoluteURLString:relativeUrl];
            uploadStatusUrlString = [url absoluteString];
            if ([_uploadDelegate respondsToSelector:@selector(uploadManager:uploadOfFile:completedWithVerificationURL:)]) {
                [_uploadDelegate uploadManager:self uploadOfFile:uploadTask.taskDescription completedWithVerificationURL:url];
            }
        }
        NSLog(@"Successfully called upload complete for upload ID %@, check status with curl -H \"Bridge-Session:%@\" %@", uploadSession.id, [self.authManager.authDelegate sessionTokenForAuthManager:self.authManager], uploadStatusUrlString);
    }
#endif
    [self completeUploadOfFile:uploadTask.taskDescription withError:error];
}

- (void)handleUploadHTTPStatusCode:(NSInteger)httpStatusCode forUploadFilePath:(NSString *)filePath
{
    switch (httpStatusCode) {
        case 403:
        case 409:
        case 500:
        case 503: {
            // 403 for our purposes means the pre-signed url timed out before starting the actual upload to S3.
            // 409 in our case it could only mean a temporary conflict (resource locked by another process, etc.) that should be retried.
            // 500 means internal server error ("We encountered an internal error. Please try again.")
            // 503 means service not available or the requests are coming too fast, so try again later.
            // In any case, we'll retry after a minimum delay to avoid spamming retries.
#if DEBUG
            NSLog(@"Background file upload to S3 failed with HTTP status %ld; retrying after delay", (long)httpStatusCode);
#endif
            [self setRetryAfterDelayForFile:filePath];
        } break;
            
        default: {
            // iOS handles redirects automatically so only e.g. 304 resource not changed etc. from the 300 range should end up here
            // (along with all unhandled 4xx and 5xx of course).
            NSString *description = [NSString stringWithFormat:@"Background file upload to S3 failed with HTTP status %ld", (long)httpStatusCode];
            NSError *s3Error = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeS3UploadErrorResponse userInfo:@{NSLocalizedDescriptionKey: description}];
            [self completeUploadOfFile:filePath withError:s3Error];
        } break;
    }
}

// --- Here's the completion handler for the step where we upload the file to S3:
- (void)uploadedFileToS3WithTask:(NSURLSessionUploadTask *)uploadTask response:(NSHTTPURLResponse *)httpResponse error:(NSError *)error
{
    NSInteger httpStatusCode = httpResponse.statusCode;
    NSString *filePath = uploadTask.taskDescription;
    
    // client-side networking issue
    if (error) {
        [self completeUploadOfFile:filePath withError:error];
        return;
    }
    
    // server didn't like the request, or otherwise hiccupped
    if (httpStatusCode >= 300) {
        [self handleUploadHTTPStatusCode:httpStatusCode forUploadFilePath:filePath];
        
        // early exit
        return;
    }
    
    // tell the API we done did it
    SBBUploadSession *uploadSession = [self uploadSessionForFile:filePath];
    [self setUploadSessionJSON:nil forFile:filePath];
    NSString *uploadId = uploadSession.id;
    if (!uploadId.length) {
        NSAssert(uploadId, @"uploadId is nil");
    }
    NSString *ref = [NSString stringWithFormat:kSBBUploadCompleteAPIFormat, uploadId];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    [self.networkManager post:ref headers:headers parameters:nil background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        [self toldBridgeFileUploadedWithTask:uploadTask forBridgeSession:uploadSession error:error];
    }];
}

// --- And here's the completion handler for getting the SBBUploadSession in the first place:
- (void)downloadedBridgeUploadSessionWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask fileURL:(NSURL *)file
{
    NSError *error;
    NSString *uploadFileURL = downloadTask.taskDescription;
    if ([self uploadSessionForFile:uploadFileURL]) {
        // already got one--this means we retried requesting the upload session for the file because the initial
        // Bridge request took too long to respond, but has now responded; but we only need one of these to
        // go on to attempt the upload to S3, so we'll just ignore this one
        return;
    }
    
    NSData *jsonData = [NSData dataWithContentsOfURL:file options:0 error:&error];
    if (error) {
        NSLog(@"Error reading downloaded UploadSession file into an NSData object:\n%@", error);
        [self completeUploadOfFile:uploadFileURL withError:error];
        return;
    }
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        [self completeUploadOfFile:uploadFileURL withError:error];
        NSLog(@"Error deserializing downloaded UploadSession data into objects:\n%@", error);
        return;
    }
    
    SBBUploadSession *uploadSession = [self.cleanObjectManager objectFromBridgeJSON:jsonObject];
    SBBUploadRequest *uploadRequest = [self uploadRequestForFile:uploadFileURL];
    if (!uploadRequest || !uploadRequest.contentLength || !uploadRequest.contentType || !uploadRequest.contentMd5) {
        NSLog(@"Failed to retrieve upload request headers for temp file %@", uploadFileURL);
        NSString *desc = [NSString stringWithFormat:@"Error retrieving upload request headers for temp file URL:\n%@", uploadFileURL];
        error = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeTempFileError userInfo:@{NSLocalizedDescriptionKey: desc}];
        [self completeUploadOfFile:uploadFileURL withError:error];
        return;
    }
    
    if ([uploadSession isKindOfClass:[SBBUploadSession class]]) {
#if DEBUG
        NSLog(@"Successfully obtained upload session with upload ID %@", uploadSession.id);
#endif
        [self setUploadSessionJSON:jsonObject forFile:uploadFileURL];
        NSDictionary *uploadHeaders =
        @{
          @"Content-Length": [uploadRequest.contentLength stringValue],
          @"Content-Type": uploadRequest.contentType,
          @"Content-MD5": uploadRequest.contentMd5
          };
        NSURL *fileUrl = [NSURL fileURLWithPath:uploadFileURL];
        [self.networkManager uploadFile:fileUrl httpHeaders:uploadHeaders toUrl:uploadSession.url taskDescription:uploadFileURL completion:^(NSURLSessionTask *task, NSHTTPURLResponse *response, NSError *error) {
#if DEBUG
            if (error || response.statusCode >= 300) {
                NSLog(@"Error uploading to S3 for upload ID %@\nHTTP status: %@\n%@", uploadSession.id, @(response.statusCode), error);
            } else {
                NSLog(@"Successfully uploaded to S3 for upload ID %@", uploadSession.id);
            }
#endif
            [self uploadedFileToS3WithTask:(NSURLSessionUploadTask *)task response:response error:error];
        }];
    } else {
        // the response from Bridge was an error message; we already handled this in the task completion
        // block for fetching the UploadSession
    }
}

- (void)uploadFileToBridge:(NSURL *)fileUrl completion:(SBBUploadManagerCompletionBlock)completion
{
    NSString *extension = fileUrl.pathExtension;
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        contentType = @"application/octet-stream";
    }
    
    [self uploadFileToBridge:fileUrl contentType:contentType completion:completion];
}

- (void)uploadFileToBridge:(NSURL *)fileUrl contentType:(NSString *)contentType completion:(SBBUploadManagerCompletionBlock)completion
{
    [self tempFileForUploadFileToBridge:fileUrl contentType:contentType completion:completion];
}

// internal method returns temp file URL for unit tests
- (NSURL *)tempFileForUploadFileToBridge:(NSURL *)fileUrl contentType:(NSString *)contentType completion:(SBBUploadManagerCompletionBlock)completion
{
    if (![fileUrl isFileURL] || ![[NSFileManager defaultManager] isReadableFileAtPath:[fileUrl path]]) {
        NSLog(@"Attempting to upload an URL that's not a readable file URL:\n%@", fileUrl);
        if (completion) {
            completion([NSError generateSBBNotAFileURLErrorForURL:fileUrl]);
        }
        if (_uploadDelegate) {
            [_uploadDelegate uploadManager:self uploadOfFile:[fileUrl absoluteString] completedWithError:[NSError generateSBBNotAFileURLErrorForURL:fileUrl]];
        }
        return nil;
    }
    
    // If we already "know" about this upload, don't add it again; if it's hung up somehow, the orphaned file checking will catch it.
    // If we don't have a completion handler for it, though, set it up with the given one before returning.
    // Compare just the sandbox-relative parts, as the app sandbox path may have changed. But completion handlers, being in-memory-only,
    // are indexed by the full path.
    NSArray *uploadTempFiles = [[BridgeSDK sharedUserDefaults] dictionaryForKey:kUploadFilesKey].allKeys;
    NSString *sandboxRelativePath = [fileUrl.path sandboxRelativePath];
    for (NSString *uploadTempFile in uploadTempFiles) {
        NSString *uploadFile = [self fileForTempFile:uploadTempFile];
        if ([uploadFile isEqualToString:sandboxRelativePath]) {
            [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
                [self setCompletionBlock:completion forFile:[uploadTempFile fullyQualifiedPath]];
            }];
            return nil;
        }
    }
    
    // make a temp copy with a unique name
    NSURL *tempFileURL = [self tempFileForFileURL:fileUrl];
    if (!tempFileURL) {
        if (completion) {
            completion([NSError generateSBBTempFileErrorForURL:fileUrl]);
        }
        return nil;
    }
    [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
        [self setCompletionBlock:completion forFile:[tempFileURL path]];
    }];
    
    // default to generic binary file if type not specified
    if (!contentType) {
        contentType = @"application/octet-stream";
    }
    
    NSString *name = [fileUrl lastPathComponent];
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *fileCoordinatorError = nil;
    __block NSData *fileData = nil;
    
    [fileCoordinator coordinateReadingItemAtURL:tempFileURL options:0 error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
        fileData = [NSData dataWithContentsOfURL:newURL];
    }];
    
    if (!fileData) {
        if (completion) {
            NSError *error = fileCoordinatorError ?: [NSError generateSBBTempFileReadErrorForURL:fileUrl];
            completion(error);
        }
        return nil;
    }
    
    SBBUploadRequest *uploadRequest = [SBBUploadRequest new];
    uploadRequest.name = name;
    uploadRequest.contentLengthValue = fileData.length;
    uploadRequest.contentType = contentType;
    uploadRequest.contentMd5 = [fileData contentMD5];
    NSString *filePath = [tempFileURL path];
    // don't use the shared SBBObjectManager--we want to use only SDK default objects for types
    NSDictionary *uploadRequestJSON = [self.cleanObjectManager bridgeJSONFromObject:uploadRequest];
    
    [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
        [self kickOffUploadForFile:filePath uploadRequestJSON:uploadRequestJSON];
    }];
    
    return tempFileURL;
}

// This presumes uploadFileToBridge:contentType:completion: was called to set things up for this file,
// so can be used for both the initial upload attempt and any retries due to 403 (presigned url timed out).
// It also presumes it's being called from within the background NSURLSession's delegate queue.
- (void)kickOffUploadForFile:(NSString *)filePath uploadRequestJSON:(NSDictionary *)uploadRequestJSON
{
    // this starts the process by downloading the Bridge UploadSession.
    // first, make sure we get rid of any existing UploadSession for this file, in case this is a retry.
    [self setUploadSessionJSON:nil forFile:filePath];
    [self setUploadRequestJSON:uploadRequestJSON forFile:filePath];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    __block NSURLSessionDownloadTask *downloadTask = [self.networkManager downloadFileFromURLString:kSBBUploadAPI method:@"POST" httpHeaders:headers parameters:uploadRequestJSON taskDescription:filePath downloadCompletion:^(NSURL *file) {
        [self downloadedBridgeUploadSessionWithDownloadTask:downloadTask fileURL:file];
    } taskCompletion:^(NSURLSessionTask *task, NSHTTPURLResponse *response, NSError *error) {
        // We don't care about this unless there was a network or HTTP error.
        // Otherwise we'll have gotten and handled the downloaded file url in the downloadCompletion block, above.
        if (error) {
            if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                NSInteger statusCode = httpResponse.statusCode;
                if (statusCode < 300) {
                    // these are not the codes you're looking for--move along
                    return;
                }
                error = [NSError generateSBBErrorForStatusCode:statusCode];
                if (error.code == SBBErrorCodeUnsupportedAppVersion) {
                    // 410 app version not supported--set it for delayed retry so it will go through after they upgrade the app
                    [self setRetryAfterDelayForFile:filePath];
                } else if (error.code == SBBErrorCodeServerPreconditionNotMet) {
                    // 412 not consented--don't retry; we shouldn't be uploading data in the first place
                    [self completeUploadOfFile:task.taskDescription withError:error];
                } else if (statusCode >= 500) {
                    // server issue--retry after a bit to give it a chance to clear up
#if DEBUG
                    NSLog(@"Request to Bridge for UploadSession failed with HTTP status %@. Will retry after delay.", @(statusCode));
#endif
                    [self setRetryAfterDelayForFile:filePath];
                } else {
                    // other 4xx--not client-recoverable, so just fail gracefully-ish
                    [self completeUploadOfFile:task.taskDescription withError:error];
                }
            } else {
                // network error--we'll only get here if the error didn't include resume data
    #if DEBUG
                NSLog(@"Request to Bridge for UploadSession failed due to network error. Will retry after delay.");
    #endif
                [self setRetryAfterDelayForFile:filePath];
            }
        }
    }];
}

// expects a fully-qualified path
- (void)retryOrphanedUploadFromScratch:(NSString *)filePath
{
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if ([fileMan fileExistsAtPath:filePath]) {
        // on the off chance the original completion block is still around...
        SBBUploadManagerCompletionBlock completion = [self completionBlockForFile:filePath];
        
        // if there's no old completion handler, get the old "original" file and delete it; the temp file is our new original
        // also create a new completion handler to delete this file upon successful upload
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        if (!completion) {
            NSString *originalFile = [[self fileForTempFile:filePath] fullyQualifiedPath];
            if (originalFile.length) {
                [fileCoordinator coordinateWritingItemAtURL:[NSURL fileURLWithPath:originalFile] options:NSFileCoordinatorWritingForDeleting error:nil byAccessor:^(NSURL * _Nonnull newURL) {
                    if  ([fileMan fileExistsAtPath:newURL.path]) {
                        [fileMan removeItemAtURL:newURL error:nil];
                    }
                }];
            }
            
            // now remove any and all other temp files which are copies of this same original
            // (both the temp files themselves, and their map entries)
            [self removeTempFilesWithOriginalFile:filePath exceptFile:filePath];
        }
        
        // remove it from the upload files map so we don't leave it hanging around
        [self removeFileForTempFile:filePath];
        
        // remove any existing uploads that map to this file, because we're going to check for that in
        // the upload method to prevent duplicating uploads-in-progress when BridgeAppSDK calls us to re-try
        // orphaned /tmp files
        [self removeTempFilesWithOriginalFile:filePath exceptFile:filePath];
        
        // let the SDK figure out the contentType
        [self uploadFileToBridge:[NSURL fileURLWithPath:filePath] completion:^(NSError *error) {
            if (!error) {
                // now that it's been uploaded, delete it
                NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
                if  (!fileUrl) {
                    NSLog(@"Could not create NSURL for file %@", filePath);
                }
                [fileCoordinator coordinateWritingItemAtURL:fileUrl options:NSFileCoordinatorWritingForDeleting error:nil byAccessor:^(NSURL * _Nonnull newURL) {
                    NSError *error;
                    if (![fileMan removeItemAtURL:newURL error:&error]) {
                        NSLog(@"Failed to remove file %@, error:\n%@", fileUrl, error);
                    }
                }];
            }
            
            if (completion) {
                completion(error);
            }
        }];
    } else {
        // ¯\_(ツ)_/¯
        NSLog(@"File %@ no longer exists, removing from upload files", filePath);
        [self cleanUpTempFile:filePath];
    }
}

- (NSArray<NSURL *> *)filesUnderDirectory:(NSURL *)baseDir
{
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator =
    [fileMan enumeratorAtURL:baseDir
  includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                     options:NSDirectoryEnumerationSkipsHiddenFiles
                errorHandler:nil];
    
    NSMutableArray<NSURL *> *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in directoryEnumerator) {
        NSNumber *isDirectory = nil;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        if (![isDirectory boolValue]) {
            // normalize the url and add to the list
            [mutableFileURLs addObject:[fileURL URLByResolvingSymlinksInPath]];
        }
    }
    
    return [mutableFileURLs copy];
}

- (NSArray<__kindof NSURLSessionTask *> * _Nullable)cancelTasksForFile:(NSString *)file inTasks:(NSArray<__kindof NSURLSessionTask *> * _Nullable)tasks
{
    NSMutableArray<__kindof NSURLSessionTask *> *tasksForFile = [NSMutableArray array];
    
    // first check if our file is the same as the task file
    for (NSURLSessionTask *task in tasks) {
        NSString *taskFile = task.taskDescription;
        if ([file isEquivalentToPath:taskFile]) {
            [tasksForFile addObject:task];
        } else {
            // now check if our file is a temp copy of the task file
            NSString *fileForTempFile = [self fileForTempFile:file];
            if ([fileForTempFile isEquivalentToPath:taskFile]) {
                [tasksForFile addObject:task];
            } else {
                // now check if the task file is a temp copy of our file
                NSString *fileForTaskTempFile = [self fileForTempFile:taskFile];
                if ([fileForTaskTempFile isEquivalentToPath:file]) {
                    [tasksForFile addObject:task];
                } else if ([fileForTaskTempFile isEquivalentToPath:fileForTempFile]) {
                    // if the task file and our file are both temp copies of the same file
                    [tasksForFile addObject:task];
                }
            }
        }
    }
    
    NSMutableArray *newTasks = [tasks mutableCopy];
    for (NSURLSessionTask *task in tasksForFile) {
        [newTasks removeObject:task];
        [task cancel];
        
        NSString *taskFile = task.description;
        if (![taskFile isEquivalentToPath:file]) {
            // make sure to remove its reference from our known uploads in progress, since
            // it's no longer an upload in progress
            [self removeFileForTempFile:task.description];
        }
    }
    
    return [newTasks copy];
}

- (void)checkAndRetryOrphanedUploads
{
    NSURLSession *bgSession = ((SBBNetworkManager *)self.networkManager).backgroundSession;
    void (^block)(NSArray<__kindof NSURLSessionTask *> * _Nullable tasks) = ^(NSArray<__kindof NSURLSessionTask *> *tasks){
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        NSFileManager *fileMan = [NSFileManager defaultManager];
        NSMutableSet *filesRetrying = [NSMutableSet set];
        
        // assume any outstanding upload requests without corresponding upload sessions whose files are
        // more than a day old are orphaned (note that under some unusual circumstances this may lead
        // to duplication of uploads).
        static const NSTimeInterval oneDay = 24. * 60. * 60.;
        NSArray *uploadFiles = [defaults dictionaryForKey:kUploadFilesKey].allKeys;
        NSDictionary *uploadRequests = [defaults dictionaryForKey:kUploadRequestsKey];
        NSDictionary *uploadSessions = [defaults dictionaryForKey:kUploadSessionsKey];
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        for (NSString *relativePath in uploadRequests.allKeys) {
            NSString *filePath = [relativePath fullyQualifiedPath];
            if ([filesRetrying containsObject:filePath]) {
                continue; // skip it, we're already retrying this one
            }
            if (!uploadSessions[relativePath]) {
                // get the modification date of the file, if it still exists
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                __block NSDictionary *fileAttrs;
                [fileCoordinator coordinateReadingItemAtURL:fileURL options:NSFileCoordinatorReadingImmediatelyAvailableMetadataOnly error:nil byAccessor:^(NSURL * _Nonnull newURL) {
                    fileAttrs = [fileMan attributesOfItemAtPath:filePath error:nil];
                }];
                
                if (fileAttrs) {
                    NSDate *modified = [fileAttrs fileModificationDate];
                    if ([modified timeIntervalSinceNow] < -oneDay) {
                        // it's more than a day old, so we will retry now
                        // but first, if it's in the retry queue, take it out
                        [self setRetryTime:nil forFile:filePath];
                        
                        // ...and update its modification date so we don't keep thinking it's due for a retry
                        [fileCoordinator coordinateWritingItemAtURL:fileURL options:NSFileCoordinatorWritingContentIndependentMetadataOnly error:nil byAccessor:^(NSURL * _Nonnull newURL) {
                            [fileMan setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:nil];
                        }];
                        
                        // ...and cancel any existing tasks trying to upload the same file
                        tasks = [self cancelTasksForFile:filePath inTasks:tasks];

                        // ok, now do the retry
                        NSDictionary *uploadRequestJSON = [self uploadRequestJSONForFile:filePath];
                        [filesRetrying addObject:filePath];
                        SBBUploadManagerCompletionBlock completion = [self completionBlockForFile:filePath];
                        if (completion && uploadRequestJSON) {
                            // just re-try the actual upload
                            [self kickOffUploadForFile:filePath uploadRequestJSON:uploadRequestJSON];
                        } else {
                            [self retryOrphanedUploadFromScratch:filePath];
                        }
                    }
                } else {
                    // it's gone, just delete its upload request etc. so we don't keep seeing it here
                    [self setUploadRequestJSON:nil forFile:filePath];
                    [self cleanUpTempFile:filePath];
                }
            }
        }
        
        // assume any outstanding upload sessions at or past their expiration date are orphaned
        for (NSString *relativePath in uploadSessions.allKeys) {
            NSString *filePath = [relativePath fullyQualifiedPath];
            if ([filesRetrying containsObject:filePath]) {
                continue; // skip it, we're already retrying this one
            }
            SBBUploadSession *session = [self uploadSessionForFile:filePath];
            if ([session.expires timeIntervalSinceNow] <= 0.) {
                // clear out the old session info
                [self setUploadSessionJSON:nil forFile:filePath];
                
                // 'touch' the file so it doesn't look orphaned again too soon
                [fileCoordinator coordinateWritingItemAtURL:[NSURL fileURLWithPath:filePath] options:NSFileCoordinatorWritingContentIndependentMetadataOnly error:nil byAccessor:^(NSURL * _Nonnull newURL) {
                    [fileMan setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:nil];
                }];
                
                // ...and cancel any existing tasks trying to upload the same file
                tasks = [self cancelTasksForFile:filePath inTasks:tasks];
                
                // if an old upload request and completion block still exist for this file, reuse them
                NSDictionary *uploadRequestJSON = [self uploadRequestJSONForFile:filePath];
                SBBUploadManagerCompletionBlock completion = [self completionBlockForFile:filePath];
                if (completion && uploadRequestJSON) {
                    [self kickOffUploadForFile:filePath uploadRequestJSON:uploadRequestJSON];
                } else {
                    // earlier version of SDK cleaned up saved UploadRequests prematurely, so just start over
                    // from scratch if we don't have one, or if the completion block is lost due to app relaunch
                    [self retryOrphanedUploadFromScratch:filePath];
                }
                [filesRetrying addObject:filePath];
            }
        }
        
        // assume any upload files with no upload request and no upload session are orphaned
        for (NSString *relativePath in uploadFiles) {
            NSString *filePath = [relativePath fullyQualifiedPath];
            if ([filesRetrying containsObject:filePath]) {
                continue; // skip it, we're already retrying this one
            }
            if (!uploadRequests[relativePath] && !uploadSessions[relativePath]) {
                // first cancel any existing tasks trying to upload the same file
                tasks = [self cancelTasksForFile:filePath inTasks:tasks];
                [filesRetrying addObject:filePath];
                [self retryOrphanedUploadFromScratch:filePath];
            }
        }
        
        // last but not least, any files lingering in the app support directory that weren't even
        // in the uploadFiles list (because older versions didn't actually ever put files in that list)
        // and are >24 hours old are assumed to be orphaned
        // (age check because retries above will add new files to the temp upload dir, but the code to
        // add them to the upload files list won't have been able to run yet because we're blocking that queue,
        // so even re-getting the list and checking against "original" files wouldn't catch those to weed out)
        NSURL *tempDir = [self tempUploadDirURL];
        NSArray *tempContents = [self filesUnderDirectory:tempDir];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSString *filePath = ((NSURL *)evaluatedObject).path;
            BOOL ofInterest = ![uploadFiles containsObject:[filePath sandboxRelativePath]];
            if (ofInterest) {
                __block NSDictionary *fileAttrs = nil;
                [fileCoordinator coordinateReadingItemAtURL:(NSURL *)evaluatedObject options:NSFileCoordinatorReadingImmediatelyAvailableMetadataOnly error:nil byAccessor:^(NSURL * _Nonnull newURL) {
                    fileAttrs = [fileMan attributesOfItemAtPath:filePath error:nil];
                }];
                if (fileAttrs) {
                    NSDate *modified = [fileAttrs fileModificationDate];
                    if ([modified timeIntervalSinceNow] >= -oneDay) {
                        ofInterest = NO;
                    }
                }
            }

            return ofInterest;
        }];
        
        NSArray *filesOfInterest = [tempContents filteredArrayUsingPredicate:predicate];
        for (NSURL *fileURL in filesOfInterest) {
            NSString *filePath = fileURL.path;
            if ([filesRetrying containsObject:filePath]) {
                continue; // skip it, we're already retrying this one
            }
            
            // first cancel any existing tasks trying to upload the same file
            tasks = [self cancelTasksForFile:filePath inTasks:tasks];
            [filesRetrying addObject:filePath];
            [self retryOrphanedUploadFromScratch:filePath];
        }
    };
    
    if (bgSession) {
        [bgSession getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
            block(tasks);
        }];
    } else {
        [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
            block(nil);
        }];
    }
}

#pragma mark - Delegate methods

- (void)completeUploadOfFile:(NSString *)file withError:(NSError *)error
{
    SBBUploadManagerCompletionBlock completion = [self completionBlockForFile:file];
    if (completion) {
        [self removeCompletionBlockForFile:file];
    } else if (!error) {
        // if we lost the original completion handler due to an app restart for whatever reason,
        // and there was no error, we should delete the original file so it doesn't linger and cause
        // a spurious retry attempt on the next app launch (or whatever the non-BridgeAppSDK-app
        // tries to do with it thinking it got lost somewhere in the internets)
        NSString *derelictFile = [self fileForTempFile:file];
        NSURL *derelictFileURL = [NSURL fileURLWithPath:[derelictFile fullyQualifiedPath]];
        if  (!derelictFileURL) {
            NSLog(@"Could not create NSURL for derelict file %@", derelictFile);
        }
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSError *fileCoordinatorError = nil;
        [fileCoordinator coordinateWritingItemAtURL:derelictFileURL options:NSFileCoordinatorWritingForDeleting error:&fileCoordinatorError byAccessor:^(NSURL * _Nonnull newURL) {
            NSError *error;
            if (![[NSFileManager defaultManager] removeItemAtURL:derelictFileURL error:&error]) {
                NSLog(@"Failed to remove derelict file %@, error:\n%@", derelictFileURL.path, error);
            }
        }];
        if (fileCoordinatorError != nil) {
            NSLog(@"Failed to coordinate removal of derelict file %@, error:\n%@", derelictFileURL.path, error);
        }
    }
    
    if (_uploadDelegate) {
        NSString *originalFile = [self fileForTempFile:file];
        [_uploadDelegate uploadManager:self uploadOfFile:originalFile completedWithError:error];
    }
    [self cleanUpTempFile:file];
    [self setUploadRequestJSON:nil forFile:file];
    [self setUploadSessionJSON:nil forFile:file];
    
    // do it here so tests can check that cleanup happened properly from within the completion handler
    if (completion) {
        completion(error);
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"Session became invalid! Error:\n%@", error);
    
    // handle completion (failure) for all outstanding uploads
    NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
    NSDictionary *files = [defaults dictionaryForKey:kUploadFilesKey];
    for (NSString *file in files.allKeys) {
        [self completeUploadOfFile:file withError:error];
    }
    
    // clear everything out
    [_uploadCompletionHandlers removeAllObjects];
    [defaults removeObjectForKey:kUploadRequestsKey];
    [defaults removeObjectForKey:kUploadSessionsKey];
    [defaults removeObjectForKey:kUploadFilesKey];
    
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *fileCoordinatorError = nil;
    NSURL *tempUploadDir = [self tempUploadDirURL];
    [fileCoordinator coordinateWritingItemAtURL:tempUploadDir options:NSFileCoordinatorWritingForDeleting error:&fileCoordinatorError byAccessor:^(NSURL * _Nonnull newURL) {
        NSError *fileError;
        [[NSFileManager defaultManager] removeItemAtURL:tempUploadDir error:&fileError];
        if (fileError) {
            NSLog(@"Error removing temp upload file directory:\n%@", fileError);
        }
    }];
    if (fileCoordinatorError != nil) {
        NSLog(@"Error coordinating removal of temp upload file directory:\n%@", fileCoordinatorError);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // This is actually an indirect delegate, with calls passed through from SBBNetworkManager's session delegate.
    // We use the same protocol to avoid needless duplication, and this method is required by that protocol,
    // but between the original session delegate and completion handlers, there's nothing left for us to do here.
}

@end
