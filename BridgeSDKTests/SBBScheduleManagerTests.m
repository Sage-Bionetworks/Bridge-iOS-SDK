//
//  SBBScheduleManagerTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPITestCase.h"
#import <BridgeSDK/SBBScheduleManager.h>
#import <BridgeSDK/SBBBridgeObjects.h>

@interface SBBScheduleManagerTests : SBBBridgeAPITestCase

@end

@implementation SBBScheduleManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetSchedules {
  NSArray *schedules =
  @[
    @{
      @"type": @"Schedule",
      @"label": @"Schedule 1 Label",
      @"activityType": @"survey",
      @"activityRef": @"url-to-retrieve-survey",
      @"scheduleType": @"once"
      }
    ];
  [self.mockNetworkManager setJson:schedules andResponseCode:200 forEndpoint:@"/api/v1/schedules" andMethod:@"GET"];
  SBBScheduleManager *sMan = [SBBScheduleManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:self.mockNetworkManager objectManager:SBBComponent(SBBObjectManager)];
  
  [sMan getSchedulesWithCompletion:^(NSArray *schedules, NSError *error) {
    XCTAssert([schedules isKindOfClass:[NSArray class]], @"Converted incoming json to NSArray");
    XCTAssert(schedules.count, @"Converted incoming json to non-empty NSArray");
    if (schedules.count) {
      XCTAssert([schedules[0] isKindOfClass:[SBBSchedule class]], @"Converted incoming json to NSArray of SBBSchedule objects");
    }
  }];
}

@end
