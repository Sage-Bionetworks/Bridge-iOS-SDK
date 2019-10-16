//
//  SBBAuthManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/15/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBTestAuthKeychainManager.h"

@interface SBBAuthManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBAuthManagerIntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSignUp {
    XCTestExpectation *expectSignUp = [self expectationWithDescription:@"signUp completion handler called"];
    
    NSString *emailFormat = @"bridge-testing+test%@@sagebase.org";
    NSString *unique = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *emailAddress = [NSString stringWithFormat:emailFormat, unique];
    NSString *usernameFormat = @"iOSIntegrationTestUser%@";
    NSString *username = [NSString stringWithFormat:usernameFormat, unique];
    NSString *password = @"123456";
    [SBBComponent(SBBAuthManager) signUpWithEmail:emailAddress username:username password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) NSLog(@"Error signing up with email %@:\n%@\n%@", emailAddress, error, responseObject);
        XCTAssert(!error, @"Signed up for account with no error");
        [expectSignUp fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
    // ok we need the user id to delete the account we just signed up, but we don't get it in the signup response
    // so we have to sign in to delete it.
    XCTestExpectation *expectSignedInAndDeleted = [self expectationWithDescription:@"signIn to delete failed for test signUp user"];
    
    [SBBComponent(SBBAuthManager) signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Failed to sign in to delete test signUp user: %@", error);
            [expectSignedInAndDeleted fulfill];
        } else {
            // delete the test user just created
            [self deleteUser:responseObject[kUserSessionInfoIdKey] completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (!error) {
                    NSLog(@"Deleted test account %@", emailAddress);
                } else {
                    NSLog(@"Failed to delete test signUp account %@ after successfully signing in\n\nError:%@\nResponse:%@", emailAddress, error, responseObject);
                }
                [expectSignedInAndDeleted fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in to delete signUp test user: %@", error);
        }
    }];
}

- (void)testSignInSignOut {
    // we need our own auth manager instance (with its own delegate) so we don't eff with the global test user
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    aMan.keychainManager = [SBBTestAuthKeychainManager new];
    XCTestExpectation *expectBadUserFails = [self expectationWithDescription:@"signIn failed for nonexistent user"];

    [aMan signInWithEmail:@"notSignedUp" password:@"notAPassword" completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == 404, @"Invalid credentials test");
        [expectBadUserFails fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in with nonexistent user: %@", error);
        }
    }];
    
    XCTestExpectation *expect412Unconsented = [self expectationWithDescription:@"signIn returns a 412 status code for unconsented user"];
    
    __block NSString *unconsentedId = nil;
    __block NSString *unconsentedEmail = nil;
    [self createTestUserConsented:NO roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Failed to create unconsented test user");
            [expect412Unconsented fulfill];
        } else {
            unconsentedEmail = emailAddress;
            [aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == SBBErrorCodeServerPreconditionNotMet, @"Valid credentials, no consent test");
                [aMan.keychainManager clearKeychainStore];
                unconsentedId = responseObject[kUserSessionInfoIdKey];
                [expect412Unconsented fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in with unconsented user: %@", error);
        }
    }];
    
    // clean up the unconsented user we just created (no need to wait for it to finish, nothing else depends on it)
    if (unconsentedId) {
        [self deleteUser:unconsentedId completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (!error) {
                NSLog(@"Deleted unconsented test account %@", unconsentedEmail);
            } else {
                NSLog(@"Failed to delete unconsented test account %@\n\nError:%@\nResponse:%@", unconsentedEmail, error, responseObject);
            }
        }];
    } else {
        NSLog(@"Failed to retrieve test account id for %@, account not deleted", unconsentedEmail);
    }
    
    XCTestExpectation *expectSignedIn = [self expectationWithDescription:@"consented test user signed in"];
    __block NSString *consentedEmail = nil;
    [self createTestUserConsented:YES roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (!error) {
            consentedEmail = emailAddress;
            [aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                XCTAssert(!error
                          && [responseObject[@"type"] isEqualToString:@"UserSessionInfo"]
                          && [responseObject[@"sessionToken"] length] > 0,
                          @"Successful sign-in of consented user");
                if (error) {
                    NSLog(@"Error signing in with consented user %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                }
                [expectSignedIn fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in with consented user: %@", error);
        }
    }];
    
    XCTAssert(consentedEmail.length && aMan.isAuthenticated, @"Check signed-in before signing out");
    XCTestExpectation *expectSignedOut = [self expectationWithDescription:@"signed-in test user signed out"];
    [aMan signOutWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error signing out from account %@:\n%@\nResponse: %@", consentedEmail, error, responseObject);
        }
        XCTAssert(!aMan.isAuthenticated && [responseObject[@"message"] isEqualToString:@"Signed out."], @"Successfully signed out");
        [expectSignedOut fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing out signed-in user: %@", error);
        }
    }];
}

