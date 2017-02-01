// 
//  SBBDataArchive.m
//  BridgeSDK
// 
// Copyright (c) 2015-2017 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
#import "SBBDataArchive.h"
#import "BridgeSDK+Internal.h"
#import <objc/runtime.h>
#import "ZipZap.h"
#import "SBBEncryptor.h"



static NSString * kFileInfoNameKey                  = @"filename";
static NSString * kUnencryptedArchiveFilename       = @"unencrypted.zip";
static NSString * kFileInfoTimeStampKey             = @"timestamp";
static NSString * kFileInfoContentTypeKey           = @"contentType";
static NSString * kTaskRunKey                       = @"taskRun";
static NSString * kFilesKey                         = @"files";
static NSString * kAppNameKey                       = @"appName";
static NSString * kAppVersionKey                    = @"appVersion";
static NSString * kPhoneInfoKey                     = @"phoneInfo";
static NSString * kItemKey                          = @"item";
static NSString * kJsonPathExtension                = @"json";
static NSString * kJsonInfoFilename                 = @"info.json";

@interface SBBDataArchive ()

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) ZZArchive *zipArchive;
@property (nonatomic, strong) NSMutableArray *zipEntries;
@property (nonatomic, strong) NSMutableArray *filesList;
@property (nonatomic, strong) NSMutableDictionary *infoDict;
@property (nonatomic, strong) NSMutableArray *expectedJsonFilenames;

@end

@implementation SBBDataArchive

- (instancetype)init {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: @"method unavailable"
                                 userInfo: nil];
    return nil;
}

//designated initializer
- (instancetype)initWithReference:(NSString *)reference
            jsonValidationMapping:(nullable NSDictionary <NSString *, NSPredicate *> *)jsonValidationMapping {
    self = [super init];
    if (self) {
        _reference = [reference copy];
        _jsonValidationMapping = [jsonValidationMapping copy];
        _expectedJsonFilenames = [[jsonValidationMapping allKeys] mutableCopy];
        [self commonInit];
    }
    
    return self;
}

//create a new zip archive at the reference path
- (void)commonInit
{
    NSURL *zipArchiveURL = [NSURL fileURLWithPath:[[self workingDirectoryPath] stringByAppendingPathComponent:kUnencryptedArchiveFilename]];
    _unencryptedURL = zipArchiveURL;

    _zipEntries = [NSMutableArray array];
    _filesList = [NSMutableArray array];
    _infoDict = [NSMutableDictionary dictionary];
    NSError * error;
    
    _zipArchive = [[ZZArchive alloc] initWithURL:zipArchiveURL
                                             options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                               error:&error];
    if (!_zipArchive) {
        NSAssert(NO, @"Error creating zip archive:\n%@", error);
    }
}

//A sandbox in the temporary directory for this archive to be cleaned up on completion.
- (NSString *)workingDirectoryPath
{
    
    NSString *workingDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.reference];
    if (![[NSFileManager defaultManager] fileExistsAtPath:workingDirectoryPath]) {
        NSError * fileError;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:workingDirectoryPath withIntermediateDirectories:YES attributes:@{ NSFileProtectionKey : NSFileProtectionComplete } error:&fileError];
        if (!created) {
            workingDirectoryPath = nil;
            NSAssert(NO, @"Error creating working directory %@:\n%@", workingDirectoryPath, fileError);
        }
    }
    
    return workingDirectoryPath;
}

- (void)setArchiveInfoObject:(id)object forKey:(NSString*)key {
    self.infoDict[key] = [[SBBObjectManager objectManager] bridgeJSONFromObject:object];
}

- (void)insertURLIntoArchive:(NSURL*)url fileName:(NSString *)filename
{
    NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:nil];
    NSDate *createdOn = [NSDate date]; // fallback in case there's a problem getting the file attributes
    if (fileAttrs) {
        createdOn = [fileAttrs fileCreationDate];
    }
    NSData *dataToInsert = [NSData dataWithContentsOfURL:url];
    [self insertDataIntoArchive:dataToInsert filename:filename createdOn:createdOn];
}

- (void)insertDictionaryIntoArchive:(NSDictionary *)dictionary filename:(NSString *)filename createdOn:(nonnull NSDate *)createdOn
{
#if DEBUG
    SBBLog(@"Archiving %@: %@", filename, dictionary);
#endif
    
    NSPredicate *validationPredicate = self.jsonValidationMapping[filename];
    if (validationPredicate && ![validationPredicate evaluateWithObject:dictionary]) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:1
                                         userInfo:@{ @"filename": filename,
                                                     @"json": dictionary,
                                                     @"validationPredicate": validationPredicate}];
        NSAssert1(false, @"%@", error);
    }
    [self.expectedJsonFilenames removeObject:filename];
    
    NSError * serializationError;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&serializationError];
        
    if (jsonData != nil) {
        [self insertDataIntoArchive:jsonData filename:filename createdOn:createdOn];
    }
    else {
        NSAssert(NO, @"Error serializing JSON dictionary:\n%@", serializationError);
    }
}

