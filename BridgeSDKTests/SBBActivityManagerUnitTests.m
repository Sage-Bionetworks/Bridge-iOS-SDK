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
#import "ModelObjectInternal.h"

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
    SBBActivityManager *tMan = [SBBActivityManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    
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
    NSString *fromDateString = @"2017-03-30T00:00:00.000";
    NSString *toDateString = @"2017-04-01T00:00:00.000";
    NSString *task1ScheduledString = @"2017-03-31T04:55:07.867";
    NSString *task2ScheduledString = @"2017-03-30T04:55:07.867";
    NSString *scheduledActivityGuid1 = [NSString stringWithFormat:@"%@:%@", activityGuid, task1ScheduledString];
    NSString *scheduledActivityGuid2 = [NSString stringWithFormat:@"%@:%@", activityGuid, task2ScheduledString];
    NSDate *fromDate = [NSDate dateWithISO8601String:fromDateString];
    NSDate *toDate = [NSDate dateWithISO8601String:toDateString];
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
      @"expiresOn": @"2017-04-01T04:55:07.867",
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
      @"expiresOn": @"2017-03-31T04:55:07.867",
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
    
    SBBActivityManager *tMan = [SBBActivityManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    
    XCTestExpectation *expectGotActivities = [self expectationWithDescription:@"Got historical activities"];
    
    [tMan getScheduledActivitiesForGuid:activityGuid scheduledFrom:fromDate to:toDate withCompletion:^(NSArray *tasks, NSError *error) {
        XCTAssert([tasks isKindOfClass:[NSArray class]], @"Converted incoming object to NSArray");
        XCTAssert(tasks.count == 2, @"Expected to retrieve 2 historical activities, got %@", @(tasks.count));
        if (tasks.count == 2) {
            SBBScheduledActivity *task0 = tasks[0];
            XCTAssert([task0 isKindOfClass:[SBBScheduledActivity class]], @"Converted items to NSArray of SBBScheduledActivity objects");
            SBBActivity *activity0 = task0.activity;
            XCTAssert([activity0 isKindOfClass:[SBBActivity class]], @"Converted 'activity' json to an SBBActivity object");
            SBBScheduledActivity *task1 = tasks[1];
            SBBActivity *activity1 = task1.activity;
            XCTAssert([activity1 isKindOfClass:[SBBActivity class]], @"Activity of second task is also an SBBActivity object");
            XCTAssert([task0.scheduledOn compare:task1.scheduledOn] == NSOrderedDescending, @"Expected later task first in the array but the order instead is %@ :: %@", task0.scheduledOn, task1.scheduledOn);
        }
        [expectGotActivities fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting historical activities: %@", error);
        }
    }];
}

- (void)testSetClientData {
    NSDictionary *task =
    @{
      @"type": @"ScheduledActivity",
      @"guid": @"testSetClientData-task-guid",
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
      @"scheduledOn": @"2017-03-31T04:55:07.867Z",
      @"expiresOn": @"2017-04-01T04:55:07.867Z",
      @"status": @"available"
      };
    
    SBBActivityManager *tMan = [SBBActivityManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    
    // get a scheduledActivity with no clientData into the cache
    SBBScheduledActivity *scheduledActivity = [self.objectManager objectFromBridgeJSON:task];
    
    // attempt to set it to non-JSON, ensure completion handler called with error set appropriately
    NSDictionary *pseudoJSON =
    @{
      @"thing": @{
              @"thing1": @"today's-date-as-a-string",
              @"thing2": [NSDate date]
              }
      };
    
    XCTestExpectation *expectError = [self expectationWithDescription:@"Attempting to set non-valid JSON"];

    [tMan setClientData:pseudoJSON forScheduledActivity:scheduledActivity withCompletion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssertNotNil(error, @"Error should not be nil but is nil; response: %@", responseObject);
        XCTAssertNil(scheduledActivity.clientData, @"clientData should be nil but is: %@", scheduledActivity.clientData);
        [expectError fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout attempting to set non-valid JSON: %@", error);
        }
    }];
    
    // set it to JSON, verify that it's set correclty both in PONSO object and Core Data cache
    NSDictionary *realJSON =
    @{
      @"thing": @{
              @"thing1": @"today's-date-as-a-string",
              @"thing2": [[NSDate date] ISO8601StringUTC]
              },
      @"anotherThing": @[
              @"anotherThing1",
              @(12345),
              @(NO),
              @(3.14159),
              @{
                  @"andAnotherThing": @"never mind"
                  }
              ]
      };
    
    XCTestExpectation *expectSet = [self expectationWithDescription:@"Setting valid JSON"];
    
    [tMan setClientData:realJSON forScheduledActivity:scheduledActivity withCompletion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssertEqualObjects(realJSON, scheduledActivity.clientData, @"Expected PONSO to have same JSON as was set");
        NSManagedObjectContext *context = self.cacheManager.cacheIOContext;
        NSManagedObject *cachedActivity = [self.cacheManager cachedObjectForBridgeObject:scheduledActivity inContext:context];
        id cachedJSON = [cachedActivity valueForKey:NSStringFromSelector(@selector(clientData))];
        XCTAssertEqualObjects(realJSON, cachedJSON, "Expected managed object to have same JSON as was set");
        [expectSet fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout attempting to set valid JSON: %@", error);
        }
    }];

    // set it to [NSNull null], verify that it's nil in both places
    XCTestExpectation *expectNulled = [self expectationWithDescription:@"Setting to null"];
    
    [tMan setClientData:[NSNull null] forScheduledActivity:scheduledActivity withCompletion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssertNil(scheduledActivity.clientData, @"Expected PONSO to have nil but have:\n%@", scheduledActivity.clientData);
        NSManagedObjectContext *context = self.cacheManager.cacheIOContext;
        NSManagedObject *cachedActivity = [self.cacheManager cachedObjectForBridgeObject:scheduledActivity inContext:context];
        id cachedJSON = [cachedActivity valueForKey:NSStringFromSelector(@selector(clientData))];
        XCTAssertNil(cachedJSON, "Expected managed object to have nil but have:\n%@", cachedJSON);
        [expectNulled fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout attempting to null clientData: %@", error);
        }
    }];
}

@end