- (void)tryReauthWithAuthMan:(id<SBBAuthManagerInternalProtocol>)aMan
               sessionTokens:(NSMutableArray *)sessionTokens
                reauthTokens:(NSMutableArray *)reauthTokens
                 expectation:(XCTestExpectation *)expectation {
    [aMan attemptReauthWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert(!error, @"Error attempting to reauth:\n%@\nResponse: %@",error, responseObject);
        [sessionTokens addObject:responseObject[@"sessionToken"] ?: @"FAILED"];
        [reauthTokens addObject:responseObject[@"reauthToken"] ?: @"FAILED"];
        [expectation fulfill];
    }];
}

- (void)tryReSignInWithAuthMan:(id<SBBAuthManagerInternalProtocol>)aMan
               sessionTokens:(NSMutableArray *)sessionTokens
                 reauthTokens:(NSMutableArray *)reauthTokens
                 expectation:(XCTestExpectation *)expectation {
    [aMan attemptSignInWithStoredCredentialsWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        XCTAssert(!error, @"Error attempting to sign in with stored credentials:\n%@\nResponse: %@", error, responseObject);
        [sessionTokens addObject:responseObject[@"sessionToken"] ?: @"FAILED"];
        [reauthTokens addObject:responseObject[@"reauthToken"] ?: @"FAILED"];
        [expectation fulfill];
    }];
}

- (void)testOverlappingSignInAndReauthCalls {
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    aMan.keychainManager = [SBBTestAuthKeychainManager new];

    XCTestExpectation *expectSignedIn = [self expectationWithDescription:@"consented test user signed in"];
    __block NSString *consentedEmail = nil;
    [self createTestUserConsented:YES roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (!error) {
            consentedEmail = emailAddress;
            [aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                XCTAssert(!error
                          && [responseObject[@"type"] isEqualToString:@"UserSessionInfo"]
                          && [responseObject[@"sessionToken"] length] > 0,
                          @"Successful sign-in of consented user");
                if (error) {
                    NSLog(@"Error signing in with consented user %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                }
                [expectSignedIn fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in with consented user: %@", error);
        }
    }];
    
    if (!consentedEmail.length || !aMan.isAuthenticated) {
        // If we couldn't even sign in the test consented user, there's no point in going on
        return;
    }
    
    // Hammer Bridge with many simultaneous reauth and signIn requests.
    NSMutableArray<NSString *> *sessionTokens = [NSMutableArray array];
    NSMutableArray<NSString *> *reauthTokens = [NSMutableArray array];
    
    for (uint32_t i = 0; i < 10; ++i) {
        NSString *description = [NSString stringWithFormat:@"reauth attempt %u completed", i];
        XCTestExpectation *expectation = [self expectationWithDescription:description];
        [self tryReauthWithAuthMan:(id<SBBAuthManagerInternalProtocol>)aMan sessionTokens:sessionTokens reauthTokens:reauthTokens expectation:expectation];
    }
    for (uint32_t j = 0; j < 2; ++j) {
        NSString *description = [NSString stringWithFormat:@"signIn attempt %u completed", j];
        XCTestExpectation *expectation = [self expectationWithDescription:description];
        [self tryReSignInWithAuthMan:(id<SBBAuthManagerInternalProtocol>)aMan sessionTokens:sessionTokens reauthTokens:reauthTokens expectation:expectation];
    }
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout waiting for multiple concurrent reauth/re-signIn requests to complete: %@", error);
        }
    }];
    
    // Verify that all 12 reauth/re-signIn attempts succeeded and got the same session and reauth tokens.
    XCTAssert(sessionTokens.count == 12, @"Expected array to have 12 session tokens but got %@", sessionTokens);
    XCTAssert(reauthTokens.count == 12, @"Expected array to have 12 reauth tokens but got %@", reauthTokens);
    
    NSString *sessionToken0 = sessionTokens[0];
    NSString *reauthToken0 = reauthTokens[0];
    XCTAssertNotEqualObjects(sessionToken0, @"FAILED", @"Failed to get new session token");
    XCTAssertNotEqualObjects(reauthToken0, @"FAILED", @"Failed to get new reauth token");
    
    for (uint32_t i = 1; i < 10; ++i) {
        XCTAssertEqualObjects(sessionToken0, sessionTokens[i], @"sessionTokens[%u]: %@ != %@", i, sessionTokens[i], sessionToken0);
    }
    for (uint32_t j = 1; j < 2; ++j) {
        XCTAssertEqualObjects(reauthToken0, reauthTokens[j], @"reauthTokens[%u]: %@ != %@", j, reauthTokens[j], reauthToken0);
    }

    XCTestExpectation *expectSignedOut = [self expectationWithDescription:@"signed-in test user signed out"];
    [aMan signOutWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error signing out from account %@:\n%@\nResponse: %@", consentedEmail, error, responseObject);
        }
        XCTAssert(!aMan.isAuthenticated && [responseObject[@"message"] isEqualToString:@"Signed out."], @"Successfully signed out");
        [expectSignedOut fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing out signed-in user: %@", error);
        }
    }];
}

#pragma clang diagnostic pop

@end
