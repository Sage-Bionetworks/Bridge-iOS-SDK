//
//  SBBTestBridgeObject.m
//
//  $Id$
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

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (TestBridgeObject)

@property (nonatomic, strong) NSDate* dateField;

@property (nonatomic, strong) NSNumber* doubleField;

@property (nonatomic, assign) double doubleFieldValue;

@property (nonatomic, strong) NSNumber* floatField;

@property (nonatomic, assign) float floatFieldValue;

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

/** \ingroup DataModel */

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
