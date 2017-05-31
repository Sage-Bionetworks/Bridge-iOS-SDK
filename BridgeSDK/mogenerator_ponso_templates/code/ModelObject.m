/*
 Copyright 2011 Marko Karppinen & Co. LLC.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 ModelObject.m
 mogenerator / PONSO
 Created by Nikita Zhuk on 22.1.2011.
 */

#import "ModelObject.h"
#import "SBBComponentManager.h"
#import "SBBObjectManager.h"
#import "SBBObjectManagerInternal.h"
#import "SBBCacheManager.h"
#import "ModelObjectInternal.h"

@implementation ModelObject

- (id) initWithCoder: (NSCoder*) aDecoder
{
    self = [super init];
    if (self) {
        // Superclass implementation:
        // If we add ivars/properties, here's where we'll load them
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder*) aCoder
{
    // Superclass implementation:
    // If we add ivars/properties, here's where we'll save them
}

+ (id)createModelObjectFromFile:(NSString *)filePath
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return nil;
    }
    
    NSError *error = nil;
    NSData *plistData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
    if(!plistData)
    {
        NSLog(@"Couldn't read '%@' data from '%@': %@.", NSStringFromClass([self class]), filePath, error);
        return nil;
    }
    
    if([plistData length] == 0)
    {
        NSLog(@"Empty '%@' data found from '%@'.", NSStringFromClass([self class]), filePath);
        return nil;
    }
    
    NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                                    options:0
                                                                     format:NULL
                                                                      error:&error];
    if(!plist)
    {
        NSLog(@"Couldn't load '%@' data from '%@': %@.", NSStringFromClass([self class]), filePath, error);
        
        return nil;
    }
    
    id modelObject = [[self alloc] initWithDictionaryRepresentation:plist objectManager:SBBComponent(SBBObjectManager)];
    [modelObject awakeFromDictionaryRepresentationInit];
    
    return modelObject;
}

- (BOOL)writeToFile:(NSString *)filePath
{
    if(filePath == nil)
    {
        NSLog(@"File path was nil - cannot write to file.");
        return NO;
    }
    
    // Save this modelObject into plist
    NSDictionary *dict = [self dictionaryRepresentationFromObjectManager:SBBComponent(SBBObjectManager)];
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if(!plistData)
    {
        NSLog(@"Error while serializing model object of class '%@' into plist. Error: '%@'.", NSStringFromClass([self class]), error);
        
        return NO;
    }
    
    BOOL isDir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:[filePath stringByDeletingLastPathComponent] isDirectory:&isDir] || !isDir)
    {
        NSError *error = nil;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Couldn't create parent directory of file path '%@' for saving model object of class '%@': %@.", filePath,  NSStringFromClass([self class]), error);
            return NO;
        }
    }
    
    if(![plistData writeToFile:filePath atomically:YES])
    {
        NSLog(@"Error while saving model object of class '%@' into plist file %@.",  NSStringFromClass([self class]), filePath);
        return NO;
        
    }
    
    return YES;
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
    return [self initWithDictionaryRepresentation:dictionary objectManager:SBBComponent(SBBObjectManager)];
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    if((self = [super init]))
    {
        self.creatingObjectManager = objectManager;
        [self updateWithDictionaryRepresentation:dictionary objectManager:objectManager];
    }
    
    return self;
}

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary
{
    [self updateWithDictionaryRepresentation:dictionary objectManager:self.creatingObjectManager ?: SBBComponent(SBBObjectManager)];
}

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    self.sourceDictionaryRepresentation = dictionary;
}

- (void)reconcileWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerInternalProtocol>)objectManager
{
    // This method is only called during caching operations.
    
    // This default implementation just calls updateWithDictionaryRepresentation:objectManager: for
    // entities that aren't marked as having client-writable fields, either directly, or by implication
    // by virtue of being marked as extendable; otherwise it does nothing. Thus, for non-client-modifiable
    // objects the server version is always canonical, and for client-modifiable objects the locally
    // cached version takes precedence.
    
    // Subclasses can override this method to provide different behavior.
    NSManagedObjectContext *cacheContext = objectManager.cacheManager.cacheIOContext;
    NSEntityDescription *entity = [self entityForContext:cacheContext];
    if (!(entity.userInfo[@"hasClientWritableFields"] || entity.userInfo[@"isExtendable"])) {
        [self updateWithDictionaryRepresentation:dictionary objectManager:objectManager];
    }
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryRepresentationFromObjectManager:self.creatingObjectManager ?: SBBComponent(SBBObjectManager)];
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    return [NSDictionary dictionary];
}

