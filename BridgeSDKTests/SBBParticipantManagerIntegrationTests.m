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

- (NSCalendar *)gregorianCalendar
{
    static NSCalendar *gregorianCalendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    
    return gregorianCalendar;
}

- (NSDateComponents *)dateOnlyComponentsForDate:(NSDate *)date
{
    return [self.gregorianCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
}

- (void)addItemData:(id<SBBJSONValue>)data toReport:(NSString *)identifier withDate:(NSDate *)date dateOnly:(BOOL)dateOnly
{
    XCTestExpectation *savedItem = [self expectationWithDescription:@"Saved report item data to Bridge"];
    if (dateOnly) {
        NSDateComponents *components = [self dateOnlyComponentsForDate:date];
        [SBBComponent(SBBParticipantManager) saveReportJSON:data withLocalDate:components forReport:identifier completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
            XCTAssertNil(error, @"Unexpected error saving datestamped report item: %@", error);
            [savedItem fulfill];
        }];
    } else {
        [SBBComponent(SBBParticipantManager) saveReportJSON:data withDateTime:date forReport:identifier completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
            XCTAssertNil(error, @"Unexpected error saving timestamped report item: %@", error);
            [savedItem fulfill];
        }];
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout saving report item data to Bridge: %@", error);
        }
    }];
}

- (void)testAddTimestampedReportItem
{
    NSDictionary *itemData = @{
                               @"whatYouWant": @"Baby I got it",
                               @"whatYouNeed": @"Do you know I got it"
                               };
    
    NSDate *now = [NSDate date];
    [self addItemData:itemData toReport:@"Respect" withDate:now dateOnly:NO];
}

- (void)testAddDatestampedReportItem
{
    NSDictionary *itemData = @{
                               @"allImAskin": @"Is for a little respect when you get home (just a little bit)",
                               @"heyBaby": @"(just a little bit) when you get home"
                               };
    
    NSString *datestamp = @"1967-04-29";
    NSDate *releaseDate = [NSDate dateWithISO8601String:datestamp];
    [self addItemData:itemData toReport:@"Respect" withDate:releaseDate dateOnly:YES];
}

- (NSArray<NSString *> *)reportJSONDataList
{
    return @[
             @{ @"title": @"Respect" },
             @{ @"title": @"Natural Woman" },
             @{ @"title": @"Chain of Fools" },
             @{ @"title": @"Think" }
             ];
}

- (NSArray<SBBReportData *> *)retrieveItemsForReport:(NSString *)identifier from:(NSDate *)fromDate to:(NSDate *)toDate dateOnly:(BOOL)dateOnly
{
    XCTestExpectation *retrievedReport = [self expectationWithDescription:@"Retrieved participant report from Bridge"];
    __block NSArray<SBBReportData *> *items = nil;
    if (dateOnly) {
        NSDateComponents *startDate = [self dateOnlyComponentsForDate:fromDate];
        NSDateComponents *endDate = [self dateOnlyComponentsForDate:toDate];
        [SBBComponent(SBBParticipantManager) getReport:identifier fromDate:startDate toDate:endDate completion:^(NSArray * _Nullable participantReport, NSError * _Nullable error) {
            items = participantReport;
            [retrievedReport fulfill];
        }];
    } else {
        [SBBComponent(SBBParticipantManager) getReport:identifier fromTimestamp:fromDate toTimestamp:toDate completion:^(NSArray * _Nullable participantReport, NSError * _Nullable error) {
            items = participantReport;
            [retrievedReport fulfill];
        }];
    }
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout retrieving participant report from Bridge: %@", error);
        }
    }];

    return items;
}

