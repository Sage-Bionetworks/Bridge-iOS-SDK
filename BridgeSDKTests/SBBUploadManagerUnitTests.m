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

- (void)checkFile:(NSURL *)uploadFileURL willRetry:(BOOL)willRetryCheck withMessage:(NSString *)message {
    [self checkFile:uploadFileURL willRetry:willRetryCheck withMessage:message cleanUpAfterward:YES];
}

- (void)checkFile:(NSURL *)uploadFileURL willRetry:(BOOL)willRetryCheck withMessage:(NSString *)message cleanUpAfterward:(BOOL)cleanUpAfterward {
    // make sure this happens on the background session delegate queue
    dispatch_block_t block = ^{
        BOOL willRetry = NO;
        BOOL fileExists = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
        NSString *uploadFileName = [uploadFileURL lastPathComponent];
        for (NSString *fileURLString in retryUploads.allKeys) {
            NSString *retryFileName = [fileURLString lastPathComponent];
            if ([retryFileName hasSuffix:uploadFileName]) {
                willRetry = YES;
                fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileURLString];
                if (cleanUpAfterward) {
                    // clean up
                    id <SBBUploadManagerInternalProtocol> uMan = (id <SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager);
                    [uMan cleanUpTempFile:fileURLString];
                    [uMan setUploadRequestJSON:nil forFile:fileURLString];
                    [uMan setUploadSessionJSON:nil forFile:fileURLString];
                    [retryUploads removeObjectForKey:fileURLString];
                    [defaults setValue:retryUploads forKey:kSBBUploadRetryAfterDelayKey];
                    [defaults synchronize];
                }
                
                break;
            }
        }
        XCTAssert(willRetry == willRetryCheck, @"%@", message);
        XCTAssert(fileExists == willRetryCheck, @"File for retry exists if retrying, doesn't if not");
    };
    
    if ([NSOperationQueue currentQueue] == self.mockBackgroundURLSession.delegateQueue) {
        // already there--just do it
        block();
    } else {
        // toss it in the background session delegate queue and wait for it to finish
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:block];
        [self.mockBackgroundURLSession.delegateQueue addOperations:@[op] waitUntilFinished:YES];
    }
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
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(error, @"Got error in completion handler, as expected");
        
        [self checkFile:uploadFileURL willRetry:NO withMessage:@"Not retrying after 412 from upload API"];
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
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        XCTAssert(!error, "Completed retry of upload without error");
        [self checkFile:uploadFileURL willRetry:NO withMessage:@"No longer in retry queue after successful retry"];
        
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
            [self checkFile:uploadFileURL willRetry:YES withMessage:@"Will retry after 503 from upload API" cleanUpAfterward:NO];
            
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
            [(id <SBBUploadManagerInternalProtocol>)SBBComponent(SBBUploadManager) retryUploadsAfterDelay];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];

}

- (void)testUploadFileToBridgeWhenS3UploadExpired {
    // test when the session is expired:
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
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:403 forEndpoint:endpoint andMethod:@"PUT"];
    
    // -- it will immediately retry, so set up the retry UploadRequest response
    responseDict = @{kKeySessionId:@"not-a-real-guid", kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:86400] ISO8601String], kKeyType:@"UploadSession"};
    endpoint = kSBBUploadAPI;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
    downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-success" withExtension:@"json"];
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
    XCTestExpectation *expectRetried = [self expectationWithDescription:@"retried immediately after 403"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(!error, @"No error in completion handler, as expected");
        
        [self checkFile:uploadFileURL willRetry:NO withMessage:@"Successfully retried after 403 from S3 and no longer awaiting retry"];
        
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
    
    [self waitForExpectationsWithTimeout:500.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

- (void)testUploadFileToBridgeWhenS3Responds500 {
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
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:500 forEndpoint:endpoint andMethod:@"PUT"];
    
    // -- it will immediately retry, so set up the retry UploadRequest response
    responseDict = @{kKeySessionId:@"not-a-real-guid", kKeySessionUrl:s3url, kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:86400] ISO8601String], kKeyType:@"UploadSession"};
    endpoint = kSBBUploadAPI;
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
    downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"upload-request-success" withExtension:@"json"];
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
    XCTestExpectation *expectRetried = [self expectationWithDescription:@"retried immediately after 403"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(!error, @"No error in completion handler, as expected");
        
        [self checkFile:uploadFileURL willRetry:NO withMessage:@"Successfully retried after 500 from S3 and no longer awaiting retry"];
        
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
    
    [self waitForExpectationsWithTimeout:500.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

- (void)testUploadFileToBridgeWhenS3Responds503 {
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
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        // will never get here in this test
    }];
    
    // queue up a couple of times to make sure the above stuff has actually completed before we check the retry queue
    [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
        [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
            [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
                [expect503 fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
    
    [self checkFile:uploadFileURL willRetry:YES withMessage:@"Will retry after 503 from S3"];
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
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(!error, @"No error in completion handler, as expected");
        
        [self checkFile:uploadFileURL willRetry:NO withMessage:@"Successfully uploaded and not awaiting retry"];
        
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
    
    [self waitForExpectationsWithTimeout:500.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

- (void)testCheckAndRetryOrphanedUploads {
    // step 1: orphan an upload by failing the initial request and then removing it from the retry queue,
    // but leaving it in the list of files being uploaded
    NSDictionary *responseDict = @{@"message": @"try again later"};
    NSString *endpoint = kSBBUploadAPI;
    NSURL *downloadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"failed-upload-request-response" withExtension:@"json"];
    [self.mockBackgroundURLSession setJson:responseDict andResponseCode:500 forEndpoint:endpoint andMethod:@"POST"];
    [self.mockBackgroundURLSession setDownloadFileURL:downloadFileURL andError:nil forEndpoint:endpoint andMethod:@"POST"];
    
    XCTestExpectation *expect500 = [self expectationWithDescription:@"500: internal server error"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        // won't ever get here because we're going to orphan it
    }];
    
    // queue up a couple of times to make sure the above stuff has actually completed before we check the retry queue
    [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
        [self.mockBackgroundURLSession.delegateQueue addOperationWithBlock:^{
            [self checkFile:uploadFileURL willRetry:YES withMessage:@"Would retry after 500 from upload API" cleanUpAfterward:NO];
            
            // remove it from the retry queue to 'orphan' it
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            NSMutableDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
            [retryUploads removeObjectForKey:uploadFileURL.path];
            [defaults setValue:retryUploads forKey:kSBBUploadRetryAfterDelayKey];
            [defaults synchronize];
        }];
    }];

    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
    
    // step 2: now checkAndRetryOrphanedUploads and make sure it goes into the retry queue, and then uploads
    
    // step 3: this time orphan it by getting a 503 from s3 and removing it from the retry queue, because the code
    // path in checkAndRetryOrphanedUploads will be different
    
    // step 4: now checkAndRetryOrphanedUploads and make sure it goes into the retry queue, and then uploads

}

@end
