//
//  ModelObjectInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBObjectManagerInternal.h"
#import "ModelObject.h"

@interface ModelObject ()

@property (nonatomic, weak) id<SBBObjectManagerProtocol> creatingObjectManager;

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager;
- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager;

// This method is only called by the cache manager, and is always followed by updating the object to CoreData cache,
// so no need to do so from within the method. Override it to customize how the Bridge server version of an object
// gets reconciled with the locally-cached version. The default behavior is server-wins for non-client-writable objects,
// and cache-wins for objects with any client-writable fields.
- (void)reconcileWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerInternalProtocol>)objectManager;

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager;

- (BOOL)isDirectlyCacheableWithContext:(NSManagedObjectContext *)context;

// This method MUST be called on the queue of the MOC in which managedObject exists.
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager;

// These methods MUST be called on cacheContext's queue.
- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager;
- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager;
- (void)releaseManagedObject:(NSManagedObject *)managedObject inContext:(NSManagedObjectContext *)cacheContext;

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context;

+ (NSString *)entityName;
+ (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context;

@end
