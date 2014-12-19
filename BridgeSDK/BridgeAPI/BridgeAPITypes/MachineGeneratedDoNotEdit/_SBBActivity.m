//
//  SBBActivity.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBActivity.h instead.
//

#import "_SBBActivity.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSchedule.h"
#import "SBBGuidCreatedOnVersionHolder.h"

@interface _SBBActivity()

@end

/** \ingroup DataModel */

@implementation _SBBActivity

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

        self.activityType = [dictionary objectForKey:@"activityType"];

        self.label = [dictionary objectForKey:@"label"];

        self.ref = [dictionary objectForKey:@"ref"];

            NSDictionary *surveyDict = [dictionary objectForKey:@"survey"];
		if(surveyDict != nil)
		{
			SBBGuidCreatedOnVersionHolder *surveyObj = [objectManager objectFromBridgeJSON:surveyDict];
			self.survey = surveyObj;

		}
	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.ref forKey:@"ref"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.survey] forKey:@"survey"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.survey awakeFromDictionaryRepresentationInit];
	[self.schedule awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setSchedule: (SBBSchedule*) schedule_ settingInverse: (BOOL) setInverse
{
    if (schedule_ == nil) {
        [_schedule removeActivitiesObject: (SBBActivity*)self settingInverse: NO];
    }

    _schedule = schedule_;

    if (setInverse == YES) {
        [_schedule addActivitiesObject: (SBBActivity*)self settingInverse: NO];
    }
}

- (void) setSchedule: (SBBSchedule*) schedule_
{
    [self setSchedule: schedule_ settingInverse: YES];
}

- (SBBSchedule*) schedule
{
    return _schedule;
}

- (void) setSurvey: (SBBGuidCreatedOnVersionHolder*) survey_ settingInverse: (BOOL) setInverse
{
    if (survey_ == nil) {
        [_survey setActivity: nil settingInverse: NO];
    }

    _survey = survey_;

    if (setInverse == YES) {
        [_survey setActivity: (SBBActivity*)self settingInverse: NO];
    }
}

- (void) setSurvey: (SBBGuidCreatedOnVersionHolder*) survey_
{
    [self setSurvey: survey_ settingInverse: YES];
}

- (SBBGuidCreatedOnVersionHolder*) survey
{
    return _survey;
}

@synthesize schedule = _schedule;@synthesize survey = _survey;

@end
