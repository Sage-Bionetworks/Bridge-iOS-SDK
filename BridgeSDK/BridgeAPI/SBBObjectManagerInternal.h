//
//  SBBObjectManagerInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

@import CoreData;

@interface SBBObjectManager ()

@property (nonatomic, strong) NSMutableDictionary *classForType;
@property (nonatomic, strong) NSMutableDictionary *typeForClass;
@property (nonatomic, strong) NSMutableDictionary *mappingsForType;

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSPersistentStore *persistentStore;

+ (NSManagedObjectContext *)

@end
