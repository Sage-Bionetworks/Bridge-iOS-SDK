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
          },
      @{
          @"type": @"ScheduledActivity",
          @"guid": @"task-3-guid",
          @"activity": @{
                  @"activityType": @"compound",
                  @"label": @"This is a compound activity",
                  @"labelDetail": @"It will be tricky and frustrating to perform",
                  @"compoundActivity": @{
                          @"type": @"CompoundActivity",
                          @"taskIdentifier": @"this-is-a-compound-activity",
                          @"schemaList": @[
                                         @{
                                             @"id": @"this-is-a-schema-ref",
                                             @"revision": @(0),
                                             @"type": @"SchemaReference"
                                         }
                                         ],
                          @"surveyList": @[
                                         @{
                                             @"identifier": @"this-is-a-survey-ref",
                                             @"guid": @"survey-guid",
                                             @"createdOn": @"2017-05-09T18:26:02.523Z",
                                             @"href": @"url-to-retrieve-survey/guid-goes-here/2017-05-09T18:26:02.523Z",
                                             @"type": @"SurveyReference"
                                         }
                                         ],
                          },
                  @"type": @"Activity"
                  },
          @"scheduledOn": @"2015-05-07T00:00:00.000Z",
          @"expiresOn": @"2020-05-07T00:00:00.000Z",
          @"status": @"available"
          }
      ];
    NSDictionary *response = @{
                                  @"type": @"DateTimeRangeResourceList",
                                  @"items": tasks,
                                  @"total": @(tasks.count),
                                  };
    [self.mockURLSession setJson:response andResponseCode:200 forEndpoint:kSBBActivityAPI andMethod:@"GET"];
    SBBActivityManager *tMan = [SBBActivityManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    
    XCTestExpectation *expectGotActivities = [self expectationWithDescription:@"Got scheduled activities"];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [tMan getScheduledActivitiesForDaysAhead:0 withCompletion:^(NSArray *tasks, NSError *error) {
#pragma clang diagnostic pop
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
            SBBScheduledActivity *task2 = tasks[2];
            SBBActivity *activity2 = task2.activity;
            XCTAssert([activity2 isKindOfClass:[SBBActivity class]], @"Activity of third task is also an SBBActivity object");
            XCTAssert([activity2.activityType isEqualToString:@"compound"], @"Put tasks into array in correct order");
            XCTAssert([activity2.compoundActivity isKindOfClass:[SBBCompoundActivity class]], @"Converted 'compoundActivity' json to SBBCompoundActivity object");
            XCTAssert(activity2.compoundActivity.schemaList.count == 1, @"Expected 1 object in schemaList, got %@", @(activity2.compoundActivity.schemaList.count));
            if (activity2.compoundActivity.schemaList.count) {
                SBBSchemaReference *schemaRef = activity2.compoundActivity.schemaList[0];
                XCTAssert([schemaRef isKindOfClass:[SBBSchemaReference class]], @"Expected SBBSchemaReference, got %@", [schemaRef class]);
            }
            XCTAssert(activity2.compoundActivity.surveyList.count == 1, @"Expected 1 object in surveyList, got %@", @(activity2.compoundActivity.surveyList.count));
            if (activity2.compoundActivity.surveyList.count) {
                SBBSurveyReference *surveyRef = activity2.compoundActivity.surveyList[0];
                XCTAssert([surveyRef isKindOfClass:[SBBSurveyReference class]], @"Expected SBBSurveyReference, got %@", [surveyRef class]);
            }
            
            // Also make sure the ResourceList containing the activities is properly identified
            // in the cache for later retrieval
            NSString *rlistName = SBBDateTimeRangeResourceList.entityName;
            NSString *saName = SBBScheduledActivity.entityName;
            SBBDateTimeRangeResourceList *activitiesRList = (SBBDateTimeRangeResourceList *)[self.cacheManager cachedObjectOfType:rlistName withId:saName createIfMissing:NO];
            XCTAssertNotNil(activitiesRList, @"Failed to retrieve %@ with listID__ '%@'", rlistName, saName);
            
            // ...and make sure it's in the backing store, not just the in-memory cache
            NSManagedObjectContext *context = self.cacheManager.cacheIOContext;
            NSEntityDescription *entity = [NSEntityDescription entityForName:rlistName inManagedObjectContext:context];
            NSString *keyPath = entity.userInfo[@"entityIDKeyPath"];
            NSManagedObject *mo = [self.cacheManager managedObjectOfEntity:entity withId:saName atKeyPath:keyPath];
            XCTAssertNotNil(mo, @"Failed to retrieve %@ with %@ == '%@' from core data cache", rlistName, keyPath, saName);
        }
        [expectGotActivities fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting scheduled activities: %@", error);
        }
    }];
}