- (void)testGetTimestampedReportItems
{
    // first set a bunch to retrieve; make sure there are more than one page's worth (default page size is 50)
    NSArray<NSString *> *dataList = self.reportJSONDataList;
    while (dataList.count <= 50) {
        dataList = [dataList arrayByAddingObjectsFromArray:dataList];
    }
    
    NSInteger timeOffset = 0;
    NSTimeInterval hour = 3600.0;
    NSString *identifier = @"Playlist";
    
    for (id<SBBJSONValue>data in dataList) {
        NSDate *timestamp = [NSDate dateWithTimeIntervalSinceNow:hour * timeOffset--];
        [self addItemData:data toReport:identifier withDate:timestamp dateOnly:NO];
    }
    
    // now retrieve them
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:hour * timeOffset];
    NSDate *endDate = [NSDate date];
    NSArray<SBBReportData *> *items = [self retrieveItemsForReport:identifier from:startDate to:endDate dateOnly:NO];

    XCTAssert(items.count == dataList.count, @"Expected %ld report data items but got %ld", dataList.count, items.count);
    if (items.count == dataList.count) {
        // expect the items to be in chronological order, so the reverse of their order in the data list
        NSInteger listOffset = dataList.count - 1;
        for (SBBReportData *item in items) {
            XCTAssertNil(item.localDate, @"Expected report item localDate to be nil but it's %@", item.localDate);
            XCTAssertNotNil(item.dateTime, @"Expected report item dateTime to not be nil but it is nil");
            id<SBBJSONValue> expectedData = dataList[listOffset--];
            XCTAssertEqual(item.data, expectedData, @"Expected item to have this data: %@\nbut got this instead: %@", expectedData, item.data);
        }
    }
    
    // now save different data at one of the existing timestamps and make sure it gets overwritten
    id<SBBJSONValue> newData = @{ @"title": @"I Say a Little Prayer" };
    uint32_t index = arc4random_uniform((uint32_t)items.count);
    NSDate *dateUpdating = items[index].date;
    NSString *dateTimeUpdating = items[index].dateTime;
    [self addItemData:newData toReport:identifier withDate:dateUpdating dateOnly:NO];
    
    // - check that it was overwritten locally:
    SBBForwardCursorPagedResourceList *cachedReport = (SBBForwardCursorPagedResourceList *)[SBBComponent(SBBCacheManager) cachedObjectOfType:SBBForwardCursorPagedResourceList.entityName withId:identifier createIfMissing:NO];
    XCTAssertNotNil(cachedReport, @"Expected to have a timestamped report cached for %@, but apparently not", identifier);
    if (cachedReport) {
        NSString *dateTimeKey = NSStringFromSelector(@selector(dateTime));
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", dateTimeKey, dateTimeUpdating];
        NSArray<SBBReportData *> *matches = [cachedReport.items filteredArrayUsingPredicate:predicate];
        XCTAssert(matches.count == 1, @"Expected cached report to have exactly one dateTime match but it has %ld", matches.count);
        if (matches.count == 1) {
            SBBReportData *item = matches[0];
            XCTAssertEqualObjects(item.data, newData, @"Expected updated item to have data %@\nbut instead it has %@", newData, item.data);
        }
    }
    
    // - clear the report from local cache, retrieve from Bridge, and check again to be sure it got overwritten there too:
    [SBBComponent(SBBCacheManager) removeFromCacheObjectOfType:SBBForwardCursorPagedResourceList.entityName withId:identifier];
    items = [self retrieveItemsForReport:identifier from:startDate to:endDate dateOnly:NO];
    XCTAssert(items.count > index, @"Expected re-retrieved report to have at least %u items, but it only has %ld", index + 1, items.count);
    if (items.count > index) {
        SBBReportData *item = items[index];
        XCTAssertEqualObjects(item.dateTime, dateTimeUpdating, @"Expected re-retrieved report to have the same dateTime at the same index, but instead of %@ it's %@", dateTimeUpdating, item.dateTime);
        XCTAssertEqualObjects(item.data, newData, @"Expected re-retrieved item to have data %@\nbut it has %@", newData, item.data);
    }
}

