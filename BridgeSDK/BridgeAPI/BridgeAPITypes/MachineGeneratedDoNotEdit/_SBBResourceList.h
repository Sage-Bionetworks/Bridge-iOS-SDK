//
//  SBBResourceList.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBResourceList.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBBridgeObject;

@protocol _SBBResourceList

@end

@interface _SBBResourceList : SBBBridgeObject

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
