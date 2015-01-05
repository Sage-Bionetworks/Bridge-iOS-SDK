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

// SBBBUNDLEID is a preprocessor macro defined in the build settings; this converts it to an NSString literal
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SBBBUNDLEIDSTRING @STRINGIZE2(SBBBUNDLEID)

@class SBBBridgeObject;

@protocol SBBCacheManagerProtocol <NSObject>

- (SBBBridgeObject *)cachedObjectOfType:(NSString *)type withId:(NSString *)objectId createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedObjectFromBridgeJSON:(id)json;

- (NSManagedObjectContext *)cacheIOContext;

- (void)saveCacheIOContext;

- (NSString *)encryptionKey;

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

+ (instancetype)cacheManagerWithDataModelName:(NSString *)modelName bundleId:(NSString *)bundleId authManager:(id<SBBAuthManagerProtocol>)authManager;

@end
