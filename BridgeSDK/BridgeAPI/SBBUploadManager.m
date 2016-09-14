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
#import "BridgeSDKInternal.h"
#import "NSDate+SBBAdditions.h"
#import "NSString+SBBAdditions.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define UPLOAD_API GLOBAL_API_PREFIX @"/uploads"
#define UPLOAD_STATUS_API GLOBAL_API_PREFIX @"/uploadstatuses"

static NSString * const uuidPrefixRegexPattern =  @"^" UUID_REGEX_PATTERN @"_";

NSString * const kSBBUploadAPI =                 UPLOAD_API;
NSString * const kSBBUploadCompleteAPIFormat =   UPLOAD_API @"/%@/complete";
NSString * const kSBBUploadStatusAPIFormat =     UPLOAD_STATUS_API @"/%@";

NSString * const keysUpdatedKey = @"SBBUploadManagerKeysUpdatedKey";
NSString * const kUploadFilesKey = @"SBBUploadFilesKey";
static NSString *kUploadRequestsKey = @"SBBUploadRequestsKey";
static NSString *kUploadSessionsKey = @"SBBUploadSessionsKey";
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

- (void)migrateKeysIfNeeded
{
    // In olden times we used full file paths as keys. Then we discovered the UUID of the app sandbox (which is part
    // of the full file paths) can change between runs. Possibly only when a new version is installed, but still. Yikes.
    // So we need to check if that's been updated and fix if not--on the background delegate queue, to serialize access.
    [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
            [defaults setObject:upgradedRetryUploads forKey:kUploadSessionsKey];
            
            // mark the keys as updated and synchronize defaults
            [defaults setBool:YES forKey:keysUpdatedKey];
            [defaults synchronize];
        }
    }];
}

- (NSURL *)tempUploadDirURL
{
    NSURL *appSupportDir = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *bundleName = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    // for unit tests, the main bundle infoDictionary is empty, so...
    NSURL *uploadDir = [[appSupportDir URLByAppendingPathComponent:bundleName ?: @"__test__"] URLByAppendingPathComponent:@"SBBUploadManager"];
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:uploadDir withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Error attempting to create uploadDir at path %@:\n%@", uploadDir.absoluteURL, error);
    }
    
    return uploadDir;
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
    NSError *error;
    NSFileManager *fileMan = [NSFileManager defaultManager];
    [fileMan copyItemAtURL:fileURL toURL:tempFileURL error:&error];
    if (error) {
        NSLog(@"Error copying file %@ to temp file %@:\n%@", [[fileURL path] sandboxRelativePath], [[tempFileURL path] sandboxRelativePath], error);
        tempFileURL = nil;
    }
    
    if (tempFileURL) {
        // give the copy a fresh modification date for retry accounting purposes
        [fileMan setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:tempFileURL.path error:nil];
        
        // keep track of what file it's a copy of
        [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
        file = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadFilesKey][[tempFilePath sandboxRelativePath]];
    }
    
    return file;
}

- (void)removeFileForTempFile:(NSString *)tempFilePath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *files = [[defaults dictionaryForKey:kUploadFilesKey] mutableCopy];
    [files removeObjectForKey:[tempFilePath sandboxRelativePath]];
    [defaults setObject:files forKey:kUploadFilesKey];
    [defaults synchronize];
}

// use the fully qualified path
- (void)cleanUpTempFile:(NSString *)tempFilePath
{
    if (tempFilePath.length) {
        // remove it from the upload files map
        [self removeFileForTempFile:tempFilePath];
        
        // delete the temp file
        NSURL *tempFile = [NSURL fileURLWithPath:[tempFilePath fullyQualifiedPath]];
        if  (!tempFile) {
            NSLog(@"Could not create NSURL for temp file %@", tempFile.path);
        }
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtURL:tempFile error:&error]) {
            NSLog(@"Failed to remove temp file %@, error:\n%@", tempFile.path, error);
        }
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
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
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadRequestsKey][[fileURLString sandboxRelativePath]];
}

- (SBBUploadRequest *)uploadRequestForFile:(NSString *)fileURLString
{
    SBBUploadRequest *uploadRequest = nil;
    id json = [self uploadRequestJSONForFile:fileURLString];
    if (json) {
        uploadRequest = [_cleanObjectManager objectFromBridgeJSON:json];
    }
    
    return uploadRequest;
}

- (void)setUploadSessionJSON:(id)json forFile:(NSString *)fileURLString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
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
    id json = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadSessionsKey][[fileURLString sandboxRelativePath]];
    if (json) {
        uploadSession = [_cleanObjectManager objectFromBridgeJSON:json];
    }
    
    return uploadSession;
}

