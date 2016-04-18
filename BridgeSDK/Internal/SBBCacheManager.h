//
//  SBBCacheManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

@import CoreData;
@import Foundation;
#import "SBBComponent.h"
#import "SBBAuthManager.h"
#import "BridgeSDKInternal.h"

@class SBBBridgeObject;
@class ModelObject;

@protocol SBBCacheManagerProtocol <NSObject>

- (SBBBridgeObject *)cachedObjectOfType:(NSString *)type withId:(NSString *)objectId createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedSingletonObjectOfType:(NSString *)type createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedObjectFromBridgeJSON:(id)json;

// use ModelObject as the parameter type because test case classes don't derive from SBBBridgeObject
// (because they're generated from a separate test data model)
- (NSManagedObject *)cachedObjectForBridgeObject:(ModelObject *)bridgeObject inContext:(NSManagedObjectContext *)context;

- (void)removeFromCacheObjectOfType:(NSString *)type withId:(NSString *)objectId;

- (NSManagedObjectContext *)cacheIOContext;

- (void)saveCacheIOContext;

- (NSString *)encryptionKey;

- (BOOL)resetCache;

// must be called in the cacheIOContext private queue
- (NSManagedObject *)managedObjectOfEntity:(NSEntityDescription *)entity withId:(NSString *)objectId atKeyPath:(NSString *)keyPath;

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

@property (nonatomic, strong) NSString *persistentStoreName;

+ (instancetype)cacheManagerWithDataModelName:(NSString *)modelName bundleId:(NSString *)bundleId storeType:(NSString *)storeType authManager:(id<SBBAuthManagerProtocol>)authManager;

@end
