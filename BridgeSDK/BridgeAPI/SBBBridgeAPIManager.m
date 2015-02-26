//
//  SBBBridgeAPIManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/10/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"

@interface SBBBridgeAPIManager ()

@property (nonatomic, strong) id<SBBNetworkManagerProtocol> networkManager;
@property (nonatomic, strong) id<SBBAuthManagerProtocol> authManager;
@property (nonatomic, strong) id<SBBObjectManagerProtocol> objectManager;

@end


@implementation SBBBridgeAPIManager

+ (instancetype)instanceWithRegisteredDependencies
{
  return [self managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
}

+ (instancetype)managerWithAuthManager:(id<SBBAuthManagerProtocol>)authManager networkManager:(id<SBBNetworkManagerProtocol>)networkManager objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  SBBBridgeAPIManager *manager = [[self alloc] init];
  manager.networkManager = networkManager;
  manager.authManager = authManager;
  manager.objectManager = objectManager;
  
  return manager;
}

- (NSString *)apiManagerName
{
    // subclasses must override
    return  nil;
}

- (NSString *)urlStringForManagerEndpoint:(NSString *)endpoint version:(NSString *)version
{
    NSString *urlForEndpoint = [NSString stringWithFormat:@"/api/%@/%@%@", version, [self apiManagerName], endpoint];

    return urlForEndpoint;
}

@end
