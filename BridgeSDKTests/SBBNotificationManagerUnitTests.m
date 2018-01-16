//
//  SBBNotificationManagerUnitTests.m
//  BridgeSDKTests
//
//  Created by Erin Mounts on 1/15/18.
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"

@interface SBBNotificationManagerUnitTests : SBBBridgeAPIUnitTestCase

@property (nonatomic, strong) NSDictionary *subscriptionStatusesNoneSubscribed;
@property (nonatomic, strong) NSDictionary *subscriptionStatusesSomeSubscribed;

@end

@implementation SBBNotificationManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.subscriptionStatusesNoneSubscribed =
    @{
      @"type": @"SubscriptionStatusList",
      @"items": @[
              @{
                  @"type": @"SubscriptionStatus",
                  @"subscribed": @NO,
                  @"topicName": @"topic1",
                  @"topicGuid": @"topic1guid"
                  },
              @{
                  @"type": @"SubscriptionStatus",
                  @"subscribed": @NO,
                  @"topicName": @"topic2",
                  @"topicGuid": @"topic2guid"
                  },
              @{
                  @"type": @"SubscriptionStatus",
                  @"subscribed": @NO,
                  @"topicName": @"topic3",
                  @"topicGuid": @"topic3guid"
                  }
              ]
      };
    
    self.subscriptionStatusesSomeSubscribed =
    @{
      @"type": @"SubscriptionStatusList",
      @"items": @[
              @{
                  @"type": @"SubscriptionStatus",
                  @"subscribed": @NO,
                  @"topicName": @"topic1",
                  @"topicGuid": @"topic1guid"
                  },
              @{
                  @"type": @"SubscriptionStatus",
                  @"subscribed": @YES,
                  @"topicName": @"topic2",
                  @"topicGuid": @"topic2guid"
                  },
              @{
                  @"type": @"SubscriptionStatus",
                  @"subscribed": @YES,
                  @"topicName": @"topic3",
                  @"topicGuid": @"topic3guid"
                  }
              ]
      };
    

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegister {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testUnregister {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testGetSubscriptionStatuses {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testSubscribeToTopicGuids {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
