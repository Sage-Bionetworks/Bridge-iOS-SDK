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

- (void)testGetDataGroups {
    XCTestExpectation *expectGotGroups = [self expectationWithDescription:@"Retrieved data groups"];
    [SBBComponent(SBBUserManager) getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[SBBDataGroups class]], @"Retrieved data groups");
        [expectGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting data groups: %@", error);
        }
    }];
}

- (void)testUpdateDataGroups {
    XCTestExpectation *expectUpdatedGroups = [self expectationWithDescription:@"Updated data groups"];
    
    SBBDataGroups *groups = [SBBDataGroups new];
    groups.dataGroups = [NSSet setWithArray:@[@"group1", @"group2", @"group3"]];
    
    [SBBComponent(SBBUserManager) updateDataGroupsWithGroups:groups completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error updating data groups:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Updated data groups");
        [expectUpdatedGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating data groups: %@", error);
        }
    }];
    
    XCTestExpectation *expectGotGroups = [self expectationWithDescription:@"Retrieved updated data groups"];
    [SBBComponent(SBBUserManager) getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[SBBDataGroups class]], @"Retrieved updated data groups");
        XCTAssert([((SBBDataGroups *)dataGroups).dataGroups isEqual:groups.dataGroups], @"Verified data groups updated as requested");
        [expectGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting updated data groups: %@", error);
        }
    }];
}

- (void)testAddToDataGroups
{
    XCTestExpectation *expectUpdatedGroups = [self expectationWithDescription:@"Updated data groups"];
    
    SBBDataGroups *groups = [SBBDataGroups new];
    groups.dataGroups = [NSSet setWithArray:@[@"group1", @"group2", @"group3"]];
    
    [SBBComponent(SBBUserManager) updateDataGroupsWithGroups:groups completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error updating data groups:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Updated data groups");
        [expectUpdatedGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating data groups: %@", error);
        }
    }];
    
    XCTestExpectation *expectAddedToGroups = [self expectationWithDescription:@"Added to data groups"];
    NSArray *newGroups = @[@"group4", @"group5"];
    [SBBComponent(SBBUserManager) addToDataGroups:newGroups completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error adding to data groups %@:\n%@\nResponse: %@", newGroups, error, responseObject);
        }
        XCTAssert(!error, @"Added to data groups");
        [expectAddedToGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout adding to data groups: %@", error);
        }
    }];

    XCTestExpectation *expectGotGroups = [self expectationWithDescription:@"Retrieved data groups"];
    [SBBComponent(SBBUserManager) getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[SBBDataGroups class]], @"Retrieved data groups");
        NSArray *combined = @[@"group1", @"group2", @"group3", @"group4", @"group5"];
        XCTAssert([[dataGroups dataGroups] isEqual:[NSSet setWithArray:combined]], @"Data groups added as expected");
        [expectGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting data groups: %@", error);
        }
    }];
}

- (void)testRemoveFromDataGroups
{
    XCTestExpectation *expectUpdatedGroups = [self expectationWithDescription:@"Updated data groups"];
    
    SBBDataGroups *groups = [SBBDataGroups new];
    groups.dataGroups = [NSSet setWithArray:@[@"group1", @"group2", @"group3"]];
    
    [SBBComponent(SBBUserManager) updateDataGroupsWithGroups:groups completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error updating data groups:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Updated data groups");
        [expectUpdatedGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating data groups: %@", error);
        }
    }];
    
    XCTestExpectation *expectRemovedFromGroups = [self expectationWithDescription:@"Removed from data groups"];
    NSArray *oldGroups = @[@"group1", @"group3"];
    [SBBComponent(SBBUserManager) removeFromDataGroups:oldGroups completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error removing from data groups %@:\n%@\nResponse: %@", oldGroups, error, responseObject);
        }
        XCTAssert(!error, @"Removed from data groups");
        [expectRemovedFromGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout removing from data groups: %@", error);
        }
    }];
    
    XCTestExpectation *expectGotGroups = [self expectationWithDescription:@"Retrieved data groups"];
    [SBBComponent(SBBUserManager) getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[SBBDataGroups class]], @"Retrieved data groups");
        NSArray *afterRemoval = @[@"group2"];
        XCTAssert([[dataGroups dataGroups] isEqual:[NSSet setWithArray:afterRemoval]], @"Data groups removed as expected");
        [expectGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting data groups: %@", error);
        }
    }];
}

@end
