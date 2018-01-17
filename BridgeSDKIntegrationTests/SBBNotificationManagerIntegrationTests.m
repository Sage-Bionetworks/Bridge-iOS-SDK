//
//  SBBNotificationManagerIntegrationTests.m
//  BridgeSDKIntegrationTests
//
//  Created by Erin Mounts on 1/16/18.
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBComponent.h"
#import "SBBNotificationManager.h"
#import "SBBCacheManager.h"
#import "ModelObjectInternal.h"

@interface SBBNotificationManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@property (nonatomic, strong) NSData *deviceToken;

@property (nonatomic, strong) NSString *topic1Guid;
@property (nonatomic, strong) NSString *topic2Guid;
@property (nonatomic, strong) NSString *topic3Guid;

@property (nonatomic, strong) NSArray<NSString *> *subscribeTopicGuids;

@end

@implementation SBBNotificationManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSString *base64Token = @"ZRrf9x0vPr1SxFJu/wGNM9DoH5gUVrTmvk6cwZNBmjk=";
    self.deviceToken = [[NSData alloc] initWithBase64EncodedString:base64Token options:0];
    
    self.topic1Guid = @"7c980f61-f878-45e4-9d52-ef3032638ef4";
    self.topic2Guid = @"05c9f286-b922-4118-992e-cd3a3634592c";
    self.topic3Guid = @"103f6f8d-36f1-4104-b0bb-372e77e7795e";
    
    self.subscribeTopicGuids = @[
                                 self.topic1Guid,
                                 self.topic3Guid
                                 ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)register {
    XCTestExpectation *expectRegistered = [self expectationWithDescription:@"Registered remote notifications device token with Bridge"];
    [SBBComponent(SBBNotificationManager) registerWithDeviceToken:self.deviceToken completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssertNil(error, @"Error registering device token: %@", error);
        if (!error) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            NSString *type = responseDict[NSStringFromSelector(@selector(type))];
            XCTAssertEqualObjects(type, SBBGuidHolder.entityName, @"Expected to get response JSON with type %@ but got %@ instead", SBBGuidHolder.entityName, type);
            NSString *guid = responseDict[NSStringFromSelector(@selector(guid))];
            XCTAssertNotNil(guid, @"Expected to get a guid in the response but did not:\n%@", responseObject);
        }
        [expectRegistered fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout registering remote notifications device token with Bridge: %@", error);
        }
    }];
}

- (void)unregister {
    XCTestExpectation *expectUnregistered = [self expectationWithDescription:@"Unregistered for remote notifications from Bridge"];
    
    [SBBComponent(SBBNotificationManager) unregisterWithCompletion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssertNil(error, @"Error unregistering for remote notifications: %@", error);
        [expectUnregistered fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout unregistering for remote notifications from Bridge: %@", error);
        }
    }];
}

- (void)testRegisterUnregister {
    [self register];
    [self unregister];
}

- (void)testGetSubscriptionStatuses {
    [self register];
    @try {
        XCTestExpectation *expectGotStatuses = [self expectationWithDescription:@"Got subscription statuses from Bridge"];
        
        [SBBComponent(SBBNotificationManager) getSubscriptionStatuses:^(NSArray * _Nullable statusList, NSArray<NSString *> * _Nullable subscribedGuids, NSError * _Nullable error) {
            XCTAssertNil(error, @"Error getting subscription statuses: %@", error);
            XCTAssert(statusList.count == 3, @"Expected 3 topic statuses, got %lu", statusList.count);
            [expectGotStatuses fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Timeout getting subscription statuses from Bridge: %@", error);
            }
        }];
    } @catch (NSException *exception) {
        XCTAssert(NO, @"Exception caught in testGetSubscriptionStatuses:\n%@", exception);
    } @finally {
        [self unregister];
    }
}

- (void)testSubscribeToTopicGuids {
    [self register];
    @try {
        XCTestExpectation *expectSubscribed = [self expectationWithDescription:@"Subscribed to topics"];
        
        [SBBComponent(SBBNotificationManager) subscribeToTopicGuids:self.subscribeTopicGuids completion:^(NSArray * _Nullable statusList, NSArray<NSString *> * _Nullable subscribedGuids, NSError * _Nullable error) {
            XCTAssertNil(error, @"Error subscribing to topics: %@", error);
            XCTAssert(statusList.count == 3, @"Expected 3 topic statuses, got %lu", statusList.count);
            XCTAssert(subscribedGuids.count == 2, @"Expected 2 subscribed guids, got %lu", subscribedGuids.count);
            
            NSSet<NSString *> *toBeSubscribed = [NSSet setWithArray:self.subscribeTopicGuids];
            NSSet<NSString *> *didSubscribe = [NSSet setWithArray:subscribedGuids];
            XCTAssertEqualObjects(toBeSubscribed, didSubscribe, @"Expected to have subscribed to %@ but got %@", toBeSubscribed, didSubscribe);
            [expectSubscribed fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Timeout subscribing to topics: %@", error);
            }
        }];
    } @catch (NSException *exception) {
        XCTAssert(NO, @"Exception caught in testSubscribeToTopicGuids:\n%@", exception);
    } @finally {
        [self unregister];
    }
}

@end
