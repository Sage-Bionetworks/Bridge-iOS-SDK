//
//  SBBProfileManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/18/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"

@interface SBBProfileManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBProfileManagerIntegrationTests

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
    [SBBComponent(SBBProfileManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
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
    
    [SBBComponent(SBBProfileManager) updateUserProfileWithProfile:profile completion:^(id responseObject, NSError *error) {
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
    [SBBComponent(SBBProfileManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
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

@end
