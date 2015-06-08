//
//  SBBTaskManagerTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/6/15.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPITestCase.h"
#import <BridgeSDK/SBBTaskManager.h>
#import <BridgeSDK/SBBBridgeObjects.h>

@interface SBBTaskManagerTests : SBBBridgeAPITestCase

@end

@implementation SBBTaskManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetTasksAsOf {
    NSArray *tasks =
    @[
      @{
          @"type": @"Task",
          @"guid": @"task-1-guid",
          @"activity": @{
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
          @"scheduledOn": @"2015-05-06T22:00:00.000Z",
          @"expiresOn": @"2020-05-06T22:00:00.000Z",
          @"status": @"available"
          },
      @{
          @"type": @"Task",
          @"guid": @"task-1-guid",
          @"activity": @{
                  @"activityType": @"task",
                  @"label": @"This is a task",
                  @"ref": @"task1",
                  @"type": @"Activity"
                  },
          @"scheduledOn": @"2015-05-07T00:00:00.000Z",
          @"expiresOn": @"2020-05-07T00:00:00.000Z",
          @"status": @"available"
          }
      ];
    NSDictionary *response = @{
                                  @"type": @"ResourceList",
                                  @"items": tasks,
                                  @"total": @(tasks.count)
                                  };
    [self.mockURLSession setJson:response andResponseCode:200 forEndpoint:@"/api/v1/tasks" andMethod:@"GET"];
    id<SBBTaskManagerProtocol> tMan = SBBComponent(SBBTaskManager);
    
    [tMan getTasksUntil:[NSDate date] withCompletion:^(SBBResourceList *tasksRList, NSError *error) {
        XCTAssert([tasksRList isKindOfClass:[SBBResourceList class]], @"Converted incoming json to SBBResourceList");
        NSArray *tasks = tasksRList.items;
        XCTAssert([tasks isKindOfClass:[NSArray class]], @"Converted items to NSArray");
        XCTAssert(tasks.count, @"Converted items to non-empty NSArray");
        if (tasks.count) {
            SBBTask *task0 = tasks[0];
            XCTAssert([task0 isKindOfClass:[SBBTask class]], @"Converted items to NSArray of SBBTask objects");
            SBBActivity *activity0 = task0.activity;
            XCTAssert([activity0 isKindOfClass:[SBBActivity class]], @"Converted 'activity' json to an SBBActivity object");
            XCTAssert([activity0.survey isKindOfClass:[SBBGuidCreatedOnVersionHolder class]], @"Converted 'survey' json to SBBGuidCreatedOnVersionHolder object");
            SBBTask *task1 = tasks[1];
            SBBActivity *activity1 = task1.activity;
            XCTAssert([activity1 isKindOfClass:[SBBActivity class]], @"Activity of second task is also an SBBActivity object");
            XCTAssert([activity1.activityType isEqualToString:@"task"], @"Put tasks into array in correct order");
        }
    }];
}

@end
