//
//  SBBGuidCreatedOnVersionHolder.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBGuidCreatedOnVersionHolder.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBActivity;

@protocol _SBBGuidCreatedOnVersionHolder

@end

@interface _SBBGuidCreatedOnVersionHolder : SBBBridgeObject

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) int64_t versionValue;

@property (nonatomic, strong, readwrite) SBBActivity *activity;

- (void) setActivity: (SBBActivity*) activity_ settingInverse: (BOOL) setInverse;

@end
