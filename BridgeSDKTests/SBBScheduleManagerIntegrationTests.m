//
//  SBBScheduleManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/18/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"

@interface SBBScheduleManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBScheduleManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetSchedules {
    XCTestExpectation *expectGotSchedules = [self expectationWithDescription:@"Retrieved schedules"];
    [SBBComponent(SBBScheduleManager) getSchedulesWithCompletion:^(id schedulesList, NSError *error) {
        if (error) {
            NSLog(@"Error getting schedules:\n%@", error);
        }
        XCTAssert(!error && [schedulesList isKindOfClass:[SBBResourceList class]], @"Retrieved schedules");
        [expectGotSchedules fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting schedules: %@", error);
        }
    }];
}

@end
