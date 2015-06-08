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
#import "SBBNetworkManagerInternal.h"
#import "MockNetworkManager.h"
#import "MockURLSession.h"

@interface SBBAuthManagerTests : SBBBridgeAPITestCase

@property (nonatomic, strong) MockNetworkManager *mockNetworkManager;

@end

@implementation SBBAuthManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.mockNetworkManager = [[MockNetworkManager alloc] init];
    [SBBComponentManager registerComponent:_mockNetworkManager forClass:[SBBNetworkManager class]];
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

- (void)testAutoRenew
{
    // set up mock credentials for the auth manager to auto-renew with
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
    
    // set up the auth delegate with the mock credentials
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    delegate.username = username;
    delegate.password = password;
    aMan.authDelegate = delegate;
    
    // this tells the mock URL session created below to return a 401 status code, which will trigger the auto-renew logic in SBBBridgeNetworkManager;
    // once the renewed session token is received (as set up above), the original Bridge call will be retried and should now complete as specified
    NSString *expiredToken = @"expired";
    [aMan setSessionToken:expiredToken];
    
    // now hit an arbitrary Bridge endpoint, and ensure that it auto-renews the session token and successfully retries
    MockURLSession *mockURLSession = [MockURLSession new];
    SBBBridgeNetworkManager *bridgeNetMan = [[SBBBridgeNetworkManager alloc] initWithAuthManager:aMan];
    bridgeNetMan.mainSession = mockURLSession;

    // ("arbitrary" in this case being the user profile endpoint)
    NSDictionary *userProfile =
    @{
      @"type": @"UserProfile",
      @"firstName": @"First",
      @"lastName": @"Last",
      @"username": @"1337p4t13nt",
      @"email": @"email@fake.tld"
      };
    [mockURLSession setJson:userProfile andResponseCode:200 forEndpoint:@"/api/v1/profile" andMethod:@"GET"];
    SBBObjectManager *oMan = [SBBObjectManager objectManager];
    SBBProfileManager *pMan = [SBBProfileManager managerWithAuthManager:aMan networkManager:bridgeNetMan objectManager:oMan];
    [oMan setupMappingForType:@"UserProfile" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"username": @"stringField"}];
    [pMan getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        XCTAssert([delegate.sessionToken isEqualToString:sessionToken], @"Delegate received sessionToken");
        XCTAssert([userProfile isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
    }];
}

@end
