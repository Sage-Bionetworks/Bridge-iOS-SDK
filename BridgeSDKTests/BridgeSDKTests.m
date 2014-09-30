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
#import "MockNetworkManager.h"
#import "SBBTestBridgeObject.h"

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
    [SBBComponentManager registerComponent:_mockNetworkManager forClass:[SBBNetworkManager class]];
  });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAuthManagerSignIn {
  [_mockNetworkManager setJson:nil andResponseCode:404 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];
  [SBBComponent(SBBAuthManager) signInWithUsername:@"notSignedUp" password:@"" completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == 404, @"Invalid credentials test");
  }];
  
  NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSDictionary *sessionInfoJson = @{@"username": @"signedUpUser",
                                    @"sessionToken": uuid,
                                    @"type": @"UserSessionInfo",
                                    @"consented": @NO,
                                    @"authenticated":@YES};
  [_mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];
  [SBBComponent(SBBAuthManager) signInWithUsername:@"signedUpUser" password:@"123456" completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == kSBBServerPreconditionNotMet && responseObject == sessionInfoJson, @"Valid credentials, no consent test");
  }];
}

- (void)testProfileManagerGet
{
  NSDictionary *userProfile =
  @{
    @"type": @"UserProfile",
    @"firstName": @"First",
    @"lastName": @"Last",
    @"username": @"1337p4t13nt",
    @"email": @"email@fake.tld"
    };
  [_mockNetworkManager setJson:userProfile andResponseCode:200 forEndpoint:@"/api/v1/profile" andMethod:@"GET"];
  SBBObjectManager *oMan = [SBBObjectManager objectManager];
  SBBProfileManager *pMan = [SBBProfileManager profileManagerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:_mockNetworkManager objectManager:oMan];
  [oMan setupMappingForType:@"UserProfile" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"username": @"stringField"}];
  [pMan getUserProfileWithCompletion:^(id userProfile, NSError *error) {
    XCTAssert([userProfile isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
  }];
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