- (void)testGetScheduledActivitiesFromTo {
    NSString *activityGuid = @"task-1-guid";
    NSString *fromDateString = @"2017-03-01T00:00:00.000-07:00";
    NSString *toDateString = @"2017-04-01T00:00:00.000-07:00";
    NSString *task1ScheduledString = @"2017-03-05T04:55:07.867-07:00";
    NSString *task2ScheduledString = @"2017-03-30T04:55:07.867-07:00";
    NSString *scheduledActivityGuid1 = [NSString stringWithFormat:@"%@:%@", activityGuid, task1ScheduledString];
    NSString *scheduledActivityGuid2 = [NSString stringWithFormat:@"%@:%@", activityGuid, task2ScheduledString];
    NSDate *fromDate = [NSDate dateWithISO8601String:fromDateString];
    NSDate *toDate = [NSDate dateWithISO8601String:toDateString];
    NSDictionary *serverClientData = @{
                                       @"thing": @{
                                               @"thing1": @"today's-date-as-a-string",
                                               @"thing2": [[NSDate date] ISO8601StringUTC]
                                               }
                                       };

    NSDictionary *localClientData = @{
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
      @"expiresOn": @"2017-03-06T04:55:07.867-07:00",
      @"status": @"available",
      @"clientData": serverClientData
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
      @"expiresOn": @"2017-03-31T04:55:07.867-07:00",
      @"status": @"available",
      @"clientData": serverClientData
      };
    NSDictionary *response1 = @{
                               @"type": @"DateTimeRangeResourceList",
                               @"items": @[task1],
                               @"startTime": fromDateString,
                               @"endTime": @"2017-03-15T00:00:00.000-07:00"
                               };
    NSDictionary *response2 = @{
                                @"type": @"DateTimeRangeResourceList",
                                @"items": @[],
                                @"startTime": @"2017-03-15T00:00:00.000-07:00",
                                @"endTime": @"2017-03-29T00:00:00.000-07:00"
                                };
    NSDictionary *response3 = @{
                                @"type": @"DateTimeRangeResourceList",
                                @"items": @[task2],
                                @"startTime": @"2017-03-29T00:00:00.000-07:00",
                                @"endTime": toDateString
                                };
    NSString *endpoint = [NSString stringWithFormat:kSBBActivityAPI, @"task-1-guid"];
    [self.mockURLSession setJson:response1 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    [self.mockURLSession setJson:response2 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    [self.mockURLSession setJson:response3 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    
    SBBActivityManager *tMan = [SBBActivityManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    
    XCTestExpectation *expectGotActivities = [self expectationWithDescription:@"Got historical activities"];
    
    [tMan getScheduledActivitiesFrom:fromDate to:toDate withCompletion:^(NSArray *tasks, NSError *error) {
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
            XCTAssert([task0.scheduledOn compare:task1.scheduledOn] == NSOrderedAscending, @"Expected tasks in the array in ascending order by scheduledOn but the order instead is %@ :: %@", task0.scheduledOn, task1.scheduledOn);
        }
        [expectGotActivities fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting historical activities: %@", error);
        }
    }];
    
    // now try the same thing, but with the two ScheduledActivities already cached and with different
    // clientData from what the "server" will return; and make sure the clientData gets reconciled correctly.
    [self.cacheManager removeFromCacheObjectOfType:SBBScheduledActivity.entityName withId:scheduledActivityGuid1];
    [self.cacheManager removeFromCacheObjectOfType:SBBScheduledActivity.entityName withId:scheduledActivityGuid2];
    NSMutableDictionary *task1Local = [task1 mutableCopy];
    task1Local[@"clientData"] = localClientData;
    [self.objectManager objectFromBridgeJSON:task1Local];
    NSMutableDictionary *task2Local = [task2 mutableCopy];
    task2Local[@"clientData"] = nil;
    [self.objectManager objectFromBridgeJSON:task2Local];
    
    [self.mockURLSession setJson:response1 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    [self.mockURLSession setJson:response2 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    [self.mockURLSession setJson:response3 andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    
    XCTestExpectation *expectReGotActivities = [self expectationWithDescription:@"Got historical activities again"];
    
    [tMan getScheduledActivitiesFrom:fromDate to:toDate withCompletion:^(NSArray *tasks, NSError *error) {
        XCTAssert(tasks.count == 2, @"Expected to retrieve 2 historical activities, got %@", @(tasks.count));
        if (tasks.count == 2) {
            SBBScheduledActivity *task0 = tasks[0];
            XCTAssertEqualObjects(localClientData, task0.clientData, @"Expected task0 to still have local client data, but have this instead:\n%@", task0.clientData);
            SBBScheduledActivity *task1 = tasks[1];
            XCTAssertEqualObjects(serverClientData, task1.clientData, @"Expected task1 to have gotten the client data from the server, but have this instead:\n%@", task1.clientData);
        }
        [expectReGotActivities fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting historical activities again: %@", error);
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
