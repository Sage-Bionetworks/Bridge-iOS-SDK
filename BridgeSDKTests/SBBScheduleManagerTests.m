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
          @"activityRef": @"url-to-retrieve-survey/guid-goes-here/2014-12-12T18:26:01.855Z",
          @"activities": @[
                  @{
                      @"activityType": @"survey",
                      @"label": @"This is a survey",
                      @"ref": @"url-to-retrieve-survey/guid-goes-here/2014-12-12T18:26:01.855Z",
                      @"survey": @{
                              @"guid": @"guid-goes-here",
                              @"createdOn": @"2014-12-12T18:26:01.855Z",
                              @"type": @"GuidCreatedOnVersionHolder"
                              },
                      @"type": @"Activity"
                      },
                  @{
                      @"activityType": @"task",
                      @"label": @"This is a task",
                      @"ref": @"task1",
                      @"type": @"Activity"
                      }
                  ],
          @"scheduleType": @"once"
          }
      ];
    [self.mockNetworkManager setJson:schedules andResponseCode:200 forEndpoint:@"/api/v1/schedules" andMethod:@"GET"];
    SBBScheduleManager *sMan = [SBBScheduleManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:self.mockNetworkManager objectManager:SBBComponent(SBBObjectManager)];
    
    [sMan getSchedulesWithCompletion:^(NSArray *schedules, NSError *error) {
        XCTAssert([schedules isKindOfClass:[NSArray class]], @"Converted incoming json to NSArray");
        XCTAssert(schedules.count, @"Converted incoming json to non-empty NSArray");
        if (schedules.count) {
            SBBSchedule *schedule0 = schedules[0];
            XCTAssert([schedule0 isKindOfClass:[SBBSchedule class]], @"Converted incoming json to NSArray of SBBSchedule objects");
            SBBActivity *activity0 = schedule0.activities[0];
            XCTAssert([activity0 isKindOfClass:[SBBActivity class]], @"Converted 'activities' json to NSArray and first item is an SBBActivity object");
            XCTAssert([activity0.survey isKindOfClass:[SBBGuidCreatedOnVersionHolder class]], @"Converted 'survey' json to SBBGuidCreatedOnVersionHolder object");
            SBBActivity *activity1 = schedule0.activities[1];
            XCTAssert([activity1 isKindOfClass:[SBBActivity class]], @"Second item of 'activities' is also an SBBActivity object");
            XCTAssert([activity1.activityType isEqualToString:@"task"], @"Put activities into array in correct order");
        }
    }];
}

@end
