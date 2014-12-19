//
//  _SBBActivity.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBActivity.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

#import "SBBGuidCreatedOnVersionHolder.h"

@class SBBGuidCreatedOnVersionHolder;

@protocol _SBBActivity

@end

@interface _SBBActivity : SBBBridgeObject

@property (nonatomic, strong) NSString* activityType;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* ref;

@property (nonatomic, strong, readwrite) SBBGuidCreatedOnVersionHolder *survey;

- (void) setSurvey: (SBBGuidCreatedOnVersionHolder*) survey_ settingInverse: (BOOL) setInverse;

@end
