//
//  SBBSurveyAnswer.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyAnswer.h instead.
//

#import "_SBBSurveyAnswer.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyResponse.h"

@interface _SBBSurveyAnswer()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyAnswer

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)declinedValue
{
	return [self.declined boolValue];
}

- (void)setDeclinedValue:(BOOL)value_
{
	self.declined = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.answer = [dictionary objectForKey:@"answer"];

        self.answeredOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"answeredOn"]];

        self.answers = [dictionary objectForKey:@"answers"];

        self.client = [dictionary objectForKey:@"client"];

        self.declined = [dictionary objectForKey:@"declined"];

        self.questionGuid = [dictionary objectForKey:@"questionGuid"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.answer forKey:@"answer"];

    [dict setObjectIfNotNil:[self.answeredOn ISO8601String] forKey:@"answeredOn"];

    [dict setObjectIfNotNil:self.answers forKey:@"answers"];

    [dict setObjectIfNotNil:self.client forKey:@"client"];

    [dict setObjectIfNotNil:self.declined forKey:@"declined"];

    [dict setObjectIfNotNil:self.questionGuid forKey:@"questionGuid"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.surveyResponse awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setSurveyResponse: (SBBSurveyResponse*) surveyResponse_ settingInverse: (BOOL) setInverse
{
    if (surveyResponse_ == nil) {
        [_surveyResponse removeAnswersObject: (SBBSurveyAnswer*)self settingInverse: NO];
    }

    _surveyResponse = surveyResponse_;

    if (setInverse == YES) {
        [_surveyResponse addAnswersObject: (SBBSurveyAnswer*)self settingInverse: NO];
    }
}

- (void) setSurveyResponse: (SBBSurveyResponse*) surveyResponse_
{
    [self setSurveyResponse: surveyResponse_ settingInverse: YES];
}

- (SBBSurveyResponse*) surveyResponse
{
    return _surveyResponse;
}

@synthesize surveyResponse = _surveyResponse;

@end
