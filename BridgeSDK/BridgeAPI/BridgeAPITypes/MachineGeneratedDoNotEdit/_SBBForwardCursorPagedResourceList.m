//
//  _SBBForwardCursorPagedResourceList.m
//
//	Copyright (c) 2014-2017 Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBForwardCursorPagedResourceList.m instead.
//

#import "_SBBForwardCursorPagedResourceList.h"
#import "_SBBForwardCursorPagedResourceListInternal.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBBridgeObject.h"

@interface _SBBForwardCursorPagedResourceList()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *items;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (ForwardCursorPagedResourceList)

@property (nullable, nonatomic, retain) NSNumber* hasNext;

@property (nullable, nonatomic, retain) NSDate* lastOffsetBy__;

@property (nullable, nonatomic, retain) NSString* listID__;

@property (nullable, nonatomic, retain) NSDate* offsetBy;

@property (nullable, nonatomic, retain) NSNumber* pageSize;

@property (nullable, nonatomic, retain) NSDate* scheduledOnEnd;

@property (nullable, nonatomic, retain) NSDate* scheduledOnStart;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *items;

- (void)addItemsObject:(NSManagedObject *)value;
- (void)removeItemsObject:(NSManagedObject *)value;
- (void)addItems:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeItems:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray<NSManagedObject *> *)values;

@end

@implementation _SBBForwardCursorPagedResourceList

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)hasNextValue
{
	return [self.hasNext boolValue];
}

- (void)setHasNextValue:(BOOL)value_
{
	self.hasNext = [NSNumber numberWithBool:value_];
}

- (int16_t)pageSizeValue
{
	return [self.pageSize shortValue];
}

- (void)setPageSizeValue:(int16_t)value_
{
	self.pageSize = [NSNumber numberWithShort:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.hasNext = [dictionary objectForKey:@"hasNext"];

    // Set the entity ID key path with the key value if available, even when it's not normally
    // included in the PONSO dictionary
    NSString *keyValue = [dictionary objectForKey:@"listID__"];
    if (keyValue)
        self.listID__ = keyValue;

    self.offsetBy = [NSDate dateWithISO8601String:[dictionary objectForKey:@"offsetBy"]];

    self.pageSize = [dictionary objectForKey:@"pageSize"];

    self.scheduledOnEnd = [NSDate dateWithISO8601String:[dictionary objectForKey:@"scheduledOnEnd"]];

    self.scheduledOnStart = [NSDate dateWithISO8601String:[dictionary objectForKey:@"scheduledOnStart"]];

    // overwrite the old items relationship entirely rather than adding to it
    [self removeItemsObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"items"])
    {
        SBBBridgeObject *itemsObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addItemsObject:itemsObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.hasNext forKey:@"hasNext"];

    [dict setObjectIfNotNil:[self.offsetBy ISO8601String] forKey:@"offsetBy"];

    [dict setObjectIfNotNil:self.pageSize forKey:@"pageSize"];

    [dict setObjectIfNotNil:[self.scheduledOnEnd ISO8601String] forKey:@"scheduledOnEnd"];

    [dict setObjectIfNotNil:[self.scheduledOnStart ISO8601String] forKey:@"scheduledOnStart"];

    if ([self.items count] > 0)
	{

		NSMutableArray *itemsRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.items count]];

		for (SBBBridgeObject *obj in self.items)
        {
            [itemsRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:itemsRepresentationsForDictionary forKey:@"items"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBBridgeObject *itemsObj in self.items)
	{
		[itemsObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"ForwardCursorPagedResourceList";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.hasNext = managedObject.hasNext;

        self.lastOffsetBy__ = managedObject.lastOffsetBy__;

        self.listID__ = managedObject.listID__;

        self.offsetBy = managedObject.offsetBy;

        self.pageSize = managedObject.pageSize;

        self.scheduledOnEnd = managedObject.scheduledOnEnd;

        self.scheduledOnStart = managedObject.scheduledOnStart;

		for (NSManagedObject *itemsManagedObj in managedObject.items)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:itemsManagedObj.entity.name];
            SBBBridgeObject *itemsObj = [[objectClass alloc] initWithManagedObject:itemsManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (itemsObj != nil)
            {
                [self addItemsObject:itemsObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ForwardCursorPagedResourceList" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [cacheManager cachedObjectForBridgeObject:self inContext:cacheContext];
    if (managedObject) {
        [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    }

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.hasNext = ((id)self.hasNext == [NSNull null]) ? nil : self.hasNext;

    managedObject.lastOffsetBy__ = ((id)self.lastOffsetBy__ == [NSNull null]) ? nil : self.lastOffsetBy__;

    managedObject.listID__ = ((id)self.listID__ == [NSNull null]) ? nil : self.listID__;

    managedObject.offsetBy = ((id)self.offsetBy == [NSNull null]) ? nil : self.offsetBy;

    managedObject.pageSize = ((id)self.pageSize == [NSNull null]) ? nil : self.pageSize;

    managedObject.scheduledOnEnd = ((id)self.scheduledOnEnd == [NSNull null]) ? nil : self.scheduledOnEnd;

    managedObject.scheduledOnStart = ((id)self.scheduledOnStart == [NSNull null]) ? nil : self.scheduledOnStart;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSOrderedSet *itemsCopy = [managedObject.items copy];

    // now remove all items from the existing relationship
    // to work pre-iOS 10, we have to work around this issue: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    NSMutableOrderedSet *workingItemsSet = [managedObject mutableOrderedSetValueForKey:NSStringFromSelector(@selector(items))];
    [workingItemsSet removeAllObjects];

    // now put the "new" items, if any, into the relationship
    if ([self.items count] > 0) {
		for (SBBBridgeObject *obj in self.items) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [workingItemsSet addObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in itemsCopy) {
        if (![relMo valueForKey:@"forwardCursorPagedResourceList"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    itemsCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addItemsObject:(SBBBridgeObject*)value_ settingInverse: (BOOL) setInverse
{
    if (self.items == nil)
	{

		self.items = [NSMutableArray array];

	}

	[(NSMutableArray *)self.items addObject:value_];

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

}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes {
    [self removeItemsAtIndexes:indexes settingInverse:YES];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.items removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject*)value {
    [self replaceObjectInItemsAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.items replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)value {
    [self replaceItemsAtIndexes:indexes withItems:value settingInverse:YES];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.items replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
