//
//  SBBAuthManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBTestAuthManagerDelegate.h"
#import "SBBNetworkManagerInternal.h"
#import "MockNetworkManager.h"
#import "MockURLSession.h"
#import "SBBUserManagerInternal.h"

@interface SBBAuthManagerUnitTests : SBBBridgeAPIUnitTestCase

@property (nonatomic, strong) MockNetworkManager *mockNetworkManager;

@end

@implementation SBBAuthManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.mockNetworkManager = [[MockNetworkManager alloc] init];
    [SBBComponentManager registerComponent:_mockNetworkManager forClass:[SBBNetworkManager class]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSignIn {
    [self.mockNetworkManager setJson:nil andResponseCode:404 forEndpoint:kSBBAuthSignInAPI andMethod:@"POST"];
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];
    // always use an auth delegate so we don't pollute the keychain for integration tests
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    aMan.authDelegate = delegate;
    [aMan signInWithEmail:@"notSignedUp" password:@"" completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == 404, @"Invalid credentials test");
    }];
    
    NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *email = @"signedUpUser";
    NSDictionary *sessionInfoJson = @{@"email": email,
                                      @"sessionToken": uuid,
                                      @"type": @"UserSessionInfo",
                                      @"consented": @NO,
                                      @"authenticated":@YES};
    
    SBBUserSessionInfo *sessionInfo = [SBBComponent(SBBObjectManager) objectFromBridgeJSON:sessionInfoJson];
    [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:kSBBAuthSignInAPI andMethod:@"POST"];
    [aMan signInWithEmail:@"signedUpUser" password:@"123456" completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == SBBErrorCodeServerPreconditionNotMet && responseObject == sessionInfoJson, @"Valid credentials, no consent test");
        XCTAssert([delegate.sessionToken isEqualToString:uuid], @"Delegate received sessionToken");
        XCTAssertEqualObjects(delegate.sessionInfo, sessionInfo, @"Expected sessionInfo to be:\n%@ but got:\n%@", sessionInfo, delegate.sessionInfo);
        XCTAssertEqualObjects(sessionInfo.studyParticipant.email, email, @"Expected sessionInfo.studyParticipant.email to be %@ but got %@", email, sessionInfo.studyParticipant.email);
    }];
}

- (void)testEnsureSignedIn
{
    NSString *sessionToken = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *email = @"signedUpUser";
    NSString *password = @"123456";
    NSDictionary *sessionInfoJson = @{@"email": email,
                                      @"sessionToken": sessionToken,
                                      @"type": @"UserSessionInfo",
                                      @"consented": @NO,
                                      @"authenticated":@YES};
    [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:kSBBAuthSignInAPI andMethod:@"POST"];
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];
    
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    aMan.authDelegate = delegate;
    
    // first try it with no saved credentials
    [aMan ensureSignedInWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert(error.code == SBBErrorCodeNoCredentialsAvailable, @"Correct error when no credentials available");
        XCTAssert(delegate.sessionToken == nil, @"Did not attempt to call signIn endpoint without credentials");
    }];
    
    // now try it with saved username/password
    delegate.email = email;
    delegate.password = password;
    [aMan ensureSignedInWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert([delegate.sessionToken isEqualToString:sessionToken], @"Delegate received sessionToken");
    }];
    
    // now try it with already-saved sessionToken
    [aMan ensureSignedInWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert(!task && !responseObject && !error, @"Seen as already signed in, did not attempt to sign in again");
    }];
}

- (void)testAutoRenew
{
    // set up mock credentials for the auth manager to auto-renew with
    NSString *sessionToken = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *email = @"signedUpUser";
    NSString *password = @"123456";
    NSDictionary *sessionInfoJson = @{@"email": email,
                                      @"sessionToken": sessionToken,
                                      @"type": @"UserSessionInfo",
                                      @"consented": @NO,
                                      @"authenticated":@YES};
    [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:kSBBAuthSignInAPI andMethod:@"POST"];
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];
    
    // set up the auth delegate with the mock credentials
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    delegate.email = email;
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
      @"email": @"email@fake.tld"
      };
    [mockURLSession setJson:userProfile andResponseCode:200 forEndpoint:kSBBUserProfileAPI andMethod:@"GET"];
    SBBUserManager *uMan = [SBBUserManager managerWithAuthManager:aMan networkManager:bridgeNetMan objectManager:self.objectManager];
    [self.objectManager setupMappingForType:@"UserProfile" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"email": @"stringField"}];
    [uMan getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        XCTAssert([delegate.sessionToken isEqualToString:sessionToken], @"Delegate received sessionToken");
        XCTAssert([userProfile isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
    }];
}

@end
