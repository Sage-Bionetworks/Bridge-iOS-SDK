//
//  SBBBridgeAPITestCase.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPITestCase.h"

@implementation SBBBridgeAPITestCase

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  self.mockNetworkManager = [[MockNetworkManager alloc] init];
  [SBBComponentManager registerComponent:_mockNetworkManager forClass:[SBBNetworkManager class]];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  [SBBComponentManager reset];
}

@end