- (void)awakeFromDictionaryRepresentationInit
{
    self.sourceDictionaryRepresentation = nil;
}

- (BOOL)isDirectlyCacheableWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityForContext:context];
    NSString *entityIDKeyPath = entity.userInfo[@"entityIDKeyPath"];
    
    return (entityIDKeyPath.length > 0);
}

+ (NSString *)entityName
{
    // generated subclasses will override this
    return nil;
}

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [self.class entityForContext:context];
}

+ (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    if (self = [super init]) {
        // generated subclasses will override this
    }
    
    return self;
}

- (void)saveToCoreDataCacheWithObjectManager:(id<SBBObjectManagerInternalProtocol>)objectManager
{
    // If objectManager doesn't define a cacheManager, or the generated code for this object doesn't
    // define an entity (because there's no entityIDKeyPath in the userInfo), this method does nothing
    if ([objectManager respondsToSelector:@selector(cacheManager)]) {
        id<SBBCacheManagerProtocol> cacheManager = objectManager.cacheManager;
        NSManagedObjectContext *cacheContext = cacheManager.cacheIOContext;
        NSEntityDescription *entity = [self entityForContext:cacheContext];
        if (entity) {
            NSString *entityIDKeyPath = entity.userInfo[@"entityIDKeyPath"];
            [cacheContext performBlockAndWait:^{
                // if there's an entityIDKeyPath, we're going to look for an existing object to update
                NSManagedObject *existingObject = nil;
                if (entityIDKeyPath.length) {
                    NSString *entityID = [self valueForKeyPath:entityIDKeyPath];
                    existingObject = [cacheManager managedObjectOfEntity:entity withId:entityID atKeyPath:entityIDKeyPath];
                }
                
                if (existingObject) {
                    [self updateManagedObject:existingObject withObjectManager:objectManager cacheManager:cacheManager];
                } else {
                    // no existing object found to update, so creating a new one
                    [self createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
                }
            }];
            
            [cacheManager saveCacheIOContext];
        }
    }
}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    // generated subclasses will override this
    return nil;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    // generated subclasses will override this
}

- (void)releaseManagedObject:(NSManagedObject *)managedObject inContext:(NSManagedObjectContext *)cacheContext
{
    // subclasses that are directly cacheable, and can be a member of more than one to-many relationship,
    // should override this to only delete when no longer a member of any of them
    [cacheContext deleteObject:managedObject];
}

- (void)dealloc
{
    self.sourceDictionaryRepresentation = nil;
}

#pragma mark key-value coding

- (id)valueForUndefinedKey:(NSString *)key
{
    // Handle paths like items[0], items[1], ...
    if ([key hasSuffix:@"]"])
    {
        NSRange startSubscript = [key rangeOfString:@"["];
        if (startSubscript.location != NSNotFound) {
            NSString *bareKey = [key substringToIndex:startSubscript.location];
            NSString *indexString = [key substringWithRange:NSMakeRange(startSubscript.location + 1, key.length - startSubscript.location - 2)];
            id containerObject = [self valueForKey:bareKey];
            if ([containerObject isKindOfClass:[NSArray class]]) {
                return containerObject[[indexString integerValue]];
            } else if ([containerObject isKindOfClass:[NSDictionary class]]) {
                return containerObject[indexString];
            }
        }
    }
    
    return [super valueForUndefinedKey:key];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    // Note: ModelObject is not autoreleased because we are in copy method.
    id<SBBObjectManagerProtocol> oMan = self.creatingObjectManager ?: SBBComponent(SBBObjectManager);
    ModelObject *copy = [[[self class] alloc] initWithDictionaryRepresentation:[self dictionaryRepresentationFromObjectManager:oMan] objectManager:oMan];
    [copy awakeFromDictionaryRepresentationInit];
    
    return copy;
}

@synthesize sourceDictionaryRepresentation;

@end


@implementation NSMutableDictionary (PONSONSMutableDictionaryAdditions)

- (void)setObjectIfNotNil:(id)obj forKey:(NSString *)key
{
    if(obj == nil)
        return;
    
    [self setObject:obj forKey:key];
}

@end
