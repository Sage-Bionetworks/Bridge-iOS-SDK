//
//  SBBSurveyResponse.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyResponse.h instead.
//

#import "_SBBSurveyResponse.h"

@interface _SBBSurveyResponse()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyResponse

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

    self.answers = [dictionary objectForKey:@"answers"];

    self.completedOn = [dictionary objectForKey:@"completedOn"];

    self.guid = [dictionary objectForKey:@"guid"];

    self.startedOn = [dictionary objectForKey:@"startedOn"];

    self.status = [dictionary objectForKey:@"status"];

    self.survey = [dictionary objectForKey:@"survey"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
	[dict setObjectIfNotNil:self.answers forKey:@"answers"];
	[dict setObjectIfNotNil:self.completedOn forKey:@"completedOn"];
	[dict setObjectIfNotNil:self.guid forKey:@"guid"];
	[dict setObjectIfNotNil:self.startedOn forKey:@"startedOn"];
	[dict setObjectIfNotNil:self.status forKey:@"status"];
	[dict setObjectIfNotNil:self.survey forKey:@"survey"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

@end
