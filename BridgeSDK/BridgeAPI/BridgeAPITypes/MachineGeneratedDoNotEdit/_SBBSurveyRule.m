//
//  SBBSurveyRule.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyRule.h instead.
//

#import "_SBBSurveyRule.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurveyRule()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyRule

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

        self.operator = [dictionary objectForKey:@"operator"];

        self.skipTo = [dictionary objectForKey:@"skipTo"];

        self.value = [dictionary objectForKey:@"value"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.operator forKey:@"operator"];

    [dict setObjectIfNotNil:self.skipTo forKey:@"skipTo"];

    [dict setObjectIfNotNil:self.value forKey:@"value"];

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
