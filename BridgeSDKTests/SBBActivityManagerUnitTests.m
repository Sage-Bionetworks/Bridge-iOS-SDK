//
//  SBBActivityManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/6/15.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBActivityManagerInternal.h"
#import "SBBBridgeObjects.h"

@interface SBBActivityManagerUnitTests : SBBBridgeAPIUnitTestCase

@end

@implementation SBBActivityManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetScheduledActivitiesAsOf {
    NSArray *tasks =
    @[
      @{
          @"type": @"ScheduledActivity",
          @"guid": @"task-1-guid",
          @"activity": @{
                  @"activityType": @"survey",
                  @"label": @"This is a survey",
                  @"labelDetail": @"It will be long and boring and tedious to fill out",
                  @"survey": @{
                          @"identifier": @"this-is-a-survey",
                          @"guid": @"guid-goes-here",
                          @"createdOn": @"2014-12-12T18:26:01.855Z",
                          @"href": @"url-to-retrieve-survey/guid-goes-here/2014-12-12T18:26:01.855Z",
                          @"type": @"SurveyReference"
                          },
                  @"type": @"Activity"
                  },
          @"scheduledOn": @"2015-05-06T22:00:00.000Z",
          @"expiresOn": @"2020-05-06T22:00:00.000Z",
          @"status": @"available"
          },
      @{
          @"type": @"ScheduledActivity",
          @"guid": @"task-2-guid",
          @"activity": @{
                  @"activityType": @"task",
                  @"label": @"This is a task",
                  @"labelDetail": @"It will be tricky and frustrating to perform",
                  @"task": @{
                          @"identifier": @"this-is-a-task",
                          @"type": @"TaskReference"
                          },
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
    [self.mockURLSession setJson:response andResponseCode:200 forEndpoint:kSBBActivityAPI andMethod:@"GET"];
    id<SBBActivityManagerProtocol> tMan = SBBComponent(SBBActivityManager);
    
    XCTestExpectation *expectGotActivities = [self expectationWithDescription:@"Got scheduled activities"];

    [tMan getScheduledActivitiesForDaysAhead:0 withCompletion:^(NSArray *tasks, NSError *error) {
        XCTAssert([tasks isKindOfClass:[NSArray class]], @"Converted incoming object to NSArray");
        XCTAssert(tasks.count, @"Converted object to non-empty NSArray");
        if (tasks.count) {
            SBBScheduledActivity *task0 = tasks[0];
            XCTAssert([task0 isKindOfClass:[SBBScheduledActivity class]], @"Converted items to NSArray of SBBScheduledActivity objects");
            SBBActivity *activity0 = task0.activity;
            XCTAssert([activity0 isKindOfClass:[SBBActivity class]], @"Converted 'activity' json to an SBBActivity object");
            XCTAssert([activity0.survey isKindOfClass:[SBBSurveyReference class]], @"Converted 'survey' json to SBBSurveyReference object");
            SBBScheduledActivity *task1 = tasks[1];
            SBBActivity *activity1 = task1.activity;
            XCTAssert([activity1 isKindOfClass:[SBBActivity class]], @"Activity of second task is also an SBBActivity object");
            XCTAssert([activity1.activityType isEqualToString:@"task"], @"Put tasks into array in correct order");
            XCTAssert([activity1.task isKindOfClass:[SBBTaskReference class]], @"Converted 'task' json to SBBTaskReference object");
        }
        [expectGotActivities fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting scheduled activities: %@", error);
        }
    }];
}

- (void)testGetScheduledActivitiesForGuid {
    NSString *activityGuid = @"task-1-guid";
    NSString *fromDateString = @"2017-03-30T00:00:00.000Z";
    NSString *toDateString = @"2017-04-01T00:00:00.000Z";
    NSString *task1ScheduledString = @"2017-03-31T04:55:07.867Z";
    NSString *task2ScheduledString = @"2017-03-30T04:55:07.867Z";
    NSString *scheduledActivityGuid1 = [NSString stringWithFormat:@"%@:%@", activityGuid, task1ScheduledString];
    NSString *scheduledActivityGuid2 = [NSString stringWithFormat:@"%@:%@", activityGuid, task2ScheduledString];
    NSDate *fromDate = [NSDate dateWithISO8601String:fromDateString];
    NSDate *toDate = [NSDate dateWithISO8601String:toDateString];
    NSDate *task1Scheduled = [NSDate dateWithISO8601String:task1ScheduledString];
    NSDate *task2Scheduled = [NSDate dateWithISO8601String:task2ScheduledString];
    NSDictionary *task1 =
    @{
      @"type": @"ScheduledActivity",
      @"guid": scheduledActivityGuid1,
      @"activity": @{
              @"activityType": @"survey",
              @"label": @"This is a survey",
              @"labelDetail": @"It will be long and boring and tedious to fill out",
              @"survey": @{
                      @"identifier": @"this-is-a-survey",
                      @"guid": @"guid-goes-here",
                      @"createdOn": @"2014-12-12T18:26:01.855Z",
                      @"href": @"url-to-retrieve-survey/guid-goes-here/2014-12-12T18:26:01.855Z",
                      @"type": @"SurveyReference"
                      },
              @"type": @"Activity"
              },
      @"scheduledOn": task1ScheduledString,
      @"expiresOn": @"2017-04-01T04:55:07.867Z",
      @"status": @"available"
      };
    NSDictionary *task2 =
    @{
      @"type": @"ScheduledActivity",
      @"guid": scheduledActivityGuid2,
      @"activity": @{
              @"activityType": @"survey",
              @"label": @"This is a survey",
              @"labelDetail": @"It will be long and boring and tedious to fill out",
              @"survey": @{
                      @"identifier": @"this-is-a-survey",
                      @"guid": @"guid-goes-here",
                      @"createdOn": @"2014-12-12T18:26:01.855Z",
                      @"href": @"url-to-retrieve-survey/guid-goes-here/2014-12-12T18:26:01.855Z",
                      @"type": @"SurveyReference"
                      },
              @"type": @"Activity"
              },
      @"scheduledOn": task2ScheduledString,
      @"expiresOn": @"2017-03-31T04:55:07.867Z",
      @"status": @"available"
      };
    NSDictionary *response1 = @{
                               @"type": @"ForwardCursorPagedResourceList",
                               @"items": @[task1],
                               @"offsetBy": @"2017-03-31T00:00:00.000",
                               @"hasNext": @(YES),
                               @"scheduledOnStart": fromDateString,
                               @"scheduledOnEnd": toDateString,
                               @"pageSize": @(1)
                               };
    NSDictionary *response2 = @{
                                @"type": @"ForwardCursorPagedResourceList",
                                @"items": @[task2],
                                @"hasNext": @(NO),
                                @"scheduledOnStart": fromDateString,
                                @"scheduledOnEnd": toDateString,
                                @"pageSize": @(1)
                                };
    NSString *endpoint = [NSString stringWithFormat:kSBBHistoricalActivityAPIFormat, @"task-1-guid"];
    [self.mockURLSession setJson:response1 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    [self.mockURLSession setJson:response2 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    
    id<SBBActivityManagerProtocol> tMan = SBBComponent(SBBActivityManager);
    
    XCTestExpectation *expectGotActivities = [self expectationWithDescription:@"Got historical activities"];
    
    [tMan getScheduledActivitiesForGuid:activityGuid scheduledFrom:fromDate to:toDate withCompletion:^(NSArray *tasks, NSError *error) {
        XCTAssert([tasks isKindOfClass:[NSArray class]], @"Converted incoming object to NSArray");
        XCTAssert(tasks.count == 2, @"Expected to retrieve 2 historical activities, got %@", @(tasks.count));
        if (tasks.count) {
            SBBScheduledActivity *task0 = tasks[0];
            XCTAssert([task0 isKindOfClass:[SBBScheduledActivity class]], @"Converted items to NSArray of SBBScheduledActivity objects");
            SBBActivity *activity0 = task0.activity;
            XCTAssert([activity0 isKindOfClass:[SBBActivity class]], @"Converted 'activity' json to an SBBActivity object");
            SBBScheduledActivity *task1 = tasks[1];
            SBBActivity *activity1 = task1.activity;
            XCTAssert([activity1 isKindOfClass:[SBBActivity class]], @"Activity of second task is also an SBBActivity object");
            XCTAssertGreaterThan(task0.scheduledOn, task1.scheduledOn, @"Expected later task first in the array but the order instead is %@ :: %@", task0.scheduledOn, task1.scheduledOn);
        }
        [expectGotActivities fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting historical activities: %@", error);
        }
    }];
}

@end
