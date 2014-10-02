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

- (void)testAuthManagerSignIn {
  [_mockNetworkManager setJson:nil andResponseCode:404 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];
  SBBAuthManager *aMan = (SBBAuthManager *)SBBComponent(SBBAuthManager);
  [aMan signInWithUsername:@"notSignedUp" password:@"" completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == 404, @"Invalid credentials test");
  }];
  
  NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSDictionary *sessionInfoJson = @{@"username": @"signedUpUser",
                                    @"sessionToken": uuid,
                                    @"type": @"UserSessionInfo",
                                    @"consented": @NO,
                                    @"authenticated":@YES};
  [_mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];
  [aMan signInWithUsername:@"signedUpUser" password:@"123456" completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == kSBBServerPreconditionNotMet && responseObject == sessionInfoJson, @"Valid credentials, no consent test");
    [aMan clearKeychainStore];
  }];
  
  SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
  aMan.authDelegate = delegate;
  [aMan signInWithUsername:@"signedUpUser" password:@"123456" completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert([delegate.sessionToken isEqualToString:uuid], @"Delegate received sessionToken");
  }];
}

- (void)testAuthManagerEnsureSignedIn
{
  SBBAuthManager *aMan = (SBBAuthManager *)SBBComponent(SBBAuthManager);
  NSString *sessionToken = [[NSProcessInfo processInfo] globallyUniqueString];
  NSString *username = @"signedUpUser";
  NSString *password = @"123456";
  NSDictionary *sessionInfoJson = @{@"username": username,
                                    @"sessionToken": sessionToken,
                                    @"type": @"UserSessionInfo",
                                    @"consented": @NO,
                                    @"authenticated":@YES};
  [_mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];

  SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
  aMan.authDelegate = delegate;
  
  // first try it with no saved credentials
  [aMan ensureSignedInWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert(error.code == kSBBNoCredentialsAvailable, @"Correct error when no credentials available");
    XCTAssert(delegate.sessionToken == nil, @"Did not attempt to call signIn endpoint without credentials");
  }];
  
  // now try it with saved username/password
  delegate.username = username;
  delegate.password = password;
  [aMan ensureSignedInWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert([delegate.sessionToken isEqualToString:sessionToken], @"Delegate received sessionToken");
  }];
  
  // now try it with already-saved sessionToken
  [aMan ensureSignedInWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert(!task && !responseObject && !error, @"Seen as already signed in, did not attempt to sign in again");
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
