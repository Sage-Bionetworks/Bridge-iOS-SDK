//
//  SBBSurveyQuestion.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestion.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyElement.h"

#import "SBBSurveyConstraints.h"

@class SBBSurveyConstraints;

@protocol _SBBSurveyQuestion

@end

@interface _SBBSurveyQuestion : SBBSurveyElement

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, strong) NSString* uiHint;

@property (nonatomic, strong, readwrite) SBBSurveyConstraints *constraints;

- (void) setConstraints: (SBBSurveyConstraints*) constraints_ settingInverse: (BOOL) setInverse;

@end
