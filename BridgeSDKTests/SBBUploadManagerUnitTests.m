//
//  SBBUploadManagerUnitTests.m
//  BridgeSDK
//
// Copyright (c) 2016, Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder(s) nor the names of any contributors
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

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBUploadManagerInternal.h"
#import "NSDate+SBBAdditions.h"
#import "NSString+SBBAdditions.h"

static NSString *const kKeySessionId = @"id";
static NSString *const kKeySessionUrl = @"url";
static NSString *const kKeySessionExpires = @"expires";
static NSString *const kKeyType = @"type";
static NSString *const kSessionType = @"UploadSession";

@interface SBBUploadManagerUnitTests : SBBBridgeAPIUnitTestCase

@property (nonatomic) NSTimeInterval savedDelay;

@end

@implementation SBBUploadManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _savedDelay = kSBBDelayForRetries;
    kSBBDelayForRetries = 0; // don't delay for tests
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    kSBBDelayForRetries = _savedDelay;
    [super tearDown];
}

- (void)checkFile:(NSURL *)tempFileURL willRetry:(BOOL)willRetryCheck withMessage:(NSString *)message {
    [self checkFile:tempFileURL willRetry:willRetryCheck stillExists:willRetryCheck withMessage:message cleanUpAfterward:YES];
}

- (void)checkFile:(NSURL *)tempFileURL willRetry:(BOOL)willRetryCheck stillExists:(BOOL)stillExists withMessage:(NSString *)message cleanUpAfterward:(BOOL)cleanUpAfterward {
    // make sure this happens on the background session delegate queue
    dispatch_block_t block = ^{
        BOOL willRetry = NO;
        NSString *tempFilePath = tempFileURL.path;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempFilePath];
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        
        NSMutableDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
        for (NSString *relativeFilePath in retryUploads.allKeys) {
            NSString *filePath = [relativeFilePath fullyQualifiedPath];
            if ([filePath isEqualToString:tempFilePath]) {
                willRetry = YES;
                if (cleanUpAfterward) {
                    // clean up
                    id <SBBUploadManagerInternalProtocol> uMan = (id <SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager);
                    [uMan cleanUpTempFile:filePath];
                    [uMan setUploadRequestJSON:nil forFile:filePath];
                    [uMan setUploadSessionJSON:nil forFile:filePath];
                    [retryUploads removeObjectForKey:filePath];
                    [defaults setValue:retryUploads forKey:kSBBUploadRetryAfterDelayKey];
                    [defaults synchronize];
                }
                
                break;
            }
        }
        XCTAssert(willRetry == willRetryCheck, @"%@", message);
        XCTAssert(fileExists == stillExists, @"%@: File for retry exists if it should, doesn't if not", message);
    };
    
    [self.mockBackgroundURLSession doSyncInDelegateQueue:block];
}

