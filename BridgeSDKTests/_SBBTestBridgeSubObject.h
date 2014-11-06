//
//  SBBTestBridgeSubObject.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBTestBridgeSubObject.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject_test.h"

@class SBBTestBridgeObject;

@protocol _SBBTestBridgeSubObject

@end

@interface _SBBTestBridgeSubObject : SBBBridgeObject_test

@property (nonatomic, strong) NSString* stringField;

@property (nonatomic, strong, readwrite) SBBTestBridgeObject *testBridgeObject;

- (void) setTestBridgeObject: (SBBTestBridgeObject*) testBridgeObject_ settingInverse: (BOOL) setInverse;

@end
