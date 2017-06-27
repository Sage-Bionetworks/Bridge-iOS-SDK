//
//  SBBParticipantManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 12/17/16.
//  Copyright (c) 2016 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBParticipantManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBStudyParticipant.h"
#import "SBBCacheManager.h"
#import "SBBObjectManagerInternal.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBTestBridgeObject.h"
#import "ModelObjectInternal.h"

@interface TestParticipantMappingObject : NSObject 

@property (nonatomic, strong) NSString *givenName;
@property (nonatomic, strong) NSString *familyName;
@property (nonatomic, strong) NSString *emailAddress;

@end

@implementation TestParticipantMappingObject

@end

@interface SBBParticipantManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@end

@implementation SBBParticipantManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetParticipantRecordWithCompletion {
    XCTestExpectation *expectGotParticipant = [self expectationWithDescription:@"Retrieved study participant record"];
    [SBBComponent(SBBParticipantManager) getParticipantRecordWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error getting study participant record:\n%@", error);
        }
        XCTAssert(!error && [studyParticipant isKindOfClass:[SBBStudyParticipant class]], @"Retrieved study participant record");
        [expectGotParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting study participant record: %@", error);
        }
    }];
}

- (void)testUpdateParticipantRecordWithRecord {
    XCTestExpectation *expectUpdatedParticipant = [self expectationWithDescription:@"Updated study participant"];
    
    SBBStudyParticipant *participant = [SBBStudyParticipant new];
    participant.firstName = @"Test";
    participant.lastName = @"User";
    participant.email = self.testUserEmail;
    
    [SBBComponent(SBBParticipantManager) updateParticipantRecordWithRecord:participant completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating user profile:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Updated study participant");
        [expectUpdatedParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating study participant record: %@", error);
        }
    }];
    
    XCTestExpectation *expectGotParticipant = [self expectationWithDescription:@"Retrieved updated study participant"];
    [SBBComponent(SBBParticipantManager) getParticipantRecordWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error getting study participant record:\n%@", error);
        }
        XCTAssert(!error && [studyParticipant isKindOfClass:[SBBStudyParticipant class]], @"Retrieved updated study participant record");
        XCTAssert([[studyParticipant firstName] isEqualToString:participant.firstName] && [[studyParticipant lastName] isEqualToString:participant.lastName], @"Verified study participant record updated as requested");
        [expectGotParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting updated study participant record: %@", error);
        }
    }];
    
    if (gSBBUseCache) {
        // what we retrieved above was from the local cache; now hit Bridge to be sure it got updated there too
        XCTestExpectation *expectGotParticipant = [self expectationWithDescription:@"Retrieved updated study participant from Bridge"];
        [(id<SBBParticipantManagerInternalProtocol>)SBBComponent(SBBParticipantManager) getParticipantRecordFromBridgeWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error getting study participant record:\n%@", error);
            }
            XCTAssert(!error && [studyParticipant isKindOfClass:[SBBStudyParticipant class]], @"Retrieved updated study participant record from Bridge");
            XCTAssert([[studyParticipant firstName] isEqualToString:participant.firstName] && [[studyParticipant lastName] isEqualToString:participant.lastName], @"Verified study participant record updated to Bridge as requested");
            [expectGotParticipant fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Timeout getting updated study participant record from Bridge: %@", error);
            }
        }];
    }
}

- (void)testUpdateParticipantRecordWithMappedRecord {
    XCTestExpectation *expectUpdatedParticipant = [self expectationWithDescription:@"Updated study participant"];
    id<SBBObjectManagerInternalProtocol> oMan = [SBBObjectManager objectManager];
    id<SBBParticipantManagerInternalProtocol> pMan = [SBBParticipantManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:oMan];
    [oMan setupMappingForType:[SBBStudyParticipant entityName]
                      toClass:[TestParticipantMappingObject class]
      fieldToPropertyMappings:@{
                                NSStringFromSelector(@selector(firstName)): NSStringFromSelector(@selector(givenName)),
                                NSStringFromSelector(@selector(lastName)): NSStringFromSelector(@selector(familyName)),
                                NSStringFromSelector(@selector(email)): NSStringFromSelector(@selector(emailAddress))
                                }];
    
    TestParticipantMappingObject *participant = [TestParticipantMappingObject new];
    participant.givenName = @"Test";
    participant.familyName = @"User";
    participant.emailAddress = self.testUserEmail;
    
    [pMan updateParticipantRecordWithRecord:participant completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating user profile:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Updated study participant");
        [expectUpdatedParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating study participant record: %@", error);
        }
    }];
    
    XCTestExpectation *expectGotParticipant = [self expectationWithDescription:@"Retrieved updated study participant"];
    [pMan getParticipantRecordWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error getting study participant record:\n%@", error);
        }
        XCTAssert(!error && [studyParticipant isKindOfClass:[TestParticipantMappingObject class]], @"Retrieved updated study participant record");
        XCTAssert([[studyParticipant givenName] isEqualToString:participant.givenName] && [[studyParticipant familyName] isEqualToString:participant.familyName], @"Verified study participant record updated as requested");
        [expectGotParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting updated study participant record: %@", error);
        }
    }];
    
    if (gSBBUseCache) {
        // what we retrieved above was from the local cache; now hit Bridge to be sure it got updated there too
        XCTestExpectation *expectGotParticipant = [self expectationWithDescription:@"Retrieved updated study participant from Bridge"];
        [pMan getParticipantRecordFromBridgeWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error getting study participant record:\n%@", error);
            }
            XCTAssert(!error && [studyParticipant isKindOfClass:[TestParticipantMappingObject class]], @"Retrieved updated study participant record from Bridge");
            XCTAssert([[studyParticipant givenName] isEqualToString:participant.givenName] && [[studyParticipant familyName] isEqualToString:participant.familyName], @"Verified study participant record updated to Bridge as requested");
            [expectGotParticipant fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Timeout getting updated study participant record from Bridge: %@", error);
            }
        }];
    }
}