- (NSDate *)retryTimeForFile:(NSString *)fileURLString
{
    NSDate *retryTime = nil;
    NSString *jsonDate = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSBBUploadRetryAfterDelayKey][[fileURLString sandboxRelativePath]];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
        for (NSString *fileURLString in retryUploads.allKeys) {
            NSDate *retryTime = [self retryTimeForFile:fileURLString];
            if ([retryTime timeIntervalSinceNow] <= 0.) {
                [self setRetryTime:nil forFile:fileURLString];
                NSDictionary *uploadRequestJSON = [self uploadRequestJSONForFile:fileURLString];
                if (uploadRequestJSON.allKeys.count) {
                    [self kickOffUploadForFile:[fileURLString fullyQualifiedPath] uploadRequestJSON:uploadRequestJSON];
                } else {
                    // if it's missing or empty, just remove and skip it
                    [retryUploads removeObjectForKey:fileURLString];
                    [defaults setObject:retryUploads forKey:kSBBUploadRetryAfterDelayKey];
                    [defaults synchronize];
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
        case 500: {
            // 403 for our purposes means the pre-signed url timed out before starting the actual upload to S3.
            // 500 means internal server error ("We encountered an internal error. Please try again.")
            // either way we should try again immediately
#if DEBUG
            NSLog(@"Background file upload to S3 failed with HTTP status %ld; retrying...", (long)httpStatusCode);
#endif
            NSDictionary *uploadRequestJSON = [self uploadRequestJSONForFile:filePath];
            [self kickOffUploadForFile:filePath uploadRequestJSON:uploadRequestJSON];
        } break;
            
        case 503: {
            // 503 means service not available or the requests are coming too fast, so try again after
            // at least a minimum delay
            
#if DEBUG
            NSLog(@"Background file upload to S3 failed with HTTP status 503.");
#endif
            [self setRetryAfterDelayForFile:filePath];
        } break;
            
        default: {
            // iOS handles redirects automatically so only e.g. 307 resource not changed etc. from the 300 range should end up here
            // (along with all unhandled 4xx and 5xx of course)
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
    
    SBBUploadSession *uploadSession = [_cleanObjectManager objectFromBridgeJSON:jsonObject];
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
    // We only compare the file and its containing directory, because at least in the debugger, the app guid (which is part of the /tmp
    // folder's path) can change from one run to the next, so the complete file path won't match.
    NSArray *uploadFiles = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadFilesKey].allValues;
    for (NSString *uploadFile in uploadFiles) {
        if ([uploadFile isEquivalentToPath:fileUrl.path]) {
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
    
    if (!_cleanObjectManager) {
        _cleanObjectManager = [SBBObjectManager objectManager];
    }
    
    // default to generic binary file if type not specified
    if (!contentType) {
        contentType = @"application/octet-stream";
    }
    
    NSString *name = [fileUrl lastPathComponent];
    NSData *fileData = [NSData dataWithContentsOfURL:tempFileURL];
    if (!fileData) {
        if (completion) {
            completion([NSError generateSBBTempFileReadErrorForURL:fileUrl]);
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
    NSDictionary *uploadRequestJSON = [_cleanObjectManager bridgeJSONFromObject:uploadRequest];
    
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
                switch (statusCode) {
                    case 412:
                        // not consented--don't retry; we shouldn't be uploading data in the first place
                        [self completeUploadOfFile:task.taskDescription withError:error];
                        break;
                        
                    default:
                        // anything else, retry after a delay
#if DEBUG
                        NSLog(@"Request to Bridge for UploadSession failed with HTTP status %@. Will retry after delay.", @(statusCode));
#endif
                        [self setRetryAfterDelayForFile:filePath];
                        break;
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
        if (!completion) {
            NSString *originalFile = [[self fileForTempFile:filePath] fullyQualifiedPath];
            if (originalFile.length) {
                if  ([fileMan fileExistsAtPath:originalFile]) {
                    [fileMan removeItemAtPath:originalFile error:nil];
                }
                
                // also remove it from the upload files map
                [self removeFileForTempFile:filePath];
            }
            
        }
        
        // let the SDK figure out the contentType
        [self uploadFileToBridge:[NSURL fileURLWithPath:filePath] completion:^(NSError *error) {
            if (!error) {
                // now that it's been uploaded, delete it
                NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
                if  (!fileUrl) {
                    NSLog(@"Could not create NSURL for file %@", filePath);
                }
                NSError *error;
                if (![fileMan removeItemAtURL:fileUrl error:&error]) {
                    NSLog(@"Failed to remove file %@, error:\n%@", filePath, error);
                }
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

- (void)checkAndRetryOrphanedUploads
{
    [((SBBNetworkManager *)self.networkManager) performBlockOnBackgroundDelegateQueue:^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSFileManager *fileMan = [NSFileManager defaultManager];
        NSMutableSet *filesRetrying = [NSMutableSet set];
        
        // assume any outstanding upload requests without corresponding upload sessions whose files are
        // more than a day old are orphaned (note that under some unusual circumstances this may lead
        // to duplication of uploads).
        static const NSTimeInterval oneDay = 24. * 60. * 60.;
        NSArray *uploadFiles = [defaults dictionaryForKey:kUploadFilesKey].allKeys;
        NSDictionary *uploadRequests = [defaults dictionaryForKey:kUploadRequestsKey];
        NSDictionary *uploadSessions = [defaults dictionaryForKey:kUploadSessionsKey];
        for (NSString *relativePath in uploadRequests.allKeys) {
            NSString *filePath = [relativePath fullyQualifiedPath];
            if ([filesRetrying containsObject:relativePath]) {
                continue; // skip it, we're already retrying this one
            }
            if (!uploadSessions[relativePath]) {
                // get the modification date of the file, if it still exists
                NSDictionary *fileAttrs = [fileMan attributesOfItemAtPath:filePath error:nil];
                if (fileAttrs) {
                    NSDate *modified = [fileAttrs fileModificationDate];
                    if ([modified timeIntervalSinceNow] < -oneDay) {
                        // it's more than a day old, so we will retry now
                        // but first, if it's in the retry queue, take it out
                        [self setRetryTime:nil forFile:filePath];
                        
                        // ...and update its modification date so we don't keep thinking it's due for a retry
                        [fileMan setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:nil];
                        
                        // ok, now do the retry
                        NSDictionary *uploadRequestJSON = [self uploadRequestJSONForFile:filePath];
                        [filesRetrying addObject:filePath];
                        [self kickOffUploadForFile:filePath uploadRequestJSON:uploadRequestJSON];
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
                
                // if an old upload request still exists for this file, reuse it
                NSDictionary *uploadRequestJSON = [self uploadRequestJSONForFile:filePath];
                if (uploadRequestJSON) {
                    // 'touch' the file so it doesn't look orphaned too soon
                    [fileMan setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:nil];
                    [self kickOffUploadForFile:filePath uploadRequestJSON:uploadRequestJSON];
                } else {
                    // earlier version of SDK cleaned up saved UploadRequests prematurely, so just start over
                    // from scratch if we don't have one
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
                [filesRetrying addObject:filePath];
                [self retryOrphanedUploadFromScratch:filePath];
            }
        }
        
        // last but not least, any files lingering in the app support directory that weren't even
        // in the uploadFiles list (because older versions didn't actually ever put files in that list)
        // are assumed to be orphaned
        NSURL *tempDir = [self tempUploadDirURL];
        NSArray *tempContents = [self filesUnderDirectory:tempDir];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return ![uploadFiles containsObject:[((NSURL *)evaluatedObject).path sandboxRelativePath]];
        }];
        
        NSArray *filesOfInterest = [tempContents filteredArrayUsingPredicate:predicate];
        for (NSURL *fileURL in filesOfInterest) {
            NSString *filePath = fileURL.path;
            if ([filesRetrying containsObject:filePath]) {
                continue; // skip it, we're already retrying this one
            }
            [filesRetrying addObject:filePath];
            [self retryOrphanedUploadFromScratch:filePath];
        }
    }];
}

#pragma mark - Delegate methods

- (void)completeUploadOfFile:(NSString *)file withError:(NSError *)error
{
    SBBUploadManagerCompletionBlock completion = [self completionBlockForFile:file];
    if (completion) {
        [self removeCompletionBlockForFile:file];
    }
    if (_uploadDelegate) {
        NSString *originalFile = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadFilesKey][file];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *files = [defaults dictionaryForKey:kUploadFilesKey];
    for (NSString *file in files.allKeys) {
        [self completeUploadOfFile:file withError:error];
    }
    
    // clear everything out
    [_uploadCompletionHandlers removeAllObjects];
    [defaults removeObjectForKey:kUploadRequestsKey];
    [defaults removeObjectForKey:kUploadSessionsKey];
    [defaults removeObjectForKey:kUploadFilesKey];
    
    NSError *fileError;
    [[NSFileManager defaultManager] removeItemAtURL:[self tempUploadDirURL] error:&fileError];
    if (fileError) {
        NSLog(@"Error removing temp upload file directory:\n%@", fileError);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // This is actually an indirect delegate, with calls passed through from SBBNetworkManager's session delegate.
    // We use the same protocol to avoid needless duplication, and this method is required by that protocol,
    // but between the original session delegate and completion handlers, there's nothing left for us to do here.
}

@end
