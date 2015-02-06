//
//  SBBSurveyQuestionOption.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestionOption.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

#import "SBBImage.h"

@class SBBImage;

@protocol _SBBSurveyQuestionOption

@end

@interface _SBBSurveyQuestionOption : SBBBridgeObject

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* value;

@property (nonatomic, strong, readwrite) SBBImage *image;

- (void) setImage: (SBBImage*) image_ settingInverse: (BOOL) setInverse;

@end