- (void)testGetDatestampedReportItems
{
    // first set a bunch to retrieve
    NSArray<NSString *> *dataList = self.reportJSONDataList;
    NSString *identifier = @"SongOfTheDay";
    
    NSInteger daysOffset = 0;
    NSDateComponents *components = [self dateOnlyComponentsForDate:[NSDate date]];
    for (id<SBBJSONValue>data in dataList) {
        components.day += daysOffset--;
        NSDate *timestamp = [self.gregorianCalendar dateFromComponents:components];
        [self addItemData:data toReport:identifier withDate:timestamp dateOnly:YES];
    }

    // now retrieve them
    NSDate *startDate = [self.gregorianCalendar dateFromComponents:components];
    NSDate *endDate = [NSDate date];
    NSArray<SBBReportData *> *items = [self retrieveItemsForReport:identifier from:startDate to:endDate dateOnly:YES];
    
    XCTAssert(items.count == dataList.count, @"Expected %ld report data items but got %ld", dataList.count, items.count);
    if (items.count == dataList.count) {
        // expect the items to be in chronological order, so the reverse of their order in the data list
        NSInteger listOffset = dataList.count - 1;
        for (SBBReportData *item in items) {
            XCTAssertNotNil(item.localDate, @"Expected report item localDate to not be nil but it is nil");
            XCTAssertNil(item.dateTime, @"Expected report item dateTime to be nil but it's %@", item.dateTime);
            id<SBBJSONValue> expectedData = dataList[listOffset--];
            XCTAssertEqual(item.data, expectedData, @"Expected item to have this data: %@\nbut got this instead: %@", expectedData, item.data);
        }
    }
    
    // now save different data at one of the existing datestamps and make sure it gets overwritten
    id<SBBJSONValue> newData = @{ @"title": @"I Say a Little Prayer" };
    uint32_t index = arc4random_uniform((uint32_t)items.count);
    NSDate *dateUpdating = items[index].date;
    NSString *localDateUpdating = items[index].localDate;
    [self addItemData:newData toReport:identifier withDate:dateUpdating dateOnly:YES];
    
    // - check that it was overwritten locally:
    SBBDateRangeResourceList *cachedReport = (SBBDateRangeResourceList *)[SBBComponent(SBBCacheManager) cachedObjectOfType:SBBDateRangeResourceList.entityName withId:identifier createIfMissing:NO];
    XCTAssertNotNil(cachedReport, @"Expected to have a datestamped report cached for %@, but apparently not", identifier);
    if (cachedReport) {
        NSString *localDateKey = NSStringFromSelector(@selector(localDate));
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", localDateKey, localDateUpdating];
        NSArray<SBBReportData *> *matches = [cachedReport.items filteredArrayUsingPredicate:predicate];
        XCTAssert(matches.count == 1, @"Expected cached report to have exactly one localDate match but it has %ld", matches.count);
        if (matches.count == 1) {
            SBBReportData *item = matches[0];
            XCTAssertEqualObjects(item.data, newData, @"Expected updated item to have data %@\nbut instead it has %@", newData, item.data);
        }
    }
    
    // - clear the report from local cache, retrieve from Bridge, and check again to be sure it got overwritten there too:
    [SBBComponent(SBBCacheManager) removeFromCacheObjectOfType:SBBDateRangeResourceList.entityName withId:identifier];
    items = [self retrieveItemsForReport:identifier from:startDate to:endDate dateOnly:YES];
    XCTAssert(items.count > index, @"Expected re-retrieved report to have at least %u items, but it only has %ld", index + 1, items.count);
    if (items.count > index) {
        SBBReportData *item = items[index];
        XCTAssertEqualObjects(item.localDate, localDateUpdating, @"Expected re-retrieved report to have the same localDate at the same index, but instead of %@ it's %@", localDateUpdating, item.localDate);
        XCTAssertEqualObjects(item.data, newData, @"Expected re-retrieved item to have data %@\nbut it has %@", newData, item.data);
    }
}

@end
