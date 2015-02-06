//
//  _SBBSurveyInfoScreen.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyInfoScreen.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyElement.h"

#import "SBBImage.h"

@class SBBImage;

@protocol _SBBSurveyInfoScreen

@end

@interface _SBBSurveyInfoScreen : SBBSurveyElement

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, strong) NSString* promptDetail;

@property (nonatomic, strong) NSString* title;

@property (nonatomic, strong, readwrite) SBBImage *image;

- (void) setImage: (SBBImage*) image_ settingInverse: (BOOL) setInverse;

@end
