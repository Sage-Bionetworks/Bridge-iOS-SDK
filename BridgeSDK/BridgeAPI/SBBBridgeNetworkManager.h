//
//  SBBBridgeNetworkManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 5/26/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import <BridgeSDK/BridgeSDK.h>

@protocol SBBBridgeNetworkManagerProtocol <SBBNetworkManagerProtocol>

@end

@interface SBBBridgeNetworkManager : SBBNetworkManager<SBBBridgeNetworkManagerProtocol>

- (instancetype)initWithAuthManager:(id<SBBAuthManagerProtocol>)authManager;

@end