- (void)testUpdateParticipantRecordWithNilRecord {
    if (!gSBBUseCache) {
        // in this case the update call would just do nothing, log an error, and return nil
        XCTAssert(YES, @"nothing to test");
        return;
    }
    
    XCTestExpectation *expectUpdatedParticipant = [self expectationWithDescription:@"Updated study participant"];
    
    // modify the cached participant singleton directly
    SBBStudyParticipant *participant = (SBBStudyParticipant *)[SBBComponent(SBBCacheManager) cachedSingletonObjectOfType:[SBBStudyParticipant entityName] createIfMissing:NO];
    participant.firstName = @"Test";
    participant.lastName = @"User";
    participant.email = self.testUserEmail;
    
    // in a real situation you should save it to CoreData now, in case the in-memory PONSO cache goes away for any reason,
    // but for testing, it doesn't matter so we won't bother
    
    // nil record means sync the cached participant record to Bridge
    [SBBComponent(SBBParticipantManager) updateParticipantRecordWithRecord:nil completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating user profile:\n%@\nResponse: %@", error, responseObject);
        }
        XCTAssert(!error, @"Updated study participant");
        [expectUpdatedParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating study participant record: %@", error);
        }
    }];
    
    XCTestExpectation *expectGotParticipant = [self expectationWithDescription:@"Retrieved updated study participant"];
    [SBBComponent(SBBParticipantManager) getParticipantRecordWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error getting study participant record:\n%@", error);
        }
        XCTAssert(!error && [studyParticipant isKindOfClass:[SBBStudyParticipant class]], @"Retrieved updated study participant record");
        XCTAssert([[studyParticipant firstName] isEqualToString:participant.firstName] && [[studyParticipant lastName] isEqualToString:participant.lastName], @"Verified study participant record updated as requested");
        [expectGotParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting updated study participant record: %@", error);
        }
    }];
    
    if (gSBBUseCache) {
        // what we retrieved above was from the local cache; now hit Bridge to be sure it got updated there too
        XCTestExpectation *expectGotParticipant = [self expectationWithDescription:@"Retrieved updated study participant from Bridge"];
        [(id<SBBParticipantManagerInternalProtocol>)SBBComponent(SBBParticipantManager) getParticipantRecordFromBridgeWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error getting study participant record:\n%@", error);
            }
            XCTAssert(!error && [studyParticipant isKindOfClass:[SBBStudyParticipant class]], @"Retrieved updated study participant record from Bridge");
            XCTAssert([[studyParticipant firstName] isEqualToString:participant.firstName] && [[studyParticipant lastName] isEqualToString:participant.lastName], @"Verified study participant record updated to Bridge as requested");
            [expectGotParticipant fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Timeout getting updated study participant record from Bridge: %@", error);
            }
        }];
    }
}

- (void)testSetSharingScope
{
    // test user is created with consent signed but sharing = none
    XCTestExpectation *expectChangedSharing = [self expectationWithDescription:@"changed data sharing"];
    [SBBComponent(SBBParticipantManager) setSharingScope:SBBParticipantDataSharingScopeAll completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssert(!error, @"Server accepted data sharing scope change");
        if (error) {
            NSLog(@"Error changing data sharing scope:\n%@\nResponse: %@", error, responseObject);
            [expectChangedSharing fulfill];
        } else {
            [SBBComponent(SBBAuthManager) signInWithEmail:self.testUserEmail password:self.testUserPassword completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error signing in to get user session info after changing data sharing scope:\n%@\nResponse: %@", error, responseObject);
                }
                XCTAssert([responseObject[@"dataSharing"] integerValue] == 1 && [responseObject[@"sharingScope"] isEqualToString:@"all_qualified_researchers"], @"Server reported new sharing scope on signIn");
                [expectChangedSharing fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout changing & checking data sharing scope: %@", error);
        }
    }];
}

