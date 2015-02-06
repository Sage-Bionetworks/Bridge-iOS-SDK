//
//  SBBImage.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBImage.h instead.
//

#import "_SBBImage.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyInfoScreen.h"
#import "SBBSurveyQuestionOption.h"

@interface _SBBImage()

@end

/** \ingroup DataModel */

@implementation _SBBImage

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (double)heightValue
{
	return [self.height doubleValue];
}

- (void)setHeightValue:(double)value_
{
	self.height = [NSNumber numberWithDouble:value_];
}

- (double)widthValue
{
	return [self.width doubleValue];
}

- (void)setWidthValue:(double)value_
{
	self.width = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.height = [dictionary objectForKey:@"height"];

        self.source = [dictionary objectForKey:@"source"];

        self.width = [dictionary objectForKey:@"width"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.height forKey:@"height"];

    [dict setObjectIfNotNil:self.source forKey:@"source"];

    [dict setObjectIfNotNil:self.width forKey:@"width"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.surveyQuestionOption awakeFromDictionaryRepresentationInit];
	[self.surveyInfoScreen awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setSurveyInfoScreen: (SBBSurveyInfoScreen*) surveyInfoScreen_ settingInverse: (BOOL) setInverse
{
    if (surveyInfoScreen_ == nil) {
        [_surveyInfoScreen setImage: nil settingInverse: NO];
    }

    _surveyInfoScreen = surveyInfoScreen_;

    if (setInverse == YES) {
        [_surveyInfoScreen setImage: (SBBImage*)self settingInverse: NO];
    }
}

- (void) setSurveyInfoScreen: (SBBSurveyInfoScreen*) surveyInfoScreen_
{
    [self setSurveyInfoScreen: surveyInfoScreen_ settingInverse: YES];
}

- (SBBSurveyInfoScreen*) surveyInfoScreen
{
    return _surveyInfoScreen;
}

- (void) setSurveyQuestionOption: (SBBSurveyQuestionOption*) surveyQuestionOption_ settingInverse: (BOOL) setInverse
{
    if (surveyQuestionOption_ == nil) {
        [_surveyQuestionOption setImage: nil settingInverse: NO];
    }

    _surveyQuestionOption = surveyQuestionOption_;

    if (setInverse == YES) {
        [_surveyQuestionOption setImage: (SBBImage*)self settingInverse: NO];
    }
}

- (void) setSurveyQuestionOption: (SBBSurveyQuestionOption*) surveyQuestionOption_
{
    [self setSurveyQuestionOption: surveyQuestionOption_ settingInverse: YES];
}

- (SBBSurveyQuestionOption*) surveyQuestionOption
{
    return _surveyQuestionOption;
}

@synthesize surveyInfoScreen = _surveyInfoScreen;@synthesize surveyQuestionOption = _surveyQuestionOption;

@end
