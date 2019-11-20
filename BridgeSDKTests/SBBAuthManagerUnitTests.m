//
//  SBBAuthManagerUnitTests.m
//  BridgeSDK
//
//  Copyright (c) 2014-2018 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBTestAuthKeychainManager.h"
#import "SBBNetworkManagerInternal.h"
#import "MockNetworkManager.h"
#import "MockURLSession.h"
#import "SBBStudyManagerInternal.h"
#import "ModelObjectInternal.h"
#import "SBBCacheManager.h"

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

- (void)resetStateOfAuthManager:(SBBAuthManager *)aMan {
    // always use a test auth keychain manager so we don't pollute the real keychain for integration tests
    aMan.keychainManager = [SBBTestAuthKeychainManager new];
    
    XCTestExpectation *expectSessionUpdate = [self expectationWithDescription:@"got session updated notification after reset"];
    __block id<NSObject> observer = [[NSNotificationCenter defaultCenter] addObserverForName:kSBBUserSessionUpdatedNotification object:aMan queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:kSBBUserSessionUpdatedNotification object:aMan];
        [expectSessionUpdate fulfill];
    }];
    
    dispatchSyncToAuthAttemptQueue(^{
        [aMan resetAuthStateIncludingCredential:YES];
    });

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error waiting for session info update notification after reset:\n%@", error);
        }
    }];
    
    [aMan clearSessionToken];
}

- (void)testSignIn {
    [self.mockNetworkManager setJson:nil andResponseCode:404 forEndpoint:kSBBAuthSignInAPI andMethod:@"POST"];
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];
    [self resetStateOfAuthManager:aMan];
    [aMan signInWithEmail:@"notSignedUp" password:@"" completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == 404, @"Invalid credentials test");
    }];
    
    NSString *sessionUuid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *reauthUuid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *email = @"signedUpUser";
    NSString *password = @"123456";
    NSDictionary *sessionInfoJson = @{NSStringFromSelector(@selector(email)): email,
                                      NSStringFromSelector(@selector(sessionToken)): sessionUuid,
                                      NSStringFromSelector(@selector(reauthToken)): reauthUuid,
                                      NSStringFromSelector(@selector(type)): SBBUserSessionInfo.entityName,
                                      NSStringFromSelector(@selector(consented)): @NO,
                                      NSStringFromSelector(@selector(authenticated)):@YES};
    
    SBBUserSessionInfo *sessionInfo = [SBBComponent(SBBObjectManager) objectFromBridgeJSON:sessionInfoJson];
    [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:kSBBAuthSignInAPI andMethod:@"POST"];
    [self resetStateOfAuthManager:aMan];
    XCTestExpectation *expectSessionUpdate = [self expectationWithDescription:@"got session updated notification"];
    __block SBBUserSessionInfo *newSessionInfo = nil;
    __block id<NSObject> observer = [[NSNotificationCenter defaultCenter] addObserverForName:kSBBUserSessionUpdatedNotification object:aMan queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        newSessionInfo = note.userInfo[kSBBUserSessionInfoKey];
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:kSBBUserSessionUpdatedNotification object:aMan];
        [expectSessionUpdate fulfill];
    }];
    
    XCTestExpectation *expectSignedIn = [self expectationWithDescription:@"signed in"];
    __block NSError *signInError = nil;
    __block id signInResponse = nil;
    [aMan signInWithEmail:email password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        signInError = error;
        signInResponse = responseObject;
        [expectSignedIn fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to sign in to test account or waiting for session info update notification:\n%@", error);
        }
    }];

    XCTAssert([signInError.domain isEqualToString:SBB_ERROR_DOMAIN] && signInError.code == SBBErrorCodeServerPreconditionNotMet && signInResponse == sessionInfoJson, @"Valid credentials, no consent test");
    XCTAssert([newSessionInfo.sessionToken isEqualToString:sessionUuid], @"Expected updated sessionToken from notificaiont to be %@ but it's %@", sessionUuid, newSessionInfo.sessionToken);
    XCTAssert(aMan.savedReauthToken == reauthUuid, @"Expected auth manager's saved reauth token to be %@ but it's %@", reauthUuid, aMan.savedReauthToken);
    XCTAssert(aMan.savedPassword == password, @"Expected auth manager's saved password to be %@ but it's %@", password, aMan.savedPassword);
    XCTAssertEqualObjects(newSessionInfo.dictionaryRepresentation, sessionInfo.dictionaryRepresentation, @"Expected sessionInfo to be:\n%@ but got:\n%@", sessionInfo, newSessionInfo);
    XCTAssertEqualObjects(newSessionInfo.studyParticipant.email, email, @"Expected sessionInfo.studyParticipant.email to be %@ but got %@", email, sessionInfo.studyParticipant.email);

}

