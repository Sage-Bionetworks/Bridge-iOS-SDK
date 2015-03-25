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

+ (void)setupWithStudy:(NSString *)study
{
    [self setupWithStudy:study environment:gDefaultEnvironment];
}

+ (void)setupWithAppPrefix:(NSString *)appPrefix
{
    [self setupWithStudy:appPrefix];
}

+ (void)setupWithStudy:(NSString *)study environment:(SBBEnvironment)environment
{
    gSBBAppStudy = study;
    gSBBDefaultEnvironment = environment;
    [SBBComponent(SBBNetworkManager) restoreBackgroundSession:kBackgroundSessionIdentifier completionHandler:nil];
}

+ (void)setupWithAppPrefix:(NSString *)appPrefix environment:(SBBEnvironment)environment
{
    [self setupWithStudy:appPrefix environment:environment];
}

@end
