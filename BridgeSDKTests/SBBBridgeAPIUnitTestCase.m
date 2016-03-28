//
//  SBBBridgeAPIUnitTestCase.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBNetworkManagerInternal.h"
#import "TestAdminAuthDelegate.h"

@interface SBBBridgeAPIUnitTestCase ()

@property (nonatomic, strong) NSURLSession *savedMainSession;

@end

@implementation SBBBridgeAPIUnitTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (!gSBBAppStudy) {
        gSBBAppStudy = @"ios-sdk-int-tests";
    }
    _mockURLSession = [MockURLSession new];
    SBBBridgeNetworkManager *bridgeNetMan = (SBBBridgeNetworkManager *)SBBComponent(SBBBridgeNetworkManager);
    _savedMainSession = bridgeNetMan.mainSession;
    bridgeNetMan.mainSession = _mockURLSession;
    
    [SBBComponentManager registerComponent:bridgeNetMan forClass:[SBBBridgeNetworkManager class]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    SBBBridgeNetworkManager *bridgeNetMan = (SBBBridgeNetworkManager *)SBBComponent(SBBBridgeNetworkManager);
    bridgeNetMan.mainSession = _savedMainSession;

    [super tearDown];
    [SBBComponentManager reset];
}

@end
