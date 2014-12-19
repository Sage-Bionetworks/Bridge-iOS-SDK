//
//  SBBBridgeObject.m
//	
//  $Id$
//

#import "SBBBridgeObject.h"
#import "SBBObjectManager.h"
#import "SBBComponentManager.h"
#import "ModelObjectInternal.h"

@implementation SBBBridgeObject

#pragma mark Abstract method overrides

// Custom logic goes here.

- (id)init
{
  if (self = [super init]) {
    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"SBB"]) {
      // set default type string (the property is read-only so we have to use the back door)
      NSDictionary *dict = @{@"type": [className substringFromIndex:3]};
      self = [super initWithDictionaryRepresentation:dict objectManager:SBBComponent(SBBObjectManager)];
    }
  }
  
  return self;
}

- (instancetype)initFromCoreDataCacheWithID:(NSString *)bridgeObjectID objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    if (self = [super init]) {
        // If objectManager doesn't define a cacheManager, or the generated code for this object doesn't
        // define an entity (because there's no entityIDKeyPath in the userInfo), this method returns nil
        if (![objectManager respondsToSelector:@selector(cacheManager)]) {
            return nil;
        }
        
        id<SBBCacheManagerProtocol> cacheManager = [(id)objectManager cacheManager];
        NSManagedObjectContext *cacheContext = cacheManager.cacheIOContext;
        
        NSEntityDescription *entity = [self entityForContext:cacheContext];
        if (!entity) {
            return nil;
        }
        
        self = [cacheManager cachedObjectOfType:entity.name withId:bridgeObjectID createIfMissing:YES];
        if (!self) {
            NSLog(@"Failed to create a managed object of type '%@' with id '%@'", entity.name, bridgeObjectID);
            return nil;
        }
    }
    
    return self;
}

@end
