//
//  BridgeSDK.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/16/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "BridgeSDK.h"
#import "SBBAuthManagerInternal.h"

@implementation BridgeSDK

+ (void)setupWithAppPrefix:(NSString *)appPrefix
{
  [self setupWithAppPrefix:appPrefix environment:gDefaultEnvironment];
}

+ (void)setupWithAppPrefix:(NSString *)appPrefix environment:(SBBEnvironment)environment
{
  gSBBAppURLPrefix = appPrefix;
  gSBBDefaultEnvironment = environment;
}

@end
