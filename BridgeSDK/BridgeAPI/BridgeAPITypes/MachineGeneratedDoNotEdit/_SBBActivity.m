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

@interface _SBBActivity()

@end

/** \ingroup DataModel */

@implementation _SBBActivity

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

        self.activityType = [dictionary objectForKey:@"activityType"];

        self.label = [dictionary objectForKey:@"label"];

        self.ref = [dictionary objectForKey:@"ref"];

        self.survey = [dictionary objectForKey:@"survey"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.ref forKey:@"ref"];

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
