//
//  SBBProfileManagerTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPITestCase.h"

@interface SBBProfileManagerTests : SBBBridgeAPITestCase

@end

@implementation SBBProfileManagerTests

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
  [self.mockURLSession setJson:userProfile andResponseCode:200 forEndpoint:@"/api/v1/profile" andMethod:@"GET"];
  SBBObjectManager *oMan = [SBBObjectManager objectManager];
  SBBProfileManager *pMan = [SBBProfileManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:oMan];
  [oMan setupMappingForType:@"UserProfile" toClass:[SBBTestBridgeObject class] fieldToPropertyMappings:@{@"username": @"stringField"}];
  [pMan getUserProfileWithCompletion:^(id userProfile, NSError *error) {
    XCTAssert([userProfile isKindOfClass:[SBBTestBridgeObject class]], @"Converted incoming json to mapped class");
  }];
}

@end