- (void)testSetExternalIdentifier
{
    XCTestExpectation *expectSetIdentifier = [self expectationWithDescription:@"set external identifier"];
    NSString *externalIdentifier = @"test-external-identifier";
    [SBBComponent(SBBParticipantManager) setExternalIdentifier:externalIdentifier completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        XCTAssert(!error, @"Server accepted external identifier");
        if (error) {
            NSLog(@"Error setting external identifier:\n%@\nResponse: %@", error, responseObject);
            [expectSetIdentifier fulfill];
        } else {
            [SBBComponent(SBBParticipantManager) getParticipantRecordWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error getting study participant record after setting external identifier:\n%@\nResponse: %@", error, responseObject);
                }
                XCTAssert([studyParticipant isKindOfClass:[SBBStudyParticipant class]], @"Retrieved study participant record");
                XCTAssert([[studyParticipant externalId] isEqualToString:externalIdentifier], @"Fetched StudyParticipant reflects new externalId");
                if (!gSBBUseCache) {
                    // we're done here
                    [expectSetIdentifier fulfill];
                }
            }];
            
            if (gSBBUseCache) {
                // get the StudyParticipant straight from Bridge and check that externalId actually got set there too
                [(id<SBBParticipantManagerInternalProtocol>)SBBComponent(SBBParticipantManager) getParticipantRecordFromBridgeWithCompletion:^(id  _Nullable studyParticipant, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"Error getting study participant record from Bridge after setting external identifier:\n%@\nResponse: %@", error, responseObject);
                    }
                    XCTAssert([studyParticipant isKindOfClass:[SBBStudyParticipant class]], @"Retrieved study participant record from Bridge");
                    XCTAssert([[studyParticipant externalId] isEqualToString:externalIdentifier], @"Fetched StudyParticipant from Bridge reflects new externalId");
                    [expectSetIdentifier fulfill];
                }];
            }
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout setting & checking external identifier: %@", error);
        }
    }];
}

- (void)testGetDataGroups {
    XCTestExpectation *expectGotGroups = [self expectationWithDescription:@"Retrieved data groups"];
    [SBBComponent(SBBParticipantManager) getDataGroupsWithCompletion:^(NSSet<NSString *> *dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[NSSet class]], @"Retrieved data groups");
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
    
    NSSet<NSString *> *groups = [NSSet setWithArray:@[@"sdk-int-1", @"sdk-int-2"]];
    
    [SBBComponent(SBBParticipantManager) updateDataGroupsWithGroups:groups completion:^(id responseObject, NSError *error) {
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
    [SBBComponent(SBBParticipantManager) getDataGroupsWithCompletion:^(NSSet<NSString *> *dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[NSSet class]], @"Retrieved updated data groups");
        XCTAssert([dataGroups isEqual:groups], @"Verified data groups updated as requested");
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
    
    NSSet<NSString *> *groups =  [NSSet setWithArray:@[@"sdk-int-1"]];
    
    [SBBComponent(SBBParticipantManager) updateDataGroupsWithGroups:groups completion:^(id responseObject, NSError *error) {
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
    NSSet<NSString *> *newGroups = [NSSet setWithArray:@[@"sdk-int-2"]];
    [SBBComponent(SBBParticipantManager) addToDataGroups:newGroups completion:^(id responseObject, NSError *error) {
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
    [SBBComponent(SBBParticipantManager) getDataGroupsWithCompletion:^(NSSet<NSString *> *dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[NSSet class]], @"Retrieved data groups");
        NSArray *combined = @[@"sdk-int-1", @"sdk-int-2"];
        XCTAssert([dataGroups isEqual:[NSSet setWithArray:combined]], @"Data groups added as expected");
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
    
    NSSet<NSString *> *groups = [NSSet setWithArray:@[@"sdk-int-1", @"sdk-int-2"]];
    
    [SBBComponent(SBBParticipantManager) updateDataGroupsWithGroups:groups completion:^(id responseObject, NSError *error) {
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
    NSSet<NSString *> *oldGroups = [NSSet setWithArray:@[@"sdk-int-1"]];
    [SBBComponent(SBBParticipantManager) removeFromDataGroups:oldGroups completion:^(id responseObject, NSError *error) {
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
    [SBBComponent(SBBParticipantManager) getDataGroupsWithCompletion:^(NSSet<NSString *> *dataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error getting data groups:\n%@", error);
        }
        XCTAssert(!error && [dataGroups isKindOfClass:[NSSet class]], @"Retrieved data groups");
        NSSet<NSString *> *afterRemoval = [NSSet setWithArray:@[@"sdk-int-2"]];
        XCTAssert([dataGroups isEqual:afterRemoval], @"Data groups removed as expected");
        [expectGotGroups fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout getting data groups: %@", error);
        }
    }];
}

@end