- (void)testUploadFileToBridgeWhenUploadRequestFails {
    // response for attempt when not consented
    NSDictionary *responseDict = @{@"message": @"try again later"};
    NSString *endpoint = kSBBUploadAPI;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:412 forEndpoint:endpoint andMethod:@"POST"];
    NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"failed-upload-request-response" withExtension:@"json"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
    
    // use expectations because this stuff involves an NSOperationQueue
    XCTestExpectation *expect412 = [self expectationWithDescription:@"412: not consented, don't retry"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    id<SBBUploadManagerInternalProtocol> uMan = (id<SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager);
    __block NSURL *tempFileURL = [uMan tempFileForUploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(error, @"Got error in completion handler, as expected");
        
        [self checkFile:tempFileURL willRetry:NO withMessage:@"Not retrying after 412 from upload API"];
        [expect412 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];

    // response for initial attempt when server is down
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:503 forEndpoint:endpoint andMethod:@"POST"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];

    XCTestExpectation *expectRetried = [self expectationWithDescription:@"got 503 and then retried 'later'"];
    tempFileURL = [uMan tempFileForUploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        XCTAssert(!error, "Completed retry of upload without error");
        [self checkFile:tempFileURL willRetry:NO withMessage:@"No longer in retry queue after successful retry"];
        
        // make sure we didn't generate any spurious uploads or retries
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        NSDictionary *retryUploads = [defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey];
        NSDictionary *uploadFiles = [defaults dictionaryForKey:kUploadFilesKey];
        NSDictionary *uploadRequests = [defaults dictionaryForKey:kUploadRequestsKey];
        NSDictionary *uploadSessions = [defaults dictionaryForKey:kUploadSessionsKey];
        XCTAssert(retryUploads.count == 0, @"No files left in retry-time map");
        XCTAssert(uploadFiles.count == 0, @"No files left in temp-file-to-original-file map");
        XCTAssert(uploadRequests.count == 0, @"No files left in temp-file-to-upload-request map");
        XCTAssert(uploadSessions.count == 0, @"No files left in temp-file-to-upload-session map");
        
        // make sure we didn't leave any unreferenced files lying around in the temp upload dir
        NSURL *tempDir = [uMan tempUploadDirURL];
        NSArray *tempContents = [uMan filesUnderDirectory:tempDir];
        XCTAssert(tempContents.count == 0, @"No files left in temp upload dir");
        
        // make sure all the mock response stuff got "used up"
        for (NSString *key in self.mockBackgroundURLSession.jsonForEndpoints.allKeys) {
            NSDictionary *jsonForEndpoint = self.mockBackgroundURLSession.jsonForEndpoints[key];
            XCTAssert(jsonForEndpoint.count == 0, @"Used up all the json for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.codesForEndpoints.allKeys) {
            NSDictionary *codesForEndpoint = self.mockBackgroundURLSession.codesForEndpoints[key];
            XCTAssert(codesForEndpoint.count == 0, @"Used up all the status codes for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.URLSForEndpoints.allKeys) {
            NSDictionary *URLSForEndpoint = self.mockBackgroundURLSession.URLSForEndpoints[key];
            XCTAssert(URLSForEndpoint.count == 0, @"Used up all the download file URLs for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.errorsForEndpoints.allKeys) {
            NSDictionary *errorsForEndpoint = self.mockBackgroundURLSession.errorsForEndpoints[key];
            XCTAssert(errorsForEndpoint.count == 0, @"Used up all the NSErrors for endpoints");
        }
        [expectRetried fulfill];
    }];
    
    // queue up a couple of times to make sure the above stuff has actually completed before we check the retry queue
    [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
        [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
            [self checkFile:tempFileURL willRetry:YES stillExists:YES withMessage:@"Will retry after 503 from upload API" cleanUpAfterward:NO];
            
            // set up mock responses for retry
            // -- set up the UploadRequest response
            NSString *s3url = @"/not-a-real-pre-signed-S3-url";
            NSString *sessionGuid = @"not-a-real-guid";
            NSDictionary *responseDict = @{kKeySessionId:@"not-a-real-guid", kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:86400] ISO8601String], kKeyType:@"UploadSession"};
            NSString *endpoint = kSBBUploadAPI;
            [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
            NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-success" withExtension:@"json"];
            [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
            
            // -- set up the mock S3 upload success response
            responseDict = @{};
            endpoint = s3url;
            [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"PUT"];
            
            // -- set up the mock upload completed response
            responseDict = nil;
            endpoint = [NSString stringWithFormat:kSBBUploadCompleteAPIFormat, sessionGuid];
            [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"POST"];
            downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"empty-response-body" withExtension:@"json"];
            [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
            
            // -- try it
            [uMan retryUploadsAfterDelay];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];

}

- (void)testUploadFileToBridgeWhenS3RespondsWithVariousFailuresThatShouldRetryLater {
    [self testUploadFileToBridgeWhenS3Responds:403]; // pre-signed url expired
    [self testUploadFileToBridgeWhenS3Responds:409]; // ?? but should retry
    [self testUploadFileToBridgeWhenS3Responds:500]; // server error
    [self testUploadFileToBridgeWhenS3Responds:503]; // too many requests--slow down
}

- (void)testUploadFileToBridgeWhenS3Responds:(NSInteger)status {
    // -- set up the mock UploadRequest response
    NSString *s3url = @"/not-a-real-pre-signed-S3-url";
    NSString *sessionGuid = @"not-a-real-guid";
    NSDictionary *responseDict = @{kKeySessionId:sessionGuid, kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:-86400] ISO8601String], kKeyType:@"UploadSession"};
    NSString *endpoint = kSBBUploadAPI;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
    NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-expired" withExtension:@"json"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
    
    // -- set up the mock S3 upload failed response
    responseDict = @{};
    endpoint = s3url;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:status forEndpoint:endpoint andMethod:@"PUT"];
    
    // -- try it
    XCTestExpectation *expectStatus = [self expectationWithDescription:@"in retry queue after non-success status"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    id<SBBUploadManagerInternalProtocol> uMan = (id<SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager);
    __block NSURL *tempFileURL = [uMan tempFileForUploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        // will never get here in this test
    }];
    
    // queue up a couple of times to make sure the above stuff has actually completed before we check the retry queue
    [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
        [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
            [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
                [expectStatus fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout waiting for upload failure: %@", error);
        }
    }];
    
    [self checkFile:tempFileURL willRetry:YES withMessage:@"Will retry after 503 from S3"];
}

- (void)testUploadFileToBridgeHappyPath {
    // -- set up the UploadRequest response
    NSString *s3url = @"/not-a-real-pre-signed-S3-url";
    NSString *sessionGuid = @"not-a-real-guid";
    NSDictionary *responseDict = @{kKeySessionId:@"not-a-real-guid", kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:86400] ISO8601String], kKeyType:@"UploadSession"};
    NSString *endpoint = kSBBUploadAPI;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
    NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-success" withExtension:@"json"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
    
    // -- set up the mock S3 upload success response
    responseDict = @{};
    endpoint = s3url;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"PUT"];
    
    // -- set up the mock upload completed response
    responseDict = nil;
    endpoint = [NSString stringWithFormat:kSBBUploadCompleteAPIFormat, sessionGuid];
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"POST"];
    downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"empty-response-body" withExtension:@"json"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
    
    // -- try it
    XCTestExpectation *expectUploaded = [self expectationWithDescription:@"succeeded first try"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    id<SBBUploadManagerInternalProtocol> uMan = (id<SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager);
    __block NSURL *tempFileURL = [uMan tempFileForUploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(!error, @"No error in completion handler, as expected");
        
        [self checkFile:tempFileURL willRetry:NO withMessage:@"Successfully uploaded and not awaiting retry"];
        
        // make sure we didn't generate any spurious uploads or retries
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        NSDictionary *retryUploads = [defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey];
        NSDictionary *uploadFiles = [defaults dictionaryForKey:kUploadFilesKey];
        NSDictionary *uploadRequests = [defaults dictionaryForKey:kUploadRequestsKey];
        NSDictionary *uploadSessions = [defaults dictionaryForKey:kUploadSessionsKey];
        XCTAssert(retryUploads.count == 0, @"No files left in retry-time map");
        XCTAssert(uploadFiles.count == 0, @"No files left in temp-file-to-original-file map");
        XCTAssert(uploadRequests.count == 0, @"No files left in temp-file-to-upload-request map");
        XCTAssert(uploadSessions.count == 0, @"No files left in temp-file-to-upload-session map");
        
        // make sure we didn't leave any unreferenced files lying around in the temp upload dir
        NSURL *tempDir = [uMan tempUploadDirURL];
        NSArray *tempContents = [uMan filesUnderDirectory:tempDir];
        XCTAssert(tempContents.count == 0, @"No files left in temp upload dir");
        
        // make sure all the mock response stuff got "used up"
        for (NSString *key in self.mockBackgroundURLSession.jsonForEndpoints.allKeys) {
            NSDictionary *jsonForEndpoint = self.mockBackgroundURLSession.jsonForEndpoints[key];
            XCTAssert(jsonForEndpoint.count == 0, @"Used up all the json for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.codesForEndpoints.allKeys) {
            NSDictionary *codesForEndpoint = self.mockBackgroundURLSession.codesForEndpoints[key];
            XCTAssert(codesForEndpoint.count == 0, @"Used up all the status codes for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.URLSForEndpoints.allKeys) {
            NSDictionary *URLSForEndpoint = self.mockBackgroundURLSession.URLSForEndpoints[key];
            XCTAssert(URLSForEndpoint.count == 0, @"Used up all the download file URLs for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.errorsForEndpoints.allKeys) {
            NSDictionary *errorsForEndpoint = self.mockBackgroundURLSession.errorsForEndpoints[key];
            XCTAssert(errorsForEndpoint.count == 0, @"Used up all the NSErrors for endpoints");
        }
        [expectUploaded fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

- (void)removeFileURLFromRetryQueue:(NSURL *)fileURL {
    NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
    NSMutableDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
    [retryUploads removeObjectForKey:[fileURL.path sandboxRelativePath]];
    [defaults setValue:retryUploads forKey:kSBBUploadRetryAfterDelayKey];
    [defaults synchronize];
}

- (void)testCheckAndRetryOrphanedUploadsWhenStuckGettingUploadSession {
    // step 1: orphan an upload by failing the initial request and then removing it from the retry queue,
    // but leaving it in the list of files being uploaded
    NSDictionary *responseDict = @{@"message": @"try again later"};
    NSString *endpoint = kSBBUploadAPI;
    NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"failed-upload-request-response" withExtension:@"json"];
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:500 forEndpoint:endpoint andMethod:@"POST"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
    
    XCTestExpectation *expect500 = [self expectationWithDescription:@"500: internal server error"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    id<SBBUploadManagerInternalProtocol> uMan = (id<SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager);
    __block NSURL *tempFileURL = [uMan tempFileForUploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(!error, @"No error in completion handler, as expected");
        
        [self checkFile:tempFileURL willRetry:NO withMessage:@"Successfully uploaded and not awaiting retry"];
        
        // make sure we didn't generate any spurious uploads or retries
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        NSDictionary *retryUploads = [defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey];
        NSDictionary *uploadFiles = [defaults dictionaryForKey:kUploadFilesKey];
        NSDictionary *uploadRequests = [defaults dictionaryForKey:kUploadRequestsKey];
        NSDictionary *uploadSessions = [defaults dictionaryForKey:kUploadSessionsKey];
        XCTAssert(retryUploads.count == 0, @"%@ files left in retry-time map", @(retryUploads.count));
        XCTAssert(uploadFiles.count == 0, @"%@ files left in temp-file-to-original-file map", @(uploadFiles.count));
        XCTAssert(uploadRequests.count == 0, @"%@ files left in temp-file-to-upload-request map", @(uploadRequests.count));
        XCTAssert(uploadSessions.count == 0, @"%@ files left in temp-file-to-upload-session map", @(uploadSessions.count));
        
        // make sure we didn't leave any unreferenced files lying around in the temp upload dir
        NSURL *tempDir = [uMan tempUploadDirURL];
        NSArray *tempContents = [uMan filesUnderDirectory:tempDir];
        XCTAssert(tempContents.count == 0, @"No files left in temp upload dir");
        
        // make sure all the mock response stuff got "used up"
        for (NSString *key in self.mockBackgroundURLSession.jsonForEndpoints.allKeys) {
            NSDictionary *jsonForEndpoint = self.mockBackgroundURLSession.jsonForEndpoints[key];
            XCTAssert(jsonForEndpoint.count == 0, @"Used up all the json for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.codesForEndpoints.allKeys) {
            NSDictionary *codesForEndpoint = self.mockBackgroundURLSession.codesForEndpoints[key];
            XCTAssert(codesForEndpoint.count == 0, @"Used up all the status codes for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.URLSForEndpoints.allKeys) {
            NSDictionary *URLSForEndpoint = self.mockBackgroundURLSession.URLSForEndpoints[key];
            XCTAssert(URLSForEndpoint.count == 0, @"Used up all the download file URLs for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.errorsForEndpoints.allKeys) {
            NSDictionary *errorsForEndpoint = self.mockBackgroundURLSession.errorsForEndpoints[key];
            XCTAssert(errorsForEndpoint.count == 0, @"Used up all the NSErrors for endpoints");
        }
        [expect500 fulfill];
    }];
    
    // queue up a couple of times to make sure the above stuff has actually completed before we check the retry queue
    [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
        [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
            [self checkFile:tempFileURL willRetry:YES stillExists:YES withMessage:@"Would retry after 500 from upload API" cleanUpAfterward:NO];
            
            // remove it from the retry queue and backdate the file two days to 'orphan' it
            [self removeFileURLFromRetryQueue:tempFileURL];
            [[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate:[NSDate dateWithTimeIntervalSinceNow:-2.*86400.]} ofItemAtPath:tempFileURL.path error:nil];
            
            [self checkFile:tempFileURL willRetry:NO stillExists:YES withMessage:@"Successfully removed file from retry queue" cleanUpAfterward:NO];
            
            // step 2: now checkAndRetryOrphanedUploads and make sure it uploads; we left the saved completion handler
            // in place so we know it's done when it gets there without errors
            // -- set up the UploadRequest response
            NSString *s3url = @"/not-a-real-pre-signed-S3-url";
            NSString *sessionGuid = @"not-a-real-guid";
            NSDictionary *responseDict = @{kKeySessionId:@"not-a-real-guid", kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:86400] ISO8601String], kKeyType:@"UploadSession"};
            NSString *endpoint = kSBBUploadAPI;
            [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
            NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-success" withExtension:@"json"];
            [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
            
            // -- set up the mock S3 upload success response
            responseDict = @{};
            endpoint = s3url;
            [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"PUT"];
            
            // -- set up the mock upload completed response
            responseDict = nil;
            endpoint = [NSString stringWithFormat:kSBBUploadCompleteAPIFormat, sessionGuid];
            [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"POST"];
            downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"empty-response-body" withExtension:@"json"];
            [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
            
            // -- try it
            [uMan checkAndRetryOrphanedUploads];
        }];
    }];

    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

- (void)testCheckAndRetryOrphanedUploadsWhenStuckUploading {
    // step 1: this time orphan it by getting a 503 from s3 and removing it from the retry queue, because the code
    // path in checkAndRetryOrphanedUploads will be different
    // -- set up the mock UploadRequest response
    NSString *s3url = @"/not-a-real-pre-signed-S3-url";
    NSString *sessionGuid = @"not-a-real-guid";
    NSDictionary *responseDict = @{kKeySessionId:sessionGuid, kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:-86400] ISO8601String], kKeyType:@"UploadSession"};
    NSString *endpoint = kSBBUploadAPI;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
    NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-expired" withExtension:@"json"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
    
    // -- set up the mock S3 upload timed-out response
    responseDict = @{};
    endpoint = s3url;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:503 forEndpoint:endpoint andMethod:@"PUT"];
    
    // -- try it
    XCTestExpectation *expect503 = [self expectationWithDescription:@"in retry queue after 503"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    id<SBBUploadManagerInternalProtocol> uMan = (id<SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager);
    __block NSURL *tempFileURL = [uMan tempFileForUploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(!error, @"No error in completion handler, as expected");
        
        [self checkFile:tempFileURL willRetry:NO withMessage:@"Successfully uploaded and not awaiting retry"];
        
        // make sure we didn't generate any spurious uploads or retries
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        NSDictionary *retryUploads = [defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey];
        NSDictionary *uploadFiles = [defaults dictionaryForKey:kUploadFilesKey];
        NSDictionary *uploadRequests = [defaults dictionaryForKey:kUploadRequestsKey];
        NSDictionary *uploadSessions = [defaults dictionaryForKey:kUploadSessionsKey];
        XCTAssert(retryUploads.count == 0, @"No files left in retry-time map");
        XCTAssert(uploadFiles.count == 0, @"No files left in temp-file-to-original-file map");
        XCTAssert(uploadRequests.count == 0, @"No files left in temp-file-to-upload-request map");
        XCTAssert(uploadSessions.count == 0, @"No files left in temp-file-to-upload-session map");
        
        // make sure we didn't leave any unreferenced files lying around in the temp upload dir
        NSURL *tempDir = [uMan tempUploadDirURL];
        NSArray *tempContents = [uMan filesUnderDirectory:tempDir];
        XCTAssert(tempContents.count == 0, @"No files left in temp upload dir");

        // make sure all the mock response stuff got "used up"
        for (NSString *key in self.mockBackgroundURLSession.jsonForEndpoints.allKeys) {
            NSDictionary *jsonForEndpoint = self.mockBackgroundURLSession.jsonForEndpoints[key];
            XCTAssert(jsonForEndpoint.count == 0, @"Used up all the json for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.codesForEndpoints.allKeys) {
            NSDictionary *codesForEndpoint = self.mockBackgroundURLSession.codesForEndpoints[key];
            XCTAssert(codesForEndpoint.count == 0, @"Used up all the status codes for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.URLSForEndpoints.allKeys) {
            NSDictionary *URLSForEndpoint = self.mockBackgroundURLSession.URLSForEndpoints[key];
            XCTAssert(URLSForEndpoint.count == 0, @"Used up all the download file URLs for endpoints");
        }
        for (NSString *key in self.mockBackgroundURLSession.errorsForEndpoints.allKeys) {
            NSDictionary *errorsForEndpoint = self.mockBackgroundURLSession.errorsForEndpoints[key];
            XCTAssert(errorsForEndpoint.count == 0, @"Used up all the NSErrors for endpoints");
        }
        [expect503 fulfill];
    }];
    
    // queue up a couple of times to make sure the above stuff has actually completed before we check the retry queue
    [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
        [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
            [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
                [self checkFile:tempFileURL willRetry:YES stillExists:YES withMessage:@"Would retry after 503 from S3" cleanUpAfterward:NO];
                
                // remove it from the retry queue and backdate the file two days to 'orphan' it
                [self removeFileURLFromRetryQueue:tempFileURL];
                [[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate:[NSDate dateWithTimeIntervalSinceNow:-2.*86400.]} ofItemAtPath:tempFileURL.path error:nil];
                
                [self checkFile:tempFileURL willRetry:NO stillExists:YES withMessage:@"Successfully removed file from retry queue" cleanUpAfterward:NO];
                
                // step 2: now checkAndRetryOrphanedUploads and make sure it uploads; we left the saved completion handler
                // in place so we know it's done when it gets there without errors
                // -- set up the UploadRequest response
                NSString *s3url = @"/not-a-real-pre-signed-S3-url";
                NSString *sessionGuid = @"not-a-real-guid";
                NSDictionary *responseDict = @{kKeySessionId:@"not-a-real-guid", kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:86400] ISO8601String], kKeyType:@"UploadSession"};
                NSString *endpoint = kSBBUploadAPI;
                [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
                NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-success" withExtension:@"json"];
                [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
                
                // -- set up the mock S3 upload success response
                responseDict = @{};
                endpoint = s3url;
                [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"PUT"];
                
                // -- set up the mock upload completed response
                responseDict = nil;
                endpoint = [NSString stringWithFormat:kSBBUploadCompleteAPIFormat, sessionGuid];
                [self.mockBackgroundURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"POST"];
                downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"empty-response-body" withExtension:@"json"];
                [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
                
                // -- try it
                [uMan checkAndRetryOrphanedUploads];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

@end
