//
//  SBBResourceList.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBResourceList.h instead.
//

#import "_SBBResourceList.h"
#import "NSDate+SBBAdditions.h"

#import "SBBBridgeObject.h"

@interface _SBBResourceList()
@property (nonatomic, strong, readwrite) NSArray *items;

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (ResourceList)

@property (nonatomic, strong) NSNumber* total;

@property (nonatomic, assign) int64_t totalValue;

@property (nonatomic, strong, readonly) NSArray *items;

- (void)addItemsObject:(SBBBridgeObject*)value_ settingInverse: (BOOL) setInverse;
- (void)addItemsObject:(SBBBridgeObject*)value_;
- (void)removeItemsObjects;
- (void)removeItemsObject:(SBBBridgeObject*)value_ settingInverse: (BOOL) setInverse;
- (void)removeItemsObject:(SBBBridgeObject*)value_;

- (void)insertObject:(SBBBridgeObject*)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject*)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)values;

@end

/** \ingroup DataModel */

@implementation _SBBResourceList

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)totalValue
{
	return [self.total longLongValue];
}

- (void)setTotalValue:(int64_t)value_
{
	self.total = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.total = [dictionary objectForKey:@"total"];

		for(id objectRepresentationForDict in [dictionary objectForKey:@"items"])
		{

SBBBridgeObject *itemsObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

			[self addItemsObject:itemsObj];
		}
	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.total forKey:@"total"];

    if([self.items count] > 0)
	{

		NSMutableArray *itemsRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.items count]];
		for(SBBBridgeObject *obj in self.items)
		{
			[itemsRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:itemsRepresentationsForDictionary forKey:@"items"];

	}

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBBridgeObject *itemsObj in self.items)
	{
		[itemsObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{

    if (self == [super init]) {

        self.total = managedObject.total;

		for(NSManagedObject *itemsManagedObj in managedObject.items)
		{
        SBBBridgeObject *itemsObj = [[SBBBridgeObject alloc] initWithManagedObject:itemsManagedObj];
        if(itemsObj != nil)
        {
            [self addItemsObject:itemsObj];
        }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    [cacheContext performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ResourceList" inManagedObjectContext:cacheContext];
    }];

    managedObject.total = self.total;

    if([self.items count] > 0)
	{

		for(SBBBridgeObject *obj in self.items)
		{
        NSManagedObject *relObj = [obj saveToContext:cacheContext withObjectManager:objectManager];
        [managedObject addItemsObject:relObj];
		}

	}

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

- (void)addItemsObject:(SBBBridgeObject*)value_ settingInverse: (BOOL) setInverse
{
    if(self.items == nil)
	{

		self.items = [NSMutableArray array];

	}

	[(NSMutableArray *)self.items addObject:value_];
	if (setInverse == YES) {
	    [value_ setResourceList: (SBBResourceList*)self settingInverse: NO];
	}
}
- (void)addItemsObject:(SBBBridgeObject*)value_
{
    [self addItemsObject:(SBBBridgeObject*)value_ settingInverse: YES];
}

- (void)removeItemsObjects
{

	self.items = [NSMutableArray array];

}

- (void)removeItemsObject:(SBBBridgeObject*)value_ settingInverse: (BOOL) setInverse
{
    if (setInverse == YES) {
        [value_ setResourceList: nil settingInverse: NO];
    }
    [(NSMutableArray *)self.items removeObject:value_];
}

- (void)removeItemsObject:(SBBBridgeObject*)value_
{
    [self removeItemsObject:(SBBBridgeObject*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBBridgeObject*)value inItemsAtIndex:(NSUInteger)idx {
    [self insertObject:value inItemsAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBBridgeObject*)value inItemsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.items insertObject:value atIndex:idx];
    if (setInverse == YES) {
    [value setResourceList:(SBBResourceList*)self settingInverse: NO];
    }
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx {
    [self removeObjectFromItemsAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBBridgeObject *object = [self.items objectAtIndex:idx];
    [self removeItemsObject:object settingInverse:YES];
}

- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertItems:value atIndexes:indexes settingInverse:YES];
}

- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.items insertObjects:value atIndexes:indexes];
    if (setInverse == YES) {
        for (SBBBridgeObject* object in value) {
            [object setResourceList:(SBBResourceList*)self settingInverse: NO];
        }
    }
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes {
    [self removeItemsAtIndexes:indexes settingInverse:YES];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsRemoved = [(NSMutableArray *)self.items objectsAtIndexes:indexes];
        for (SBBBridgeObject* object in objectsRemoved) {
            [object setResourceList:nil settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.items removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject*)value {
    [self replaceObjectInItemsAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject*)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    SBBBridgeObject* objectReplaced = [(NSMutableArray *)self.items objectAtIndex:idx];
    [objectReplaced setResourceList:nil settingInverse: NO];
    [value setResourceList:(SBBResourceList*)self settingInverse: NO];
    }
    [(NSMutableArray *)self.items replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)value {
    [self replaceItemsAtIndexes:indexes withItems:value settingInverse:YES];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsReplaced = [(NSMutableArray *)self.items objectsAtIndexes:indexes];
        for (SBBBridgeObject* object in objectsReplaced) {
            [object setResourceList:nil settingInverse: NO];
        }
        for (SBBBridgeObject* object in value) {
            [object setResourceList:(SBBResourceList*)self settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.items replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
