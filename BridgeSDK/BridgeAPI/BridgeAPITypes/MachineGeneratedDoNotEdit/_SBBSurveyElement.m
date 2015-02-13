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

@interface _SBBSurveyElement()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyElement

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

        self.guid = [dictionary objectForKey:@"guid"];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.prompt = [dictionary objectForKey:@"prompt"];

        self.promptDetail = [dictionary objectForKey:@"promptDetail"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

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

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

@end
