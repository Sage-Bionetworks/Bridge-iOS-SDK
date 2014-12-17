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
#import "SBBAuthManagerInternal.h"

@class SBBBridgeObject;

@protocol SBBCacheManagerProtocol <NSObject>

- (SBBBridgeObject *)cachedObjectOfType:(NSString *)type withId:(NSString *)objectId createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedObjectFromBridgeJSON:(id)json;

- (NSManagedObjectContext *)cacheIOContext;

- (NSString *)encryptionKey;

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

+ (instancetype)cacheManagerWithPersistentStoreName:(NSString *)storeName authManager:(id<SBBAuthManagerProtocol>)authManager;

@end