- (void)testEnsureSignedIn
{
    NSString *sessionToken = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *reauthToken = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *email = @"signedUpUser";
    NSString *password = @"123456";
    NSDictionary *sessionInfoJson = @{NSStringFromSelector(@selector(email)): email,
                                      NSStringFromSelector(@selector(emailVerified)): @YES,
                                      NSStringFromSelector(@selector(sessionToken)): sessionToken,
                                      NSStringFromSelector(@selector(reauthToken)): reauthToken,
                                      NSStringFromSelector(@selector(type)): SBBUserSessionInfo.entityName,
                                      NSStringFromSelector(@selector(consented)): @NO,
                                      NSStringFromSelector(@selector(authenticated)):@YES};
    [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:kSBBAuthSignInAPI andMethod:@"POST"];
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];
    [self resetStateOfAuthManager:aMan];

    // first try it with no saved credentials
    XCTestExpectation *expectNotSignedIn = [self expectationWithDescription:@"not signed in (no saved credentials)"];
    __block NSError *signInError = nil;
    __block id signInResponse = nil;
    [aMan ensureSignedInWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        signInError = error;
        signInResponse = responseObject;
        [expectNotSignedIn fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to ensure not signed in to test account (no saved credentials):\n%@", error);
        }
    }];

    XCTAssert(signInError.code == SBBErrorCodeNoCredentialsAvailable, @"Expected error code to be %ld but got %ld instead", (long)SBBErrorCodeNoCredentialsAvailable, (long)signInError.code);
    XCTAssert(signInResponse == nil, @"Did not attempt to call signIn endpoint without credentials");

    // now try it with saved email/password
    [self resetStateOfAuthManager:aMan];
    [aMan.keychainManager setKeysAndValues:@{ aMan.passwordKey: password }];
    aMan.placeholderSessionInfo.studyParticipant.email = email;
    aMan.placeholderSessionInfo.studyParticipant.emailVerifiedValue = YES;
    XCTestExpectation *expectSessionUpdate = [self expectationWithDescription:@"got session updated notification"];
    __block SBBUserSessionInfo *newSessionInfo = nil;
    __block id<NSObject> observer = [[NSNotificationCenter defaultCenter] addObserverForName:kSBBUserSessionUpdatedNotification object:aMan queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        newSessionInfo = note.userInfo[kSBBUserSessionInfoKey];
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:kSBBUserSessionUpdatedNotification object:aMan];
        [expectSessionUpdate fulfill];
    }];
    
    XCTestExpectation *expectSignedIn = [self expectationWithDescription:@"signed in"];
    [aMan ensureSignedInWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        signInError = error;
        signInResponse = responseObject;
        [expectSignedIn fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to ensure signed in to test account (saved credentials) or waiting for session info update notification:\n%@", error);
        }
    }];

    XCTAssert([newSessionInfo.sessionToken isEqualToString:sessionToken], @"Expected updated info from notification to have sessionToken %@, but got %@ instead", sessionToken, newSessionInfo.sessionToken);
    XCTAssert([aMan.savedReauthToken isEqualToString:reauthToken], @"Expected auth manager to have reauthToken %@, but got %@ instead", reauthToken, aMan.savedReauthToken);

    // now try it with already-saved sessionToken
    [aMan ensureSignedInWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert(!task && !responseObject && !error, @"Seen as already signed in, did not attempt to sign in again");
    }];
}

