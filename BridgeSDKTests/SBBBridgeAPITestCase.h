//
//  SBBBridgeAPITestCase.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <XCTest/XCTest.h>
@import BridgeSDK;
#import "MockNetworkManager.h"
#import "SBBTestBridgeObject.h"

@interface SBBBridgeAPITestCase : XCTestCase

@property (nonatomic, strong) MockNetworkManager *mockNetworkManager;

@end
