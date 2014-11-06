//
//  SBBBridgeObject_test.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBBridgeObject_test.h instead.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"

@class SBBTestBridgeObject;

@protocol _SBBBridgeObject_test

@end

@interface _SBBBridgeObject_test : ModelObject

@property (nonatomic, strong, readonly) NSString* type;

@property (nonatomic, strong, readwrite) SBBTestBridgeObject *parentTestBridgeObject;

- (void) setParentTestBridgeObject: (SBBTestBridgeObject*) parentTestBridgeObject_ settingInverse: (BOOL) setInverse;

@end
