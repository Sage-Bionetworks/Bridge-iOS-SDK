//
//  SBBSurveyElement.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyElement.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBSurvey;

@protocol _SBBSurveyElement

@end

@interface _SBBSurveyElement : SBBBridgeObject

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, strong) NSString* promptDetail;

@property (nonatomic, strong, readwrite) SBBSurvey *survey;

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse;

@end
