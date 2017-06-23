//
//  SBBObjectManagerInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBCacheManager.h"
#import "SBBObjectManager.h"

@protocol SBBObjectManagerInternalProtocol <SBBObjectManagerProtocol>

@property (nonatomic, strong) id<SBBCacheManagerProtocol> cacheManager;
@property (nonatomic, assign) BOOL bypassCache;

- (id)mappedObjectForBridgeObject:(SBBBridgeObject *)bridgeObject;

@end

@interface SBBObjectManager () <SBBObjectManagerInternalProtocol>

@property (nonatomic, strong) NSMutableDictionary *classForType;
@property (nonatomic, strong) NSMutableDictionary *typeForClass;
@property (nonatomic, strong) NSMutableDictionary *mappingsForType;

+ (instancetype)objectManagerWithCacheManager:(id<SBBCacheManagerProtocol>)cacheManager;
+ (Class)bridgeClassFromType:(NSString *)type;

@end
