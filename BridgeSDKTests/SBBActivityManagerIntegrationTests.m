//
//  SBBTaskManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/18/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBTestAuthManagerDelegate.h"

#define TASKS_ADMIN_API @"/v3/scheduleplans"

@interface SBBActivityManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@property (nonatomic, strong) NSString *ardUserEmail;
@property (nonatomic, strong) NSString *ardUserUsername;
@property (nonatomic, strong) NSString *ardUserPassword;
@property (nonatomic, strong) SBBAuthManager *aMan;
@property (nonatomic, strong) SBBTestAuthManagerDelegate *aManDelegate;

@property (nonatomic, strong) NSDictionary *schedule;
@property (nonatomic, strong) NSString *scheduleJSON;
@property (nonatomic, strong) NSString *scheduleGuid;
@property (nonatomic, strong) NSString *activityGuid;

- (void)createTestSchedule:(NSDictionary *)schedule completionHandler:(SBBNetworkManagerCompletionBlock)completion;
- (void)deleteSchedule:(NSString *)guid completionHandler:(SBBNetworkManagerCompletionBlock)completion;

@end

@implementation SBBActivityManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // 1. Create a user with admin, researcher, and developer roles so we can do all the things.
    // we need our own auth manager instance (with its own delegate) so we don't eff with the global test user
    _aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    _aManDelegate = [SBBTestAuthManagerDelegate new];
    _aMan.authDelegate = _aManDelegate;
    XCTestExpectation *expectARDUser = [self expectationWithDescription:@"Created user with all roles"];
    [self createTestUserConsented:NO roles:@[@"admin", @"researcher", @"developer"] completionHandler:^(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating all-roles test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
            if (![error.domain isEqualToString:@"com.apple.XCTestErrorDomain"] || error.code != 0) {
                [expectARDUser fulfill];
            }
        } else {
            _ardUserEmail = emailAddress;
            _ardUserUsername = username;
            _ardUserPassword = password;
            [_aMan signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error signing in to all-roles test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                }
                [expectARDUser fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to create and sign in to all-roles test user account:\n%@", error);
        }
    }];
    
    // 2. Create a test schedule.
    _scheduleJSON = @"{\"type\":\"SchedulePlan\",\"label\":\"Sample Schedule\",\"strategy\":{\"schedule\":{\"scheduleType\":\"recurring\",\"interval\":\"P1D\",\"expires\":\"P1D\",\"times\":[\"23:59\"],\"activities\":[{\"type\":\"Activity\",\"label\":\"Sample Task\",\"labelDetail\":\"10 minutes\",\"activityType\":\"task\",\"task\":{\"identifier\":\"task:AAA\"}}]},\"type\":\"SimpleScheduleStrategy\"}}";
    _schedule = [NSJSONSerialization JSONObjectWithData:[_scheduleJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    XCTestExpectation *expectSchedule = [self expectationWithDescription:@"test schedule created"];
    [self createTestSchedule:_schedule completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error trying to create test schedule:\n%@", error);
        }
        
        _scheduleGuid = [responseObject objectForKey:@"guid"];
        [expectSchedule fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to create test schedule:\n%@", error);
        }
    }];
    
    // 3. Read the test schedule back in so we can get the activity guid(s).
    XCTestExpectation *expectScheduleRead = [self expectationWithDescription:@"test schedule read back in"];
    if (_scheduleGuid.length) {
        [self readSchedule:_scheduleGuid completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            if (!error) {
                NSLog(@"Read test schedule %@", _scheduleGuid);
                _activityGuid = [[[[responseObject objectForKey:@"strategy"] objectForKey:@"schedule"] objectForKey:@"activities"][0] objectForKey:@"guid"];
            } else {
                NSLog(@"Failed to read test schedule %@\n\nError:%@\nResponse:%@", _scheduleGuid, error, responseObject);
            }
            [expectScheduleRead fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Timeout error attempting to read test schedule %@", _scheduleGuid);
            }
        }];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    // 3. Delete the test schedule.
    XCTestExpectation *expectSchedule = [self expectationWithDescription:@"test schedule deleted"];
    if (_scheduleGuid.length) {
        [self deleteSchedule:_scheduleGuid completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            if (!error) {
                NSLog(@"Deleted test schedule %@", _scheduleGuid);
                _scheduleGuid = nil;
                _activityGuid = nil;
            } else {
                NSLog(@"Failed to delete test schedule %@\n\nError:%@\nResponse:%@", _scheduleGuid, error, responseObject);
            }
            [expectSchedule fulfill];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Timeout error attempting to delete test schedule %@", _scheduleGuid);
        }
    }];
    
    // 4. Delete the test god-mode user.
    XCTestExpectation *expectUser = [self expectationWithDescription:@"test user deleted"];
    [self deleteUser:_ardUserEmail completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted all-roles test account %@", _ardUserEmail);
        } else {
            NSLog(@"Failed to delete all-roles test account %@\n\nError:%@\nResponse:%@", _ardUserEmail, error, responseObject);
        }
        [expectUser fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error attempting to delete all-roles test user account %@: %@", _ardUserEmail, error);
        }
    }];
    
    [super tearDown];
}

