//
//  SBBObjectManagerInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBCacheManager.h"

@interface SBBObjectManager ()

@property (nonatomic, strong) NSMutableDictionary *classForType;
@property (nonatomic, strong) NSMutableDictionary *typeForClass;
@property (nonatomic, strong) NSMutableDictionary *mappingsForType;

@property (nonatomic, strong) id<SBBCacheManagerProtocol> cacheManager;

+ (instancetype)objectManagerWithCacheManager:(id<SBBCacheManagerProtocol>)cacheManager;

@end
