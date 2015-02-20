//
//  SBBSurveyElement.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyElement.h instead.
//

#import "_SBBSurveyElement.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurvey.h"

@interface _SBBSurveyElement()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyElement

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.guid = [dictionary objectForKey:@"guid"];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.prompt = [dictionary objectForKey:@"prompt"];

        self.promptDetail = [dictionary objectForKey:@"promptDetail"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:self.prompt forKey:@"prompt"];

    [dict setObjectIfNotNil:self.promptDetail forKey:@"promptDetail"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.survey awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse
{
    if (survey_ == nil) {
        [_survey removeElementsObject: (SBBSurveyElement*)self settingInverse: NO];
    }

    _survey = survey_;

    if (setInverse == YES) {
        [_survey addElementsObject: (SBBSurveyElement*)self settingInverse: NO];
    }
}

- (void) setSurvey: (SBBSurvey*) survey_
{
    [self setSurvey: survey_ settingInverse: YES];
}

- (SBBSurvey*) survey
{
    return _survey;
}

@synthesize survey = _survey;

@end
