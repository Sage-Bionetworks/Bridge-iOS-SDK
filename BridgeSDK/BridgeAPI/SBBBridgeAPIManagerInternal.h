//
//  SBBBridgeAPIManagerInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 2/25/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIManager.h"

@interface SBBBridgeAPIManager(internal)

- (NSString *)urlStringForManagerEndpoint:(NSString *)endpoint version:(NSString *)version;
- (NSString *)apiManagerName;

@end