- (void)tryGetScheduledActivitiesForDaysAhead:(NSInteger)daysAhead expectTasks:(XCTestExpectation *)expectTasks timeZoneString:(NSString *)tzStr
{
    [SBBComponent(SBBActivityManager) getScheduledActivitiesForDaysAhead:daysAhead withCompletion:^(SBBResourceList *tasksRList, NSError *error) {
        if (error) {
            NSLog(@"Error getting tasks for %@:\n%@", tzStr, error);
        }
        XCTAssert([tasksRList isKindOfClass:[SBBResourceList class]], "Server returned a resource list");
        if (tasksRList.items.count) {
            SBBScheduledActivity *task = tasksRList.items[0];
            XCTAssert([task isKindOfClass:[SBBScheduledActivity class]], "Server returned a list of ScheduledActivity objects");
        }
        NSInteger countMyActivities = 0;
        for (SBBScheduledActivity *task in tasksRList.items) {
            if ([task.activity.guid isEqualToString:_activityGuid]) {
                countMyActivities++;
            }
        }
        XCTAssert(countMyActivities == daysAhead + 1, "Server returned a list that actually contains one item from test schedule per day requested");
        
        [expectTasks fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error attempting to get tasks for %@: %@", tzStr, error);
        }
    }];
}

- (void)testGetScheduledActivitiesPST {
    NSTimeZone *originalTZ = [NSTimeZone systemTimeZone];
    
    NSInteger daysAhead = arc4random_uniform(5);
    
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-(3600*8)]];
    [NSTimeZone resetSystemTimeZone];
    XCTestExpectation *expectTasksPST = [self expectationWithDescription:@"got scheduled activities for PST"];
    [self tryGetScheduledActivitiesForDaysAhead:daysAhead expectTasks:expectTasksPST timeZoneString:[[NSTimeZone defaultTimeZone] name]];
    
    [NSTimeZone setDefaultTimeZone:originalTZ];
    [NSTimeZone resetSystemTimeZone];
}

- (void)testGetScheduledActivitiesGMT
{
    NSTimeZone *originalTZ = [NSTimeZone systemTimeZone];
    
    NSInteger daysAhead = arc4random_uniform(5);
    
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [NSTimeZone resetSystemTimeZone];
    XCTestExpectation *expectTasksGMT = [self expectationWithDescription:@"got scheduled activities for GMT"];
    [self tryGetScheduledActivitiesForDaysAhead:daysAhead expectTasks:expectTasksGMT timeZoneString:[[NSTimeZone defaultTimeZone] name]];
    
    [NSTimeZone setDefaultTimeZone:originalTZ];
    [NSTimeZone resetSystemTimeZone];
}

- (void)testGetScheduledActivitiesHK
{
    NSTimeZone *originalTZ = [NSTimeZone systemTimeZone];
    
    NSInteger daysAhead = arc4random_uniform(5);
    
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:(3600*8)]];
    [NSTimeZone resetSystemTimeZone];
    XCTestExpectation *expectTasksHK = [self expectationWithDescription:@"got scheduled activities for HK"];
    [self tryGetScheduledActivitiesForDaysAhead:daysAhead expectTasks:expectTasksHK timeZoneString:[[NSTimeZone defaultTimeZone] name]];
    
    [NSTimeZone setDefaultTimeZone:originalTZ];
    [NSTimeZone resetSystemTimeZone];
}

- (void)createTestSchedule:(NSDictionary *)schedule completionHandler:(SBBNetworkManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [_aMan addAuthHeaderToHeaders:headers];
    [SBBComponent(SBBNetworkManager) post:TASKS_ADMIN_API headers:headers parameters:schedule completion:completion];
}

- (void)deleteSchedule:(NSString *)guid completionHandler:(SBBNetworkManagerCompletionBlock)completion
{
    NSString *deleteScheduleFormat = TASKS_ADMIN_API @"/%@";
    NSString *deleteSchedule = [NSString stringWithFormat:deleteScheduleFormat, guid];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [_aMan addAuthHeaderToHeaders:headers];
    [SBBComponent(SBBNetworkManager) delete:deleteSchedule headers:headers parameters:nil completion:completion];
}

- (void)readSchedule:(NSString *)guid completionHandler:(SBBNetworkManagerCompletionBlock)completion
{
    NSString *readScheduleFormat = TASKS_ADMIN_API @"/%@";
    NSString *readSchedule = [NSString stringWithFormat:readScheduleFormat, guid];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [_aMan addAuthHeaderToHeaders:headers];
    [SBBComponent(SBBNetworkManager) get:readSchedule headers:headers parameters:nil completion:completion];
}


@end