- (void)testAutoRenew
{
    // set up mock credentials for the auth manager to auto-renew with
    NSString *sessionToken = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *reauthToken = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *email = @"signedUpUser";
    NSDictionary *sessionInfoJson = @{NSStringFromSelector(@selector(email)): email,
                                      NSStringFromSelector(@selector(emailVerified)): @YES,
                                      NSStringFromSelector(@selector(sessionToken)): sessionToken,
                                      NSStringFromSelector(@selector(reauthToken)): reauthToken,
                                      NSStringFromSelector(@selector(type)): SBBUserSessionInfo.entityName,
                                      NSStringFromSelector(@selector(consented)): @NO,
                                      NSStringFromSelector(@selector(authenticated)):@YES};
    [self.mockNetworkManager setJson:sessionInfoJson andResponseCode:412 forEndpoint:kSBBAuthReauthAPI andMethod:@"POST"];
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:self.mockNetworkManager];
    [self resetStateOfAuthManager:aMan];

    // set up the auth manager with mock credentials
    NSString *initialReauthToken = [[NSProcessInfo processInfo] globallyUniqueString];
    aMan.placeholderSessionInfo.studyParticipant.email = email;
    aMan.placeholderSessionInfo.studyParticipant.emailVerifiedValue = YES;
    [aMan.keychainManager setKeysAndValues:@{ aMan.reauthTokenKey: initialReauthToken }];
    
    // this tells the mock URL session created below to return a 401 status code, which will trigger the auto-renew logic in SBBBridgeNetworkManager;
    // once the renewed session token is received (as set up above), the original Bridge call will be retried and should now complete as specified
    NSString *expiredToken = @"expired";
    aMan.placeholderSessionInfo.sessionToken = expiredToken;
    [aMan setSessionToken:expiredToken];
    
    // now hit an arbitrary Bridge endpoint, and ensure that it auto-renews the session token and successfully retries
    MockURLSession *mockURLSession = [MockURLSession new];
    SBBBridgeNetworkManager *bridgeNetMan = [[SBBBridgeNetworkManager alloc] initWithAuthManager:aMan];
    bridgeNetMan.mainSession = mockURLSession;
    
    // ("arbitrary" in this case being the study manager app config endpoint)
    NSDictionary *appConfig =
    @{
      NSStringFromSelector(@selector(type)): SBBAppConfig.entityName,
      NSStringFromSelector(@selector(clientData)): @"Client data",
      };
    
    NSString *studyId = SBBBridgeInfo.shared.studyIdentifier;
    NSString *endpoint = [NSString stringWithFormat:kSBBStudyAPIFormat, studyId];
    [mockURLSession setJson:appConfig andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    SBBStudyManager *sMan = [SBBStudyManager managerWithAuthManager:aMan networkManager:bridgeNetMan objectManager:self.objectManager];
    [self.objectManager setupMappingForType:SBBAppConfig.entityName toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"clientData": @"stringField"}];
    XCTestExpectation *expectGotAppConfig = [self expectationWithDescription:@"Got appConfig"];
    __block id gotAppConfig;
    __block NSError *gotError;
    [sMan getAppConfigWithCompletion:^(id appConfig, NSError *error) {
        gotAppConfig = appConfig;
        gotError = error;
        [expectGotAppConfig fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to auto-renew with reauthToken and load appConfig:\n%@", error);
        }
    }];
    
    XCTAssert([aMan.sessionToken isEqualToString:sessionToken], @"Expected authManager's sessionToken to be %@, but instead it's %@", sessionToken, aMan.sessionToken);
    XCTAssert([gotAppConfig isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
    SBBStudyParticipant *participant = (SBBStudyParticipant *)[aMan.cacheManager cachedSingletonObjectOfType:@"StudyParticipant" createIfMissing:NO];
    XCTAssert(participant.email = email, @"Expected cached study participant email to be %@, but it's %@", email, participant.email);

    // now set up the network manager to return a 404 on reauth attempt
    // this would happen if e.g. there's no account with the given identifier, or the reauthToken is bad
    NSDictionary *failedSessionInfoJson = @{
                                      @"statusCode": @404,
                                      @"message": @"Account not found.",
                                      @"entityClass": @"Account",
                                      @"type": @"EntityNotFoundException"
                                      };
    [self.mockNetworkManager setJson:failedSessionInfoJson andResponseCode:404 forEndpoint:kSBBAuthReauthAPI andMethod:@"POST"];

    // once again tell the mock URL session created below to return a 401 status code, which will trigger the auto-renew logic in SBBBridgeNetworkManager;
    // when that throws a 404, there's nothing further we can do without participant intervention, so the original request should be abandoned.
    aMan.placeholderSessionInfo.sessionToken = expiredToken;
    [aMan setSessionToken:expiredToken];
    
    // now hit that arbitrary Bridge endpoint again, and ensure that it fails to renew the session token and gives up
    mockURLSession = [MockURLSession new];
    bridgeNetMan.mainSession = mockURLSession;
    
    [mockURLSession setJson:appConfig andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    XCTestExpectation *expectDidntGetAppConfig = [self expectationWithDescription:@"Didn't get appConfig"];
    gotAppConfig = nil;
    gotError = nil;
    [sMan getAppConfigWithCompletion:^(id appConfig, NSError *error) {
        gotAppConfig = appConfig;
        gotError = error;
        [expectDidntGetAppConfig fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to fail to auto-renew with reauthToken:\n%@", error);
        }
    }];
    
    XCTAssertNil(aMan.sessionToken, @"Expected authManager's sessionToken to be nil, but instead it's %@", aMan.sessionToken);
    XCTAssert(gotAppConfig == nil, @"Expected to abandon the original request, but instead got %@", gotAppConfig);
    
    // When the reauth attempt failed due to the 404, it would fall back to trying to
    // use stored credentials; since we haven't set those up, it should get this error:
    XCTAssert(gotError.code == SBBErrorCodeNoCredentialsAvailable, @"Expected to get a no credentials available error but instead got %@", gotError);
    
    // Double-check that the cached StudyParticipant has been cleared out as well
    participant = (SBBStudyParticipant *)[aMan.cacheManager cachedSingletonObjectOfType:@"StudyParticipant" createIfMissing:NO];
    XCTAssertNil(participant, @"Expected cached study participant to be cleared, but it's %@", participant);
}


@end
