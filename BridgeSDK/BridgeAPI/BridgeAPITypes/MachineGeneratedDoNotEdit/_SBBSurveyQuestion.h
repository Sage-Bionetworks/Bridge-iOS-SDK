//
//  SBBSurveyQuestion.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestion.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

#import "SBBSurveyConstraints.h"

@class SBBSurveyConstraints;
@class SBBSurvey;

@protocol _SBBSurveyQuestion

@end

@interface _SBBSurveyQuestion : SBBBridgeObject

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, strong) NSString* uiHint;

@property (nonatomic, strong, readwrite) SBBSurveyConstraints *constraints;

@property (nonatomic, strong, readwrite) SBBSurvey *survey;

- (void) setConstraints: (SBBSurveyConstraints*) constraints_ settingInverse: (BOOL) setInverse;

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse;

@end
