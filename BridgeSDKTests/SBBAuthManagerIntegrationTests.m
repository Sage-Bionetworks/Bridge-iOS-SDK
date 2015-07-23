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
    [SBBComponent(SBBAuthManager) signUpWithEmail:emailAddress username:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (error) NSLog(@"Error signing up with email %@:\n%@\n%@", emailAddress, error, responseObject);
        XCTAssert(!error, @"Signed up for account with no error");
        [expectSignUp fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
    // delete the test user just created
    XCTestExpectation *expectDelete = [self expectationWithDescription:@"delete completion handler called"];
    [self deleteUser:emailAddress completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted test account %@", emailAddress);
        } else {
            NSLog(@"Failed to delete test account %@\n\nError:%@\nResponse:%@", emailAddress, error, responseObject);
        }
        [expectDelete fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testSignInSignOut {
    // we need our own auth manager instance (with its own delegate) so we don't eff with the global test user
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    aMan.authDelegate = delegate;
    XCTestExpectation *expectBadUserFails = [self expectationWithDescription:@"signIn failed for nonexistent user"];

    [aMan signInWithUsername:@"notSignedUp" password:@"notAPassword" completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == 404, @"Invalid credentials test");
        [expectBadUserFails fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in with nonexistent user: %@", error);
        }
    }];
    
    XCTestExpectation *expect412Unconsented = [self expectationWithDescription:@"signIn returns a 412 status code for unconsented user"];
    
    __block NSString *unconsentedEmail = nil;
    [self createTestUserConsented:NO roles:@[] completionHandler:^(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error) {
        if (!error) {
            unconsentedEmail = emailAddress;
            [aMan signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                XCTAssert([error.domain isEqualToString:SBB_ERROR_DOMAIN] && error.code == kSBBServerPreconditionNotMet, @"Valid credentials, no consent test");
                [aMan clearKeychainStore];
                [expect412Unconsented fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in with unconsented user: %@", error);
        }
    }];
    
    // clean up the unconsented user we just created (no need to wait for it to finish, nothing else depends on it)
    [self deleteUser:unconsentedEmail completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted unconsented test account %@", unconsentedEmail);
        } else {
            NSLog(@"Failed to delete unconsented test account %@\n\nError:%@\nResponse:%@", unconsentedEmail, error, responseObject);
        }
    }];
    
    XCTestExpectation *expectSignedIn = [self expectationWithDescription:@"consented test user signed in"];
    __block NSString *consentedEmail = nil;
    [self createTestUserConsented:YES roles:@[] completionHandler:^(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error) {
        if (!error) {
            consentedEmail = emailAddress;
            [aMan signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                XCTAssert(!error
                          && [responseObject[@"type"] isEqualToString:@"UserSessionInfo"]
                          && [responseObject[@"sessionToken"] length] > 0
                          && [responseObject[@"username"] isEqualToString:username],
                          @"Successful sign-in of consented user");
                if (error) {
                    NSLog(@"Error signing in with consented user %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                }
                [expectSignedIn fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing in with consented user: %@", error);
        }
    }];
    
    XCTAssert(consentedEmail.length && aMan.isAuthenticated, @"Check signed-in before signing out");
    XCTestExpectation *expectSignedOut = [self expectationWithDescription:@"signed-in test user signed out"];
    [aMan signOutWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
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

@end
