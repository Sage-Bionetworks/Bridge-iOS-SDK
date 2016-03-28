//
//  SBBUserManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBUserManagerInternal.h"

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
    NSDictionary *userProfile =
    @{
      @"type": @"UserProfile",
      @"firstName": @"First",
      @"lastName": @"Last",
      @"username": @"1337p4t13nt",
      @"email": @"email@fake.tld"
      };
    [self.mockURLSession setJson:userProfile andResponseCode:200 forEndpoint:kSBBUserProfileAPI andMethod:@"GET"];
    SBBObjectManager *oMan = [SBBObjectManager objectManager];
    SBBUserManager *uMan = [SBBUserManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:oMan];
    [oMan setupMappingForType:@"UserProfile" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"username": @"stringField"}];
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
    SBBObjectManager *oMan = [SBBObjectManager objectManager];
    SBBUserManager *uMan = [SBBUserManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:oMan];
    [oMan setupMappingForType:@"DataGroups" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"dataGroups": @"jsonArrayField"}];
    [uMan getDataGroupsWithCompletion:^(id dataGroups, NSError *error) {
        XCTAssert([dataGroups isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
    }];
}

@end
