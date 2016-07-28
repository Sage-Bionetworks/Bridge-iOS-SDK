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

- (void)testUploadFileToBridgeWhenUploadRequestFails {
    // response for attempt when not consented
    NSDictionary* responseDict = @{@"message": @"try again later"};
    NSString *endpoint = kSBBUploadAPI;
    [self.mockURLSession setJson:responseDict andResponseCode:412 forEndpoint:endpoint andMethod:@"POST"];
    
    // use expectations because this stuff involves an NSOperationQueue
    XCTestExpectation *expect412 = [self expectationWithDescription:@"412: not consented, don't retry"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(error, @"Got error in completion handler, as expected");
        
        BOOL willRetry = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
        for (NSString *fileURLString in retryUploads.allKeys) {
            if ([fileURLString isEqualToString:uploadFileURL.path]) {
                willRetry = YES;
                break;
            }
        }
        XCTAssert(!willRetry, @"Not retrying after 412, as expected");
        [expect412 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];

    // response for initial attempt when server is down
    responseDict = @{@"message": @"try again later"};
    endpoint = kSBBUploadAPI;
    [self.mockURLSession setJson:responseDict andResponseCode:503 forEndpoint:endpoint andMethod:@"POST"];

    XCTestExpectation *expect503 = [self expectationWithDescription:@"503: server offline, retry later"];
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        // should never get here in this test
    }];
    
    BOOL willRetry = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *retryUploads = [[defaults dictionaryForKey:kSBBUploadRetryAfterDelayKey] mutableCopy];
    for (NSString *fileURLString in retryUploads.allKeys) {
        if ([fileURLString isEqualToString:uploadFileURL.path]) {
            willRetry = YES;
            break;
        }
    }
    XCTAssert(willRetry, @"Retrying after 503, as expected");
    [expect503 fulfill];

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

- (void)testUploadFileToBridgeWhenS3UploadFails {
    NSDictionary* responseDict = @{kKeySessionId:@"not-a-real-guid", kKeySessionUrl:@"not-a-real-url", kKeySessionExpires:[[NSDate dateWithTimeIntervalSinceNow:86400] ISO8601String]};
    NSString *endpoint = kSBBUploadAPI;
    [self.mockURLSession setJson:responseDict andResponseCode:201 forEndpoint:endpoint andMethod:@"POST"];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
