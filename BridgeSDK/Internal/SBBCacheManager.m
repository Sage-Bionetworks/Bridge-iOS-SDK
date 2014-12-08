//
//  SBBCacheManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 11/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBCacheManager.h"
@import UIKit;

// SBBBUNDLEID is a preprocessor macro defined in the build settings; this converts it to an NSString literal
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SBBBUNDLEIDSTRING @STRINGIZE2(SBBBUNDLEID)

static NSMutableDictionary *gCoreDataQueuesByPersistentStoreName;

@interface SBBCacheManager ()

@property (nonatomic, strong) NSCache *objectsCachedByTypeAndID;
@property (nonatomic, strong) dispatch_queue_t bridgeObjectCacheQueue;

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSPersistentStore *persistentStore;
@property (nonatomic, strong) NSString *persistentStoreName;
@property (nonatomic, strong) NSManagedObjectContext *cacheIOContext;

@property (nonatomic, weak) id appWillTerminateObserver;

@end


@implementation SBBCacheManager

+ (void)initialize
{
  gCoreDataQueuesByPersistentStoreName = [[NSMutableDictionary alloc] init];
}

+ (instancetype)defaultComponent
{
  static SBBCacheManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self cacheManagerWithPersistentStoreName:@"SBBDataModel.sqlite"];
  });
  
  return shared;
}

+ (instancetype)cacheManagerWithPersistentStoreName:(NSString *)storeName
{
  SBBCacheManager *cm = [[self alloc] init];
  cm.persistentStoreName = storeName;
  return cm;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self dispatchSyncToBridgeObjectCacheQueue:^{
            self.objectsCachedByTypeAndID = [[NSCache alloc] init];
            self.appWillTerminateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
                // TODO: Make sure the Core Data MOC is saved
            }];
        }];
    }
    
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.appWillTerminateObserver];
    [self discardCacheManagerCoreDataQueue];
}

#pragma mark - In-memory cache

- (dispatch_queue_t)bridgeObjectCacheQueue
{
  if (!_bridgeObjectCacheQueue) {
    _bridgeObjectCacheQueue = dispatch_queue_create("org.sagebase.BridgeObjectCacheQueue", DISPATCH_QUEUE_SERIAL);
  }
  
  return _bridgeObjectCacheQueue;
}

// BE CAREFUL never to allow this to be called recursively, even indirectly.
// The only way to ensure this is to never synchronously call out to anything
// in dispatchBlock that you can't absolutely guarantee will never get back here.
- (void)dispatchSyncToBridgeObjectCacheQueue:(dispatch_block_t)dispatchBlock
{
  dispatch_sync(self.bridgeObjectCacheQueue, dispatchBlock);
}

#pragma mark - CoreData cache

dispatch_queue_t CoreDataQueueForPersistentStoreName(NSString *name)
{
  dispatch_queue_t queue = [gCoreDataQueuesByPersistentStoreName objectForKey:name];
  if (!queue) {
    NSString *qName = [NSString stringWithFormat:@"org.sagebase.CoreDataQueueFor%@", [name capitalizedString]];
    queue = dispatch_queue_create([qName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    [gCoreDataQueuesByPersistentStoreName setObject:queue forKey:name];
  }
  
  return queue;
}

void removeCoreDataQueueForPersistentStoreName(NSString *name)
{
    [gCoreDataQueuesByPersistentStoreName setObject:nil forKey:name];
}

// BE CAREFUL never to allow this to be called recursively, even indirectly.
// The only way to ensure this is to never synchronously call out to anything
// in dispatchBlock that you can't absolutely guarantee will never get back here.
- (void)dispatchSyncToCacheManagerCoreDataQueue:(dispatch_block_t)dispatchBlock
{
  dispatch_sync(CoreDataQueueForPersistentStoreName(self.persistentStoreName), dispatchBlock);
}

- (void)discardCacheManagerCoreDataQueue
{
    removeCoreDataQueueForPersistentStoreName(self.persistentStoreName);
}

- (NSURL *)appDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
  if (_managedObjectModel != nil)
  {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle bundleWithIdentifier:SBBBUNDLEIDSTRING] URLForResource:@"SBBDataModel" withExtension:@"momd"];
  if (!modelURL) {
    modelURL = [[NSBundle bundleWithIdentifier:SBBBUNDLEIDSTRING] URLForResource:@"SBBDataModel" withExtension:@"mom"];
  }
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  //NSLog(@"_managedObjectModel: %@",_managedObjectModel);
  
  return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
  if (_persistentStoreCoordinator != nil)
  {
    return _persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [self storeURL];
  
  NSError *error = nil;
  
  // Automatic Lightweight Migration
  NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                  [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
  
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  
  self.persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
  
  if (!self.persistentStore)
  {
    /*
     NOTE: Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
     
     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed object model.
     Check the error message to determine what the actual problem was.
     
     
     If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
     
     If you encounter schema incompatibility errors during development, you can reduce their frequency by:
     * Simply deleting the existing store:
     
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
     
     * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
     [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
     
     Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
     
     */
    
    NSString *message = [NSString stringWithFormat:@"Unresolved error %@, %@", error, [error localizedDescription]];
    NSLog(@"%@", message);
    
    // removing store
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    // resetting _persistentStoreCoordinator
    _persistentStoreCoordinator = nil;
    
  }
  
  return _persistentStoreCoordinator;
}

- (NSURL *)storeURL
{
  return [[self appDocumentsDirectory] URLByAppendingPathComponent:self.persistentStoreName];
}

- (NSManagedObjectContext *)cacheIOContext
{
    if (!_cacheIOContext) {
        _cacheIOContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _cacheIOContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
        _cacheIOContext.undoManager = [[NSUndoManager alloc] init];
    }
    
    return _cacheIOContext;
}

- (BOOL)resetCache
{
  __block BOOL reset = NO;
  [self dispatchSyncToBridgeObjectCacheQueue:^{
    self.objectsCachedByTypeAndID = [[NSCache alloc] init];
    reset = [self resetDatabase];
  }];
  
  return reset;
}

- (BOOL)resetDatabase
{
  __block NSError *error;
  __block BOOL reset = NO;
  
  [self dispatchSyncToCacheManagerCoreDataQueue:^{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.appWillTerminateObserver];
    
    [_cacheIOContext performBlockAndWait:^{
      [_cacheIOContext reset];
      
      if (_persistentStoreCoordinator) {
        if (![_persistentStoreCoordinator removePersistentStore:self.persistentStore error:&error]) {
          NSLog(@"Unable to remove persistent store: error %@, %@", error, [error userInfo]);
          return;
        }
      }
      _persistentStoreCoordinator = nil;
      _cacheIOContext= nil;
      _managedObjectModel = nil;
      
      NSURL *storeURL = [self storeURL];
      if (![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]) {
        NSLog(@"Unable to delete SQLite db file at %@ : error %@, %@", storeURL, error, [error userInfo]);
        return;
      }
      
      reset = YES;
    }];
  }];
  
  return reset;
}


@end
