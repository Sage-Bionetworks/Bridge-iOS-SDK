//
//  _SBBTestBridgeObject.h
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
// Make changes to SBBTestBridgeObject.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject_test.h"

@class SBBBridgeObject_test;
@class SBBTestBridgeSubObject;
@class SBBTestBridgeSubObject;

@protocol _SBBTestBridgeObject

@end

@interface _SBBTestBridgeObject : SBBBridgeObject_test

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

@property (nonatomic, strong, readonly) NSArray *bridgeObjectSetField;

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

- (void)addBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_ settingInverse: (BOOL) setInverse;
- (void)addBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_;
- (void)removeBridgeObjectSetFieldObjects;
- (void)removeBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_ settingInverse: (BOOL) setInverse;
- (void)removeBridgeObjectSetFieldObject:(SBBTestBridgeSubObject*)value_;

- (void) setBridgeSubObjectField: (SBBTestBridgeSubObject*) bridgeSubObjectField_ settingInverse: (BOOL) setInverse;

@end
