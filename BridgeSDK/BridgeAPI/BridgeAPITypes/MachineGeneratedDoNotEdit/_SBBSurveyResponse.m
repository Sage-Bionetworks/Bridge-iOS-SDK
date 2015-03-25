//
//  SBBSurveyResponse.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyResponse.h instead.
//

#import "_SBBSurveyResponse.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurveyResponse()

@end

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

        self.completedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"completedOn"]];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.startedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startedOn"]];

        self.status = [dictionary objectForKey:@"status"];

        self.survey = [dictionary objectForKey:@"survey"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.answers forKey:@"answers"];

    [dict setObjectIfNotNil:[self.completedOn ISO8601String] forKey:@"completedOn"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:[self.startedOn ISO8601String] forKey:@"startedOn"];

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
