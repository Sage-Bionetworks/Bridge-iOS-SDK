//
//  SBBCacheManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/25/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBCacheManager.h"
#import "SBBComponentManager.h"
#import "SBBUserManager.h"
#import "SBBUserProfile.h"
#import "SBBDataGroups.h"

@interface SBBCacheManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBCacheManagerIntegrationTests

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

- (void)testProfileAndDataGroupsAcrossSignIn {
    // fetch profile and data groups
    __block SBBUserProfile *profile = nil;
    __block SBBDataGroups *groups = nil;
    XCTestExpectation *expectGotProfile = [self expectationWithDescription:@"Retrieved user profile"];
    [SBBComponent(SBBUserManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        if (error) {
            NSLog(@"Error getting user profile:\n%@", error);
        }
        XCTAssert(!error && [userProfile isKindOfClass:[SBBUserProfile class]], @"Retrieved user profile");
        profile = userProfile;
        [expectGotProfile fulfill];
    }];
    
    XCTestExpectation *expectGotGroups = [self expectationWithDescription:@"Retrieved data groups"];
    [SBBComponent(SBBUserManager) getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[SBBDataGroups class]], @"Retrieved data groups");
        groups = dataGroups;
        [expectGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting user profile and/or data groups: %@", error);
        }
    }];
    
    // modify them locally without updating to server
    
    SBBUserProfile *savedProfile = [profile copy];
    SBBDataGroups *savedGroups = [groups copy];
    
    profile.firstName = [savedProfile.firstName ?: @"" stringByAppendingString:@"soitsnotthesame"];
    groups.dataGroups = [savedGroups.dataGroups ?: [NSSet set] setByAddingObjectsFromArray:@[@"soitsnotthesame"]];
    
    // fetch them again without signing in again first; they should not be updated from server
    __block SBBUserProfile *reProfile = nil;
    __block SBBDataGroups *reGroups = nil;
    XCTestExpectation *expectReGotProfile = [self expectationWithDescription:@"Re-retrieved user profile"];
    [SBBComponent(SBBUserManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        if (error) {
            NSLog(@"Error getting user profile:\n%@", error);
        }
        XCTAssert(!error && [userProfile isKindOfClass:[SBBUserProfile class]], @"Re-retrieved user profile");
        reProfile = userProfile;
        [expectReGotProfile fulfill];
    }];
    
    XCTestExpectation *expectReGotGroups = [self expectationWithDescription:@"Re-retrieved data groups"];
    [SBBComponent(SBBUserManager) getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[SBBDataGroups class]], @"Re-retrieved data groups");
        reGroups = dataGroups;
        [expectReGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout re-getting user profile and/or data groups: %@", error);
        }
    }];
    
    // Compare before & after; profile & data groups should stay updated locally, not revert to what was on server.
    // Note that what comes back from the getXxxWithCompletion: methods will be the in-memory cached objects as they
    // exist after updating from the server.
    XCTAssertNotEqualObjects(savedProfile.firstName, reProfile.firstName, @"Refreshing from server without intervening signIn did not revert to server UserProfile");
    XCTAssertEqualObjects(profile.firstName, reProfile.firstName, @"Refreshing from server without intervening signIn did not overwrite cached UserProfile");
    XCTAssertNotEqualObjects(savedGroups.dataGroups, reGroups.dataGroups, @"Refreshing from server without intervening signIn did not revert to server DataGroups");
    XCTAssertEqualObjects(groups.dataGroups, reGroups.dataGroups, @"Refreshing from server without intervening signIn did not overwrite cached DataGroups");
    
    // sign in again (no need to sign out first for this test)
    XCTestExpectation *expectSignedIn = [self expectationWithDescription:@"Signed back in"];
    [SBBComponent(SBBAuthManager) signInWithEmail:self.testUserEmail password:self.testUserPassword completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error signing in to test user account %@:\n%@\nResponse: %@", self.testUserEmail, error, responseObject);
        }
        self.testSignInResponseObject = responseObject;
        [expectSignedIn fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout signing back in: %@", error);
        }
    }];
    // fetch them yet again after signing in again first; this time they should be updated from server
    XCTestExpectation *expectReReGotProfile = [self expectationWithDescription:@"Re-re-retrieved user profile"];
    [SBBComponent(SBBUserManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        if (error) {
            NSLog(@"Error getting user profile:\n%@", error);
        }
        XCTAssert(!error && [userProfile isKindOfClass:[SBBUserProfile class]], @"Re-re-trieved user profile");
        reProfile = userProfile;
        [expectReReGotProfile fulfill];
    }];
    
    XCTestExpectation *expectReReGotGroups = [self expectationWithDescription:@"Re-re-retrieved data groups"];
    [SBBComponent(SBBUserManager) getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[SBBDataGroups class]], @"Re-re-retrieved data groups");
        reGroups = dataGroups;
        [expectReReGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout re-re-getting user profile and/or data groups: %@", error);
        }
    }];
    
    // Compare before & after; after a sign-in, cached profile & data groups should revert to what was on server.
    // Note that what comes back from the getXxxWithCompletion: methods will be the in-memory cached objects as they
    // exist after updating from the server.
    XCTAssertEqualObjects(savedProfile.firstName, reProfile.firstName, @"Refreshing from server with intervening signIn did overwrite cached UserProfile");
    XCTAssertEqualObjects(savedGroups.dataGroups, reGroups.dataGroups, @"Refreshing from server with intervening signIn did overwrite cached DataGroups");
}

#pragma clang diagnostic pop

@end
