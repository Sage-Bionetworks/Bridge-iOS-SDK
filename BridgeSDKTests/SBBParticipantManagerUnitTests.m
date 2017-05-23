//
//  SBBParticipantManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 12/16/16.
//  Copyright (c) 2016 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBParticipantManagerInternal.h"
#import "SBBStudyParticipant.h"
#import "SBBStudyParticipantCustomAttributes.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBUserSessionInfo.h"
#import "ModelObjectInternal.h"

@interface SBBStudyParticipantCustomAttributes (customFields)

@property (nonatomic, strong) NSString *customStringField;
@property (nonatomic, strong) NSDictionary *customDictField;
@property (nonatomic, strong) NSArray *customArrayField;

@end

@implementation SBBStudyParticipantCustomAttributes (customFields)

@dynamic customStringField;
@dynamic customDictField;
@dynamic customArrayField;

@end


@interface SBBParticipantManagerUnitTests : SBBBridgeAPIUnitTestCase

@property (nonatomic, strong) NSSet<NSString *> *testDataGroups;
@property (nonatomic, strong) NSDictionary *testParticipantJSON;
@property (nonatomic, strong) SBBStudyParticipant *testParticipant;
@property (nonatomic, strong) SBBStudyParticipantCustomAttributes *testCustomAttributes;

@end

@implementation SBBParticipantManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (gSBBUseCache) {
        // a lot of the Participant Manager code makes the assumption that if we've enabled caching, then
        // once we've signed in for the first time, there will be a cached StudyParticipant (derived from
        // the UserSessionInfo received from the signIn endpoint). So, make sure that's the case.
        NSArray *dataGroupsJSON = @[@"group1", @"group2", @"group3"];
        _testDataGroups = [NSSet setWithArray:dataGroupsJSON];
        
        _testCustomAttributes = [[SBBStudyParticipantCustomAttributes alloc] init];
        _testCustomAttributes.customStringField = @"customStringFieldContents";
        _testCustomAttributes.customDictField = @{@"customDictFieldKey": @"customDictFieldValue"};
        _testCustomAttributes.customArrayField = @[@"customArrayFieldValue1", @"customArrayFieldValue2"];

        _testParticipant = [[SBBStudyParticipant alloc] init];
        _testParticipant.attributes = _testCustomAttributes;
        _testParticipant.firstName = @"First";
        _testParticipant.lastName = @"Last";
        _testParticipant.email = @"email@fake.tld";
        _testParticipant.dataGroups = _testDataGroups;
        
        _testParticipantJSON = [self.objectManager bridgeJSONFromObject:_testParticipant];
        
        NSMutableDictionary *userSessionInfoJSON = [_testParticipantJSON mutableCopy];
        userSessionInfoJSON[NSStringFromSelector(@selector(sessionToken))] = @"fake-session-token";
        userSessionInfoJSON[NSStringFromSelector(@selector(type))] = [SBBUserSessionInfo entityName];
        
        // this is where the StudyParticipant gets cached by deriving it from UserSessionInfo
        __unused SBBUserSessionInfo *userSessionInfo = [self.objectManager objectFromBridgeJSON:userSessionInfoJSON];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class
    [(id <SBBParticipantManagerInternalProtocol>)SBBComponent(SBBParticipantManager) clearUserInfoFromCache];
    [super tearDown];
}

- (void)testGetParticipantRecordWithCompletion
{
    NSDictionary *attributesJSON = _testParticipantJSON[NSStringFromSelector(@selector(attributes))];
    XCTAssert([[attributesJSON objectForKey:@"customStringField"] isKindOfClass:[NSString class]], @"Custom string field serializes to NSString");
    XCTAssert([[attributesJSON objectForKey:@"customDictField"] isKindOfClass:[NSString class]], @"Custom dictionary field serializes to NSString");
    XCTAssert([[attributesJSON objectForKey:@"customArrayField"] isKindOfClass:[NSString class]], @"Custom array field serializes to NSString");
    [self.mockURLSession setJson:_testParticipantJSON andResponseCode:200 forEndpoint:kSBBParticipantAPI andMethod:@"GET"];
    SBBParticipantManager *pMan = [SBBParticipantManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    [pMan getParticipantRecordWithCompletion:^(SBBStudyParticipant *participant, NSError *error) {
        XCTAssert([participant isKindOfClass:[SBBStudyParticipant class]], @"Converted incoming json to SBBStudyParticipant");
        XCTAssertEqualObjects(_testParticipant.attributes.customStringField, participant.attributes.customStringField, @"Custom string field: object equal to original");
        XCTAssertEqualObjects(_testParticipant.attributes.customDictField, participant.attributes.customDictField, @"Custom dict field: object equal to original");
        XCTAssertEqualObjects(_testParticipant.attributes.customArrayField, participant.attributes.customArrayField, @"Custom array field: object equal to original");
    }];
    [self.objectManager setupMappingForType:@"StudyParticipant" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"lastName": @"stringField"}];
    [self.mockURLSession setJson:_testParticipantJSON andResponseCode:200 forEndpoint:kSBBParticipantAPI andMethod:@"GET"];
    [pMan getParticipantRecordWithCompletion:^(id participant, NSError *error) {
        XCTAssert([participant isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
    }];
}

- (void)testGetDataGroupsWithCompletion
{
    [self.mockURLSession setJson:_testParticipantJSON andResponseCode:200 forEndpoint:kSBBParticipantAPI andMethod:@"GET"];
    SBBParticipantManager *pMan = [SBBParticipantManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    [pMan getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        XCTAssert([dataGroups isKindOfClass:[NSSet class]], @"Retrieved data groups");
    }];
}

- (void)testUpdateDataGroups
{
    SBBParticipantManager *pMan = [SBBParticipantManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    
    XCTestExpectation *expectSetParticipant = [self expectationWithDescription:@"Set study participant in cache by fetching it"];
    [self.mockURLSession setJson:_testParticipantJSON andResponseCode:200 forEndpoint:kSBBParticipantAPI andMethod:@"GET"];
    [pMan getParticipantRecordWithCompletion:^(SBBStudyParticipant *participant, NSError *error) {
        XCTAssert([participant isKindOfClass:[SBBStudyParticipant class]], @"Converted incoming json to SBBStudyParticipant");
        XCTAssertEqualObjects(_testParticipant.attributes.customStringField, participant.attributes.customStringField, @"Custom string field: object equal to original");
        XCTAssertEqualObjects(_testParticipant.attributes.customDictField, participant.attributes.customDictField, @"Custom dict field: object equal to original");
        XCTAssertEqualObjects(_testParticipant.attributes.customArrayField, participant.attributes.customArrayField, @"Custom array field: object equal to original");
        [expectSetParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout setting study participant record in cache: %@", error);
        }
    }];
    
    XCTestExpectation *expectUpdatedParticipant = [self expectationWithDescription:@"Updated study participant"];

    [self.mockURLSession setJson:nil andResponseCode:500 forEndpoint:kSBBParticipantAPI andMethod:@"POST"];
    NSSet<NSString *> *groups = [NSSet setWithArray:@[@"group1", @"group2", @"group4"]];
    [pMan updateDataGroupsWithGroups:groups completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        // now check that it's updated in local cache in spite of "server error"
        SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedSingletonObjectOfType:SBBStudyParticipant.entityName createIfMissing:NO];
        XCTAssertEqualObjects(groups, cachedParticipant.dataGroups, @"Expected data groups to be %@ but got %@", groups, cachedParticipant.dataGroups);
        [expectUpdatedParticipant fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout updating study participant: %@", error);
        }
    }];
}

@end
