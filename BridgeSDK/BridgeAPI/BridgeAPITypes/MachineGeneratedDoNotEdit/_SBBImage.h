//
//  SBBImage.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBImage.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBSurveyInfoScreen;
@class SBBSurveyQuestionOption;

@protocol _SBBImage

@end

@interface _SBBImage : SBBBridgeObject

@property (nonatomic, strong) NSNumber* height;

@property (nonatomic, assign) double heightValue;

@property (nonatomic, strong) NSString* source;

@property (nonatomic, strong) NSNumber* width;

@property (nonatomic, assign) double widthValue;

@property (nonatomic, strong, readwrite) SBBSurveyInfoScreen *surveyInfoScreen;

@property (nonatomic, strong, readwrite) SBBSurveyQuestionOption *surveyQuestionOption;

- (void) setSurveyInfoScreen: (SBBSurveyInfoScreen*) surveyInfoScreen_ settingInverse: (BOOL) setInverse;

- (void) setSurveyQuestionOption: (SBBSurveyQuestionOption*) surveyQuestionOption_ settingInverse: (BOOL) setInverse;

@end
