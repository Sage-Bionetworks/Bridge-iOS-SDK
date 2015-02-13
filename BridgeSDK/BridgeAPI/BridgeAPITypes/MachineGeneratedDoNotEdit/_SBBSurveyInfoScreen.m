//
//  SBBSurveyInfoScreen.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyInfoScreen.h instead.
//

#import "_SBBSurveyInfoScreen.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurveyInfoScreen()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyInfoScreen

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

        self.image = [dictionary objectForKey:@"image"];

        self.title = [dictionary objectForKey:@"title"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.image forKey:@"image"];

    [dict setObjectIfNotNil:self.title forKey:@"title"];

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
