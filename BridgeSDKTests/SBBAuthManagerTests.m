//
//  SBBAuthManagerTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPITestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBTestAuthManagerDelegate.h"

@interface SBBAuthManagerTests : SBBBridgeAPITestCase

@end

@implementation SBBAuthManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    gSBBAppStudy = @"test";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    gSBBAppStudy = nil;
}

- (void)testSignIn {
  [self.mockNetworkManager setJson:nil andResponseCode:404 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];
  SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];
  [aMan signInWithUsername:@"notSignedUp" password:@"" completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == 404, @"Invalid credentials test");
  }];
  
  NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSDictionary *sessionInfoJson = @{@"username": @"signedUpUser",
                                    @"sessionToken": uuid,
                                    @"type": @"UserSessionInfo",
                                    @"consented": @NO,
                                    @"authenticated":@YES};
  [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];
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

- (void)testEnsureSignedIn
{
  NSString *sessionToken = [[NSProcessInfo processInfo] globallyUniqueString];
  NSString *username = @"signedUpUser";
  NSString *password = @"123456";
  NSDictionary *sessionInfoJson = @{@"username": username,
                                    @"sessionToken": sessionToken,
                                    @"type": @"UserSessionInfo",
                                    @"consented": @NO,
                                    @"authenticated":@YES};
  [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:@"/api/v1/auth/signIn" andMethod:@"POST"];
  SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];

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

@end
