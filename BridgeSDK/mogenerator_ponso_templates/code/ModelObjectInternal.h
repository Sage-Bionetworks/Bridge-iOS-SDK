//
//  ModelObjectInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBObjectManagerInternal.h"

@interface ModelObject ()

// This method MUST be called on the queue of the MOC in which managedObject exists.
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject;

// This method MUST be called on cacheContext's queue.
- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager;

@end