//
//  _SBBTestBridgeObject.m
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
// Make changes to SBBTestBridgeObject.m instead.
//

#import "_SBBTestBridgeObject.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBBridgeObject_test.h"
#import "SBBTestBridgeSubObject.h"
#import "SBBTestBridgeSubObject.h"

@interface _SBBTestBridgeObject()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *bridgeObjectArrayField;

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *bridgeObjectSetField;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (TestBridgeObject)

@property (nullable, nonatomic, retain) NSDate* dateField;

@property (nullable, nonatomic, retain) NSNumber* doubleField;

@property (nullable, nonatomic, retain) NSNumber* floatField;

@property (nullable, nonatomic, retain) NSString* guid;

@property (nullable, nonatomic, retain) NSArray* jsonArrayField;

@property (nullable, nonatomic, retain) NSDictionary* jsonDictField;

@property (nullable, nonatomic, retain) NSNumber* longField;

@property (nullable, nonatomic, retain) NSNumber* longLongField;

@property (nullable, nonatomic, retain) NSNumber* shortField;

@property (nullable, nonatomic, retain) NSString* stringField;

@property (nullable, nonatomic, retain) NSNumber* uLongField;

@property (nullable, nonatomic, retain) NSNumber* uLongLongField;

@property (nullable, nonatomic, retain) NSNumber* uShortField;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *bridgeObjectArrayField;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *bridgeObjectSetField;

@property (nullable, nonatomic, retain) NSManagedObject *bridgeSubObjectField;

- (void)addBridgeObjectArrayFieldObject:(NSManagedObject *)value;
- (void)removeBridgeObjectArrayFieldObject:(NSManagedObject *)value;
- (void)addBridgeObjectArrayField:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeBridgeObjectArrayField:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)insertBridgeObjectArrayField:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBridgeObjectArrayFieldAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes withBridgeObjectArrayField:(NSArray<NSManagedObject *> *)values;

- (void)addBridgeObjectSetFieldObject:(NSManagedObject *)value;
- (void)removeBridgeObjectSetFieldObject:(NSManagedObject *)value;

- (void)addBridgeObjectSetField:(NSSet<NSManagedObject *> *)values;
- (void)removeBridgeObjectSetField:(NSSet<NSManagedObject *> *)values;

@end

@implementation _SBBTestBridgeObject

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (double)doubleFieldValue
{
	return [self.doubleField doubleValue];
}

- (void)setDoubleFieldValue:(double)value_
{
	self.doubleField = [NSNumber numberWithDouble:value_];
}

- (float)floatFieldValue
{
	return [self.floatField floatValue];
}

- (void)setFloatFieldValue:(float)value_
{
	self.floatField = [NSNumber numberWithFloat:value_];
}

- (int32_t)longFieldValue
{
	return [self.longField intValue];
}

- (void)setLongFieldValue:(int32_t)value_
{
	self.longField = [NSNumber numberWithInt:value_];
}

- (int64_t)longLongFieldValue
{
	return [self.longLongField longLongValue];
}

- (void)setLongLongFieldValue:(int64_t)value_
{
	self.longLongField = [NSNumber numberWithLongLong:value_];
}

- (int16_t)shortFieldValue
{
	return [self.shortField shortValue];
}

- (void)setShortFieldValue:(int16_t)value_
{
	self.shortField = [NSNumber numberWithShort:value_];
}

- (uint32_t)uLongFieldValue
{
	return [self.uLongField unsignedIntValue];
}

- (void)setULongFieldValue:(uint32_t)value_
{
	self.uLongField = [NSNumber numberWithUnsignedInt:value_];
}

- (uint64_t)uLongLongFieldValue
{
	return [self.uLongLongField unsignedLongLongValue];
}

- (void)setULongLongFieldValue:(uint64_t)value_
{
	self.uLongLongField = [NSNumber numberWithUnsignedLongLong:value_];
}

- (uint16_t)uShortFieldValue
{
	return [self.uShortField unsignedShortValue];
}

