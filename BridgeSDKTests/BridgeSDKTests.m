//
//  BridgeSDKTests.m
//  BridgeSDKTests
//
//  Created by Erin Mounts on 9/8/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
@import BridgeSDK;
#import "SBBAuthManagerInternal.h"
#import "MockNetworkManager.h"
#import "SBBTestBridgeObject.h"
#import "SBBTestAuthManagerDelegate.h"

@interface BridgeSDKTests : XCTestCase

@property (nonatomic, strong) MockNetworkManager *mockNetworkManager;

@end

@implementation BridgeSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  
  // The first time this is run, register our mock network manager.
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _mockNetworkManager = [[MockNetworkManager alloc] init];
  });
  
  [SBBComponentManager registerComponent:_mockNetworkManager forClass:[SBBNetworkManager class]];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
  [SBBComponentManager reset];
}


//- (void)testProfileManagerUpdate
//{
//  
//}
//
//- (void)testConsentManagerConsent
//{
//  
//}
//
//- (void)testConsentManagerSuspend
//{
//  
//}
//
//- (void)testConsentManagerResume
//{
//  
//}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
