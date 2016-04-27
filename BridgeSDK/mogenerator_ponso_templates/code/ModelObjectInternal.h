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
- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager;

- (BOOL)isDirectlyCacheableWithContext:(NSManagedObjectContext *)context;

// This method MUST be called on the queue of the MOC in which managedObject exists.
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager;

// These methods MUST be called on cacheContext's queue.
- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager;
- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager;

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context;

@end