- (void)setUShortFieldValue:(uint16_t)value_
{
	self.uShortField = [NSNumber numberWithUnsignedShort:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.dateField = [NSDate dateWithISO8601String:[dictionary objectForKey:@"dateField"]];

    self.doubleField = [dictionary objectForKey:@"doubleField"];

    self.floatField = [dictionary objectForKey:@"floatField"];

    self.guid = [dictionary objectForKey:@"guid"];

    self.jsonArrayField = [dictionary objectForKey:@"jsonArrayField"];

    self.jsonDictField = [dictionary objectForKey:@"jsonDictField"];

    self.longField = [dictionary objectForKey:@"longField"];

    self.longLongField = [dictionary objectForKey:@"longLongField"];

    self.shortField = [dictionary objectForKey:@"shortField"];

    self.stringField = [dictionary objectForKey:@"stringField"];

    self.uLongField = [dictionary objectForKey:@"uLongField"];

    self.uLongLongField = [dictionary objectForKey:@"uLongLongField"];

    self.uShortField = [dictionary objectForKey:@"uShortField"];

    // overwrite the old bridgeObjectArrayField relationship entirely rather than adding to it
    [self removeBridgeObjectArrayFieldObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"bridgeObjectArrayField"])
    {
        SBBBridgeObject_test *bridgeObjectArrayFieldObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addBridgeObjectArrayFieldObject:bridgeObjectArrayFieldObj];
    }

    // overwrite the old bridgeObjectSetField relationship entirely rather than adding to it
    [self removeBridgeObjectSetFieldObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"bridgeObjectSetField"])
    {
        SBBTestBridgeSubObject *bridgeObjectSetFieldObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addBridgeObjectSetFieldObject:bridgeObjectSetFieldObj];
    }

    NSDictionary *bridgeSubObjectFieldDict = [dictionary objectForKey:@"bridgeSubObjectField"];

    if (bridgeSubObjectFieldDict != nil)
    {
        SBBTestBridgeSubObject *bridgeSubObjectFieldObj = [objectManager objectFromBridgeJSON:bridgeSubObjectFieldDict];
        self.bridgeSubObjectField = bridgeSubObjectFieldObj;
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:[self.dateField ISO8601String] forKey:@"dateField"];

    [dict setObjectIfNotNil:self.doubleField forKey:@"doubleField"];

    [dict setObjectIfNotNil:self.floatField forKey:@"floatField"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.jsonArrayField forKey:@"jsonArrayField"];

    [dict setObjectIfNotNil:self.jsonDictField forKey:@"jsonDictField"];

    [dict setObjectIfNotNil:self.longField forKey:@"longField"];

    [dict setObjectIfNotNil:self.longLongField forKey:@"longLongField"];

    [dict setObjectIfNotNil:self.shortField forKey:@"shortField"];

    [dict setObjectIfNotNil:self.stringField forKey:@"stringField"];

    [dict setObjectIfNotNil:self.uLongField forKey:@"uLongField"];

    [dict setObjectIfNotNil:self.uLongLongField forKey:@"uLongLongField"];

    [dict setObjectIfNotNil:self.uShortField forKey:@"uShortField"];

    if ([self.bridgeObjectArrayField count] > 0)
	{

		NSMutableArray *bridgeObjectArrayFieldRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.bridgeObjectArrayField count]];

		for (SBBBridgeObject_test *obj in self.bridgeObjectArrayField)
        {
            [bridgeObjectArrayFieldRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:bridgeObjectArrayFieldRepresentationsForDictionary forKey:@"bridgeObjectArrayField"];

	}

    if ([self.bridgeObjectSetField count] > 0)
	{

		NSMutableArray *bridgeObjectSetFieldRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.bridgeObjectSetField count]];

		for (SBBTestBridgeSubObject *obj in self.bridgeObjectSetField)
        {
            [bridgeObjectSetFieldRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:bridgeObjectSetFieldRepresentationsForDictionary forKey:@"bridgeObjectSetField"];

	}

    [dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.bridgeSubObjectField] forKey:@"bridgeSubObjectField"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBTestBridgeSubObject *bridgeObjectSetFieldObj in self.bridgeObjectSetField)
	{
		[bridgeObjectSetFieldObj awakeFromDictionaryRepresentationInit];
	}
	[self.bridgeSubObjectField awakeFromDictionaryRepresentationInit];

	for (SBBBridgeObject_test *bridgeObjectArrayFieldObj in self.bridgeObjectArrayField)
	{
		[bridgeObjectArrayFieldObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"TestBridgeObject";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.dateField = managedObject.dateField;

        self.doubleField = managedObject.doubleField;

        self.floatField = managedObject.floatField;

        self.guid = managedObject.guid;

        self.jsonArrayField = managedObject.jsonArrayField;

        self.jsonDictField = managedObject.jsonDictField;

        self.longField = managedObject.longField;

        self.longLongField = managedObject.longLongField;

        self.shortField = managedObject.shortField;

        self.stringField = managedObject.stringField;

        // ensure that unsigned-ness is preserved

        self.uLongFieldValue = [managedObject.uLongField unsignedIntValue];

        // ensure that unsigned-ness is preserved

        self.uLongLongFieldValue = [managedObject.uLongLongField unsignedLongLongValue];

        // ensure that unsigned-ness is preserved

        self.uShortFieldValue = [managedObject.uShortField unsignedShortValue];

		for (NSManagedObject *bridgeObjectArrayFieldManagedObj in managedObject.bridgeObjectArrayField)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:bridgeObjectArrayFieldManagedObj.entity.name];
            SBBBridgeObject_test *bridgeObjectArrayFieldObj = [[objectClass alloc] initWithManagedObject:bridgeObjectArrayFieldManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (bridgeObjectArrayFieldObj != nil)
            {
                [self addBridgeObjectArrayFieldObject:bridgeObjectArrayFieldObj];
            }
		}

		for (NSManagedObject *bridgeObjectSetFieldManagedObj in managedObject.bridgeObjectSetField)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:bridgeObjectSetFieldManagedObj.entity.name];
            SBBTestBridgeSubObject *bridgeObjectSetFieldObj = [[objectClass alloc] initWithManagedObject:bridgeObjectSetFieldManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (bridgeObjectSetFieldObj != nil)
            {
                [self addBridgeObjectSetFieldObject:bridgeObjectSetFieldObj];
            }
		}
            NSManagedObject *bridgeSubObjectFieldManagedObj = managedObject.bridgeSubObjectField;
        Class bridgeSubObjectFieldClass = [SBBObjectManager bridgeClassFromType:bridgeSubObjectFieldManagedObj.entity.name];
        SBBTestBridgeSubObject *bridgeSubObjectFieldObj = [[bridgeSubObjectFieldClass alloc] initWithManagedObject:bridgeSubObjectFieldManagedObj objectManager:objectManager cacheManager:cacheManager];
        if (bridgeSubObjectFieldObj != nil)
        {
          self.bridgeSubObjectField = bridgeSubObjectFieldObj;
        }
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TestBridgeObject" inManagedObjectContext:cacheContext];
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

    managedObject.dateField = ((id)self.dateField == [NSNull null]) ? nil : self.dateField;

    managedObject.doubleField = ((id)self.doubleField == [NSNull null]) ? nil : self.doubleField;

    managedObject.floatField = ((id)self.floatField == [NSNull null]) ? nil : self.floatField;

    managedObject.guid = ((id)self.guid == [NSNull null]) ? nil : self.guid;

    managedObject.jsonArrayField = ((id)self.jsonArrayField == [NSNull null]) ? nil : self.jsonArrayField;

    managedObject.jsonDictField = ((id)self.jsonDictField == [NSNull null]) ? nil : self.jsonDictField;

    managedObject.longField = ((id)self.longField == [NSNull null]) ? nil : self.longField;

    managedObject.longLongField = ((id)self.longLongField == [NSNull null]) ? nil : self.longLongField;

    managedObject.shortField = ((id)self.shortField == [NSNull null]) ? nil : self.shortField;

    managedObject.stringField = ((id)self.stringField == [NSNull null]) ? nil : self.stringField;

    managedObject.uLongField = ((id)self.uLongField == [NSNull null]) ? nil : self.uLongField;

    managedObject.uLongLongField = ((id)self.uLongLongField == [NSNull null]) ? nil : self.uLongLongField;

    managedObject.uShortField = ((id)self.uShortField == [NSNull null]) ? nil : self.uShortField;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSOrderedSet *bridgeObjectArrayFieldCopy = [managedObject.bridgeObjectArrayField copy];

    // now remove all items from the existing relationship
    // to work pre-iOS 10, we have to work around this issue: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    NSMutableOrderedSet *workingBridgeObjectArrayFieldSet = [managedObject mutableOrderedSetValueForKey:NSStringFromSelector(@selector(bridgeObjectArrayField))];
    [workingBridgeObjectArrayFieldSet removeAllObjects];

    // now put the "new" items, if any, into the relationship
    if ([self.bridgeObjectArrayField count] > 0) {
		for (SBBBridgeObject_test *obj in self.bridgeObjectArrayField) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [workingBridgeObjectArrayFieldSet addObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in bridgeObjectArrayFieldCopy) {
        if (![relMo valueForKey:@"parentTestBridgeObject"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    bridgeObjectArrayFieldCopy = nil;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSSet *bridgeObjectSetFieldCopy = [managedObject.bridgeObjectSetField copy];

    // now remove all items from the existing relationship
    [managedObject removeBridgeObjectSetField:managedObject.bridgeObjectSetField];

    // now put the "new" items, if any, into the relationship
    if ([self.bridgeObjectSetField count] > 0) {
		for (SBBTestBridgeSubObject *obj in self.bridgeObjectSetField) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [managedObject addBridgeObjectSetFieldObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in bridgeObjectSetFieldCopy) {
        if (![relMo valueForKey:@"testBridgeObjectSet"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    bridgeObjectSetFieldCopy = nil;

    // destination entity TestBridgeSubObject is not directly cacheable, so delete it and create the replacement
    if (managedObject.bridgeSubObjectField) {
        [cacheContext deleteObject:managedObject.bridgeSubObjectField];
    }
    NSManagedObject *relMoBridgeSubObjectField = [self.bridgeSubObjectField createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];

    [managedObject setBridgeSubObjectField:relMoBridgeSubObjectField];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_ settingInverse: (BOOL) setInverse
{
    if (self.bridgeObjectArrayField == nil)
	{

		self.bridgeObjectArrayField = [NSMutableArray array];

	}

	[(NSMutableArray *)self.bridgeObjectArrayField addObject:value_];

}

- (void)addBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_
{
    [self addBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_ settingInverse: YES];
}

- (void)removeBridgeObjectArrayFieldObjects
{

    self.bridgeObjectArrayField = [NSMutableArray array];

}

- (void)removeBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.bridgeObjectArrayField removeObject:value_];

}

- (void)removeBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_
{
    [self removeBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBBridgeObject_test*)value inBridgeObjectArrayFieldAtIndex:(NSUInteger)idx {
    [self insertObject:value inBridgeObjectArrayFieldAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBBridgeObject_test*)value inBridgeObjectArrayFieldAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.bridgeObjectArrayField insertObject:value atIndex:idx];

}

- (void)removeObjectFromBridgeObjectArrayFieldAtIndex:(NSUInteger)idx {
    [self removeObjectFromBridgeObjectArrayFieldAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromBridgeObjectArrayFieldAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBBridgeObject_test *object = [self.bridgeObjectArrayField objectAtIndex:idx];
    [self removeBridgeObjectArrayFieldObject:object settingInverse:YES];
}

- (void)insertBridgeObjectArrayField:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertBridgeObjectArrayField:value atIndexes:indexes settingInverse:YES];
}

- (void)insertBridgeObjectArrayField:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.bridgeObjectArrayField insertObjects:value atIndexes:indexes];

}

- (void)removeBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes {
    [self removeBridgeObjectArrayFieldAtIndexes:indexes settingInverse:YES];
}

- (void)removeBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.bridgeObjectArrayField removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInBridgeObjectArrayFieldAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject_test*)value {
    [self replaceObjectInBridgeObjectArrayFieldAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInBridgeObjectArrayFieldAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject_test*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.bridgeObjectArrayField replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes withBridgeObjectArrayField:(NSArray *)value {
    [self replaceBridgeObjectArrayFieldAtIndexes:indexes withBridgeObjectArrayField:value settingInverse:YES];
}

- (void)replaceBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes withBridgeObjectArrayField:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.bridgeObjectArrayField replaceObjectsAtIndexes:indexes withObjects:value];
}

- (void)addBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_ settingInverse: (BOOL) setInverse
{
    if (self.bridgeObjectSetField == nil)
	{

		self.bridgeObjectSetField = [NSMutableArray array];

	}

	[(NSMutableArray *)self.bridgeObjectSetField addObject:value_];

}

- (void)addBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_
{
    [self addBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_ settingInverse: YES];
}

- (void)removeBridgeObjectSetFieldObjects
{

    self.bridgeObjectSetField = [NSMutableArray array];

}

- (void)removeBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.bridgeObjectSetField removeObject:value_];

}

- (void)removeBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_
{
    [self removeBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_ settingInverse: YES];
}

- (void) setBridgeSubObjectField: (SBBTestBridgeSubObject*) bridgeSubObjectField_ settingInverse: (BOOL) setInverse
{

    _bridgeSubObjectField = bridgeSubObjectField_;

}

- (void) setBridgeSubObjectField: (SBBTestBridgeSubObject*) bridgeSubObjectField_
{
    [self setBridgeSubObjectField: bridgeSubObjectField_ settingInverse: YES];
}

- (SBBTestBridgeSubObject*) bridgeSubObjectField
{
    return _bridgeSubObjectField;
}

@synthesize bridgeSubObjectField = _bridgeSubObjectField;

@end
