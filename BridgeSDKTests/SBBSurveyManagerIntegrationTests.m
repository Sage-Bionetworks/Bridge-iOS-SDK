//
//  SBBSurveyManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/18/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBTestAuthManagerDelegate.h"

@interface SBBSurveyManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@property (nonatomic, strong) NSString *ardUserEmail;
@property (nonatomic, strong) NSString *ardUserPassword;
@property (nonatomic, strong) NSString *ardUserId;
@property (nonatomic, strong) SBBAuthManager *aMan;

@end

@implementation SBBSurveyManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // 1. Create a user with admin, researcher, and developer roles so we can do all the things.
    // we need our own auth manager instance (with its own delegate) so we don't eff with the global test user
    _aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    _aMan.authDelegate = delegate;
    XCTestExpectation *expectARDUser = [self expectationWithDescription:@"Created user with all roles"];
    [self createTestUserConsented:NO roles:@[@"admin", @"researcher", @"developer"] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating all-roles test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
            if (![error.domain isEqualToString:@"com.apple.XCTestErrorDomain"] || error.code != 0) {
                [expectARDUser fulfill];
            }
        } else {
            _ardUserEmail = emailAddress;
            _ardUserPassword = password;
            [_aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error signing in to all-roles test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                } else {
                    _ardUserId = responseObject[kUserSessionInfoIdKey];
                }
                [expectARDUser fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to create and sign in to all-roles test user account:\n%@", error);
        }
    }];
    
    // 2. Create a test survey.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.

    // 3. Delete the test survey.
    
    // 4. Delete the test god-mode user.
    XCTestExpectation *expectation = [self expectationWithDescription:@"test user deleted"];
    [self deleteUser:_ardUserId completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted all-roles test account %@", _ardUserEmail);
        } else {
            NSLog(@"Failed to delete all-roles test account %@\n\nError:%@\nResponse:%@", _ardUserEmail, error, responseObject);
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error attempting to delete all-roles test user account %@: %@", _ardUserEmail, error);
        }
    }];

    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

@end
