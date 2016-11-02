//
//  SBBBridgeAPIUnitTestCase.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <XCTest/XCTest.h>
@import BridgeSDK;
#import "MockURLSession.h"
#import "SBBTestBridgeObject.h"
#import "SBBComponentManager.h"
#import "SBBCacheManager.h"

@interface SBBBridgeAPIUnitTestCase : XCTestCase

@property (nonatomic, strong) MockURLSession *mockURLSession;
@property (nonatomic, strong) MockURLSession *mockBackgroundURLSession;

@property (nonatomic, strong) SBBCacheManager *cacheManager;
@property (nonatomic, strong) id<SBBObjectManagerProtocol> objectManager;

@end
