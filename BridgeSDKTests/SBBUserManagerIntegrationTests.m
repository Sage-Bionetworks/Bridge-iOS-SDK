//
//  SBBUserManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/18/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"

@interface SBBUserManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBUserManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetUserProfile {
    XCTestExpectation *expectGotProfile = [self expectationWithDescription:@"Retrieved user profile"];
    [SBBComponent(SBBUserManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        if (error) {
            NSLog(@"Error getting user profile:\n%@", error);
        }
        XCTAssert(!error && [userProfile isKindOfClass:[SBBUserProfile class]], @"Retrieved user profile");
        [expectGotProfile fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting user profile: %@", error);
        }
    }];
}

- (void)testUpdateUserProfile {
    XCTestExpectation *expectUpdatedProfile = [self expectationWithDescription:@"Updated user profile"];
    
    SBBUserProfile *profile = [SBBUserProfile new];
    profile.firstName = @"Test";
    profile.lastName = @"User";
    profile.email = self.testUserEmail;
    profile.username = self.testUserUsername;
    
    [SBBComponent(SBBUserManager) updateUserProfileWithProfile:profile completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error updating user profile:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Updated user profile");
        [expectUpdatedProfile fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating user profile: %@", error);
        }
    }];
    
    XCTestExpectation *expectGotProfile = [self expectationWithDescription:@"Retrieved updated user profile"];
    [SBBComponent(SBBUserManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        if (error) {
            NSLog(@"Error getting user profile:\n%@", error);
        }
        XCTAssert(!error && [userProfile isKindOfClass:[SBBUserProfile class]], @"Retrieved updated user profile");
        XCTAssert([[userProfile firstName] isEqualToString:profile.firstName] && [[userProfile lastName] isEqualToString:profile.lastName], @"Verified user profile updated as requested");
        [expectGotProfile fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting updated user profile: %@", error);
        }
    }];
}

- (void)testDataSharing
{
    // test user is created with consent signed but sharing = none
    XCTestExpectation *expectChangedSharing = [self expectationWithDescription:@"changed data sharing"];
    [SBBComponent(SBBUserManager) dataSharing:SBBUserDataSharingScopeAll completion:^(id responseObject, NSError *error) {
        XCTAssert(!error, @"Server accepted data sharing scope change");
        if (error) {
            NSLog(@"Error changing data sharing scope:\n%@\nResponse: %@", error, responseObject);
            [expectChangedSharing fulfill];
        } else {
            [SBBComponent(SBBAuthManager) signInWithUsername:self.testUserUsername password:self.testUserPassword completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error signing in to get user session info after changing data sharing scope:\n%@\nResponse: %@", error, responseObject);
                }
                XCTAssert([responseObject[@"dataSharing"] integerValue] == 1 && [responseObject[@"sharingScope"] isEqualToString:@"all_qualified_researchers"], @"Server reported new sharing scope on signIn");
                [expectChangedSharing fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout changing & checking data sharing scope: %@", error);
        }
    }];
}

- (void)testEmailData
{
    XCTestExpectation *expectSentData = [self expectationWithDescription:@"emailed data"];
    [SBBComponent(SBBUserManager) emailDataToUserFrom:[NSDate dateWithTimeIntervalSince1970:0] to:[NSDate date] completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error requesting user data:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Server emailed data");
        [expectSentData fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout requesting user data: %@", error);
        }
    }];
}

@end