- (void)insertDictionaryIntoArchive:(NSDictionary *)dictionary filename:(NSString *)filename
{
    [self insertDictionaryIntoArchive:dictionary filename:filename createdOn:[NSDate date]];
}

- (void)insertDataIntoArchive:(NSData *)data filename:(NSString *)filename createdOn:(nonnull NSDate *)createdOn
{
    // Check that the file has not already been added
    if ([self.filesList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", kFileInfoNameKey, filename]].count != 0) {
        NSAssert1(NO, @"File has already been added: %@", filename);
        return;
    }
    
    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: filename
                                                                compress:YES
                                                               dataBlock:^(NSError** error)
                                 {
                                     SBBLog(@"%@", *error);
                                     return data;
                                 }]];
    
    //add the fileInfoEntry
    NSString *extension = [filename pathExtension] ? : kJsonPathExtension;
    NSDictionary *fileInfoEntry = @{ kFileInfoNameKey: filename,
                                     kFileInfoTimeStampKey: [createdOn ISO8601String],
                                     kFileInfoContentTypeKey: [self contentTypeForFileExtension:extension] };
    
    [self.filesList addObject:fileInfoEntry];

}

- (void)insertDataIntoArchive:(NSData *)data filename:(NSString *)filename
{
    [self insertDataIntoArchive:data filename:filename createdOn:[NSDate date]];
}

+ (NSString *)appVersion
{
    static NSString *appVersion = nil;
    if (!appVersion)
    {
        NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *build   = NSBundle.mainBundle.appVersion;
        appVersion	= [NSString stringWithFormat: @"version %@, build %@", version, build];
    }
    
    return appVersion;
}

- (BOOL)isEmpty
{
    return self.filesList.count == 0;
}

//Compiles the final info.json file and inserts it into the zip archive.
- (BOOL)completeArchive:(NSError **)error
{
    BOOL success = YES;
    NSError *internalError = nil;
    if (!self.isEmpty) {
        
        if (self.expectedJsonFilenames.count > 0) {
            NSString *filenames = [self.expectedJsonFilenames componentsJoinedByString:@","];
            NSError *validationError = [NSError errorWithDomain:NSStringFromClass([self class]) code:1
                                             userInfo:@{ @"message": [NSString stringWithFormat:@"Missing expected json files: %@", filenames]
                                                         }];
            NSAssert1(false, @"%@", validationError);
            if (error) {
                *error = validationError;
                return NO;
            }
        }
        
        [self.infoDict setObject:self.filesList forKey:kFilesKey];
        
        [self.infoDict setObject:self.reference forKey:kItemKey];
        [self.infoDict setObject:[[NSBundle mainBundle] appName] forKey:kAppNameKey];
        [self.infoDict setObject:[self.class appVersion] forKey:kAppVersionKey];
        [self.infoDict setObject:[[UIDevice currentDevice] deviceInfo] forKey:kPhoneInfoKey];

        [self insertDictionaryIntoArchive:self.infoDict filename:kJsonInfoFilename createdOn:[NSDate date]];
        
        if (![self.zipArchive updateEntries:self.zipEntries error:&internalError]) {
            SBBLog(@"%@", internalError);
            success = NO;
            if (error) {
                *error = internalError;
            }
        }
    }
    
    return success;
}

- (void)encryptAndUploadArchive
{
    SBBEncryptor *encryptor = [SBBEncryptor new];
    
    [encryptor encryptFileAtURL:_unencryptedURL withCompletion:^(NSURL *url, NSError *error) {
        if (!error) {
            //remove the archive after encryption
            [self removeArchive];
            
            //upload the encrypted archive
            [SBBComponent(SBBUploadManager) uploadFileToBridge:url contentType:@"application/zip" completion:^(NSError *error) {
                if (!error) {
#if DEBUG
                    SBBLog(@"SBBDataArchive uploaded file: %@", url.relativePath.lastPathComponent);
#endif
                    [encryptor removeDirectory];
                    // TODO: emm 2016-05-18 Fire off a delayed validation check and output the response
                } else {
                    SBBLog(@"SBBDataArchive error returned from SBBUploadManager:\n%@\n%@", error.localizedDescription, error.localizedFailureReason);
                }

            }];
        }
    }];
}

+ (void)encryptAndUploadArchives:(NSArray<SBBDataArchive *> *)archives
{
    for (SBBDataArchive *archive in archives) {
        [archive encryptAndUploadArchive];
    }
}

//delete the workingDirectoryPath, and therefore its contents.
-(void)removeArchive
{
    NSError *err;
    if (![[NSFileManager defaultManager] removeItemAtPath:[self workingDirectoryPath] error:&err]) {
        NSAssert(false, @"Error removing unencrypted archive at %@:]n%@", [self workingDirectoryPath], err);
    }
}

#pragma mark - Helpers

- (NSString *)contentTypeForFileExtension: (NSString *)extension
{
    NSString *contentType;
    if ([extension isEqualToString:@"csv"]) {
        contentType = @"text/csv";
    }else if ([extension isEqualToString:@"m4a"]) {
        contentType = @"audio/mp4";
    }else {
        contentType = @"application/json";
    }
    
    return contentType;
}

@end
