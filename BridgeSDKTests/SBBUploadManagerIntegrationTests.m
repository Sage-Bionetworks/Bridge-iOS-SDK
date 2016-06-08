//
//  SBBUploadManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/18/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"

@interface SBBUploadManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBUploadManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUploadFileToBridge {
    XCTestExpectation *expectUploaded = [self expectationWithDescription:@"Uploaded"];
    NSURL *uploadFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"cat" withExtension:@"jpg"];
    [SBBComponent(SBBUploadManager) uploadFileToBridge:uploadFileURL contentType:@"image/jpeg" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading file to Bridge:\n%@", error);
        }
        XCTAssert(!error, @"Uploaded file");
        [expectUploaded fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout uploading file: %@", error);
        }
    }];
}

@end
