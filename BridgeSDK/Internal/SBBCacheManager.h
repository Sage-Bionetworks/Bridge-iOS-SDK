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

@protocol SBBCacheManagerProtocol <NSObject>

- (SBBBridgeObject *)cachedObjectOfType:(NSString *)type withId:(NSString *)objectId createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedSingletonObjectOfType:(NSString *)type createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedObjectFromBridgeJSON:(id)json;

- (NSManagedObjectContext *)cacheIOContext;

- (void)saveCacheIOContext;

- (NSString *)encryptionKey;

// must be called in the cacheIOContext private queue
- (NSManagedObject *)managedObjectOfEntity:(NSEntityDescription *)entity withId:(NSString *)objectId atKeyPath:(NSString *)keyPath;

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

+ (instancetype)cacheManagerWithDataModelName:(NSString *)modelName bundleId:(NSString *)bundleId authManager:(id<SBBAuthManagerProtocol>)authManager;

@end
