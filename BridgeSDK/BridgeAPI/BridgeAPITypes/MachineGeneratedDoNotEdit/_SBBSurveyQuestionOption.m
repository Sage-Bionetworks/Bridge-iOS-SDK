//
//  SBBSurveyQuestionOption.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestionOption.h instead.
//

#import "_SBBSurveyQuestionOption.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurveyQuestionOption()

@end

@implementation _SBBSurveyQuestionOption

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

        self.detail = [dictionary objectForKey:@"detail"];

        self.image = [dictionary objectForKey:@"image"];

        self.label = [dictionary objectForKey:@"label"];

        self.value = [dictionary objectForKey:@"value"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.detail forKey:@"detail"];

    [dict setObjectIfNotNil:self.image forKey:@"image"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

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
