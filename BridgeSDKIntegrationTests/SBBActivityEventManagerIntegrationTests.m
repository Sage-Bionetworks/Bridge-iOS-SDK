//
//  SBBActivityEventManagerIntegrationTests.m
//  BridgeSDKIntegrationTests
//
//  Created by Erin Mounts on 8/19/18.
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBComponentManager.h"
#import "SBBActivityEventManager.h"
#import "SBBActivityEvent.h"

@interface SBBActivityEventManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBActivityEventManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)addActivityEvent:(NSString *)eventKey timestamp:(NSDate *)timestamp
{
    XCTestExpectation *expectAddedEvent = [self expectationWithDescription:@"Added activity event"];
    [SBBComponent(SBBActivityEventManager) createActivityEvent:eventKey withTimestamp:timestamp completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssertNil(error, @"Unexpected network/server error creating activity event: %@", error);
        [expectAddedEvent fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to create activity event:\n%@", error);
        }
    }];
}

- (void)testCreateActivityEvent {
    [self addActivityEvent:@"test-event-1" timestamp:[NSDate date]];
}

/* TODO: un-comment test when object type name is sorted out
- (void)testGetActivityEvents {
    NSDate *now = [NSDate date];
    
    // set up one that's a duplicate to make sure we only get one back per key
    NSArray *eventsToSetUpForRetrieval = @[
                                           @{ @"eventKey": @"test-event-1", @"timestamp": now },
                                           @{ @"eventKey": @"test-event-2", @"timestamp": [now dateByAddingTimeInterval:-1.0] },
                                           @{ @"eventKey": @"test-event-3", @"timestamp": [now dateByAddingTimeInterval:-2.0] },
                                           @{ @"eventKey": @"test-event-3", @"timestamp": [now dateByAddingTimeInterval:-3.0] }
                                           ];
    for (NSDictionary *eventInfo in eventsToSetUpForRetrieval) {
        [self addActivityEvent:eventInfo[@"eventKey"] timestamp:eventInfo[@"timestamp"]];
    }
    
    // ok now go get 'em
    XCTestExpectation *expectGotActivityEvents = [self expectationWithDescription:@"Got activity events"];
    [SBBComponent(SBBActivityEventManager) getActivityEvents:^(NSArray * _Nullable activityEventsList, NSError * _Nullable error) {
        XCTAssertNil(error, @"Unexpected network/server error getting activity events: %@", error);
        XCTAssert(activityEventsList.count == eventsToSetUpForRetrieval.count - 1, @"Expected to get back %ld events but got %ld instead", eventsToSetUpForRetrieval.count - 1, activityEventsList.count);
        [expectGotActivityEvents fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to get activity events:\n%@", error);
        }
    }];
}
 */

@end
