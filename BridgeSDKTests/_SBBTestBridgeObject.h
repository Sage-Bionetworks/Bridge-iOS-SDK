//
//  _SBBTestBridgeObject.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBTestBridgeObject.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject_test.h"

@class SBBBridgeObject_test;
@class SBBTestBridgeSubObject;

@protocol _SBBTestBridgeObject

@end

@interface _SBBTestBridgeObject : SBBBridgeObject_test

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

@property (nonatomic, strong, readwrite) SBBTestBridgeSubObject *bridgeSubObjectField;

- (void)addBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_ settingInverse: (BOOL) setInverse;
- (void)addBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_;
- (void)removeBridgeObjectArrayFieldObjects;
- (void)removeBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_ settingInverse: (BOOL) setInverse;
- (void)removeBridgeObjectArrayFieldObject:(SBBBridgeObject_test*)value_;

- (void)insertObject:(SBBBridgeObject_test*)value inBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)insertBridgeObjectArrayField:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBridgeObjectArrayFieldAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject_test*)value;
- (void)replaceBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes withBridgeObjectArrayField:(NSArray *)values;

- (void) setBridgeSubObjectField: (SBBTestBridgeSubObject*) bridgeSubObjectField_ settingInverse: (BOOL) setInverse;

@end
