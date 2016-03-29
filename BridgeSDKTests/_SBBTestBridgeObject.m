//
//  SBBTestBridgeObject.m
//
//	Copyright (c) 2014-2016 Sage Bionetworks
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
// Make changes to SBBTestBridgeObject.h instead.
//

#import "_SBBTestBridgeObject.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBBridgeObject_test.h"
#import "SBBTestBridgeSubObject.h"

@interface _SBBTestBridgeObject()
@property (nonatomic, strong, readwrite) NSArray *bridgeObjectArrayField;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (TestBridgeObject)

@property (nonatomic, strong) NSDate* dateField;

@property (nonatomic, strong) NSNumber* doubleField;

@property (nonatomic, assign) double doubleFieldValue;

@property (nonatomic, strong) NSNumber* floatField;

@property (nonatomic, assign) float floatFieldValue;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSArray* jsonArrayField;

@property (nonatomic, strong) NSDictionary* jsonDictField;

@property (nonatomic, strong) NSNumber* longField;

@property (nonatomic, assign) int32_t longFieldValue;

@property (nonatomic, strong) NSNumber* longLongField;

@property (nonatomic, assign) int64_t longLongFieldValue;

@property (nonatomic, strong) NSNumber* shortField;

@property (nonatomic, assign) int16_t shortFieldValue;

@property (nonatomic, strong) NSString* stringField;

@property (nonatomic, strong) NSNumber* uLongField;

@property (nonatomic, assign) uint32_t uLongFieldValue;

@property (nonatomic, strong) NSNumber* uLongLongField;

@property (nonatomic, assign) uint64_t uLongLongFieldValue;

@property (nonatomic, strong) NSNumber* uShortField;

@property (nonatomic, assign) uint16_t uShortFieldValue;

@property (nonatomic, strong, readonly) NSArray *bridgeObjectArrayField;

@property (nonatomic, strong, readwrite) NSManagedObject *bridgeSubObjectField;

- (void)addBridgeObjectArrayFieldObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addBridgeObjectArrayFieldObject:(NSManagedObject *)value_;
- (void)removeBridgeObjectArrayFieldObjects;
- (void)removeBridgeObjectArrayFieldObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeBridgeObjectArrayFieldObject:(NSManagedObject *)value_;

- (void)insertObject:(NSManagedObject *)value inBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)insertBridgeObjectArrayField:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBridgeObjectArrayFieldAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes withBridgeObjectArrayField:(NSArray *)values;

- (void) setBridgeSubObjectField: (NSManagedObject *) bridgeSubObjectField_ settingInverse: (BOOL) setInverse;

@end

@implementation _SBBTestBridgeObject

- (instancetype)init
{
	if((self = [super init]))
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

    for(id objectRepresentationForDict in [dictionary objectForKey:@"bridgeObjectArrayField"])
    {
        SBBBridgeObject_test *bridgeObjectArrayFieldObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addBridgeObjectArrayFieldObject:bridgeObjectArrayFieldObj];
    }
        NSDictionary *bridgeSubObjectFieldDict = [dictionary objectForKey:@"bridgeSubObjectField"];
    if(bridgeSubObjectFieldDict != nil)
    {
        SBBTestBridgeSubObject *bridgeSubObjectFieldObj = [objectManager objectFromBridgeJSON:bridgeSubObjectFieldDict];
        self.bridgeSubObjectField = bridgeSubObjectFieldObj;

    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

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

    if([self.bridgeObjectArrayField count] > 0)
	{

		NSMutableArray *bridgeObjectArrayFieldRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.bridgeObjectArrayField count]];
		for(SBBBridgeObject_test *obj in self.bridgeObjectArrayField)
		{
			[bridgeObjectArrayFieldRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:bridgeObjectArrayFieldRepresentationsForDictionary forKey:@"bridgeObjectArrayField"];

	}

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.bridgeSubObjectField] forKey:@"bridgeSubObjectField"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.bridgeSubObjectField awakeFromDictionaryRepresentationInit];

	for(SBBBridgeObject_test *bridgeObjectArrayFieldObj in self.bridgeObjectArrayField)
	{
		[bridgeObjectArrayFieldObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"TestBridgeObject" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

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

        self.uLongField = managedObject.uLongField;

        self.uLongLongField = managedObject.uLongLongField;

        self.uShortField = managedObject.uShortField;

		for(NSManagedObject *bridgeObjectArrayFieldManagedObj in managedObject.bridgeObjectArrayField)
		{
            SBBBridgeObject_test *bridgeObjectArrayFieldObj = [[SBBBridgeObject_test alloc] initWithManagedObject:bridgeObjectArrayFieldManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(bridgeObjectArrayFieldObj != nil)
            {
                [self addBridgeObjectArrayFieldObject:bridgeObjectArrayFieldObj];
            }
		}
            NSManagedObject *bridgeSubObjectFieldManagedObj = managedObject.bridgeSubObjectField;
        SBBTestBridgeSubObject *bridgeSubObjectFieldObj = [[SBBTestBridgeSubObject alloc] initWithManagedObject:bridgeSubObjectFieldManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(bridgeSubObjectFieldObj != nil)
        {
          self.bridgeSubObjectField = bridgeSubObjectFieldObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TestBridgeObject" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.dateField = self.dateField;

    managedObject.doubleField = self.doubleField;

    managedObject.floatField = self.floatField;

    managedObject.guid = self.guid;

    managedObject.jsonArrayField = self.jsonArrayField;

    managedObject.jsonDictField = self.jsonDictField;

    managedObject.longField = self.longField;

    managedObject.longLongField = self.longLongField;

    managedObject.shortField = self.shortField;

    managedObject.stringField = self.stringField;

    managedObject.uLongField = self.uLongField;

    managedObject.uLongLongField = self.uLongLongField;

    managedObject.uShortField = self.uShortField;

    if([self.bridgeObjectArrayField count] > 0) {
        [managedObject removeBridgeObjectArrayFieldObjects];
		for(SBBBridgeObject_test *obj in self.bridgeObjectArrayField) {
            NSManagedObject *relMo = [obj saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            [managedObject addBridgeObjectArrayFieldObject:relMo];
		}
	}

    [cacheContext deleteObject:managedObject.bridgeSubObjectField];
    NSManagedObject *relMoBridgeSubObjectField = [self.bridgeSubObjectField saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
    [managedObject setBridgeSubObjectField:relMoBridgeSubObjectField];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_ settingInverse: (BOOL) setInverse
{
    if(self.bridgeObjectArrayField == nil)
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
