//
//  SBBAuthManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/15/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBTestAuthManagerDelegate.h"

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
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    aMan.authDelegate = delegate;
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
                [aMan clearKeychainStore];
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
        XCTAssertNil(delegate.sessionInfo, @"Expected the delegate to have been told to clear the sessionInfo, but it still has this:\n%@", delegate.sessionInfo);
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
