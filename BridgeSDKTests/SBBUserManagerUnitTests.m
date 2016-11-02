//
//  SBBUserManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBUserManagerInternal.h"
#import "SBBUserProfile.h"
#import "SBBBridgeNetworkManager.h"

@interface SBBUserProfile (customFields)

@property (nonatomic, strong) NSString *customStringField;
@property (nonatomic, strong) NSDictionary *customDictField;
@property (nonatomic, strong) NSArray *customArrayField;

@end

@implementation SBBUserProfile (customFields)

@dynamic customStringField;
@dynamic customDictField;
@dynamic customArrayField;

@end


@interface SBBUserManagerUnitTests : SBBBridgeAPIUnitTestCase

@end

@implementation SBBUserManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetUserProfileWithCompletion
{
    SBBUserProfile *testUserProfile = [[SBBUserProfile alloc] init];
    testUserProfile.firstName = @"First";
    testUserProfile.lastName = @"Last";
    testUserProfile.email = @"email@fake.tld";
    testUserProfile.customStringField = @"customStringFieldContents";
    testUserProfile.customDictField = @{@"customDictFieldKey": @"customDictFieldValue"};
    testUserProfile.customArrayField = @[@"customArrayFieldValue1", @"customArrayFieldValue2"];
    
    NSDictionary *userProfileJSON = [self.objectManager bridgeJSONFromObject:testUserProfile];
    XCTAssert([[userProfileJSON objectForKey:@"customStringField"] isKindOfClass:[NSString class]], @"Custom string field serializes to NSString");
    XCTAssert([[userProfileJSON objectForKey:@"customDictField"] isKindOfClass:[NSString class]], @"Custom dictionary field serializes to NSString");
    XCTAssert([[userProfileJSON objectForKey:@"customArrayField"] isKindOfClass:[NSString class]], @"Custom array field serializes to NSString");
    [self.mockURLSession setJson:userProfileJSON andResponseCode:200 forEndpoint:kSBBUserProfileAPI andMethod:@"GET"];
    SBBUserManager *uMan = [SBBUserManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    [uMan getUserProfileWithCompletion:^(SBBUserProfile *userProfile, NSError *error) {
        XCTAssert([userProfile isKindOfClass:[SBBUserProfile class]], @"Converted incoming json to SBBUserProfile");
        XCTAssertEqualObjects(testUserProfile.customStringField, userProfile.customStringField, @"Custom string field: object equal to JSON");
        XCTAssertEqualObjects(testUserProfile.customDictField, userProfile.customDictField, @"Custom dict field: object equal to JSON");
        XCTAssertEqualObjects(testUserProfile.customArrayField, userProfile.customArrayField, @"Custom array field: object equal to JSON");
    }];
    [self.objectManager setupMappingForType:@"UserProfile" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"username": @"stringField"}];
    [self.mockURLSession setJson:userProfileJSON andResponseCode:200 forEndpoint:kSBBUserProfileAPI andMethod:@"GET"];
    [uMan getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        XCTAssert([userProfile isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
    }];
}

- (void)testGetDataGroupsWithCompletion
{
    NSDictionary *dataGroups =
    @{
      @"type": @"DataGroups",
      @"dataGroups": @[@"group1", @"group2", @"group3"]
      };
    [self.mockURLSession setJson:dataGroups andResponseCode:200 forEndpoint:kSBBUserDataGroupsAPI andMethod:@"GET"];
    SBBUserManager *uMan = [SBBUserManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    [self.objectManager setupMappingForType:@"DataGroups" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"dataGroups": @"jsonArrayField"}];
    [uMan getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        XCTAssert([dataGroups isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
    }];
}

@end
