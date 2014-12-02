//
//  SBBSchedule.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSchedule.h instead.
//

#import "_SBBSchedule.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSchedule()

@end

/** \ingroup DataModel */

@implementation _SBBSchedule

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

        self.activityRef = [dictionary objectForKey:@"activityRef"];

        self.activityType = [dictionary objectForKey:@"activityType"];

        self.cronTrigger = [dictionary objectForKey:@"cronTrigger"];

        self.endsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"endsOn"]];

        self.expires = [dictionary objectForKey:@"expires"];

        self.label = [dictionary objectForKey:@"label"];

        self.scheduleType = [dictionary objectForKey:@"scheduleType"];

        self.startsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startsOn"]];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.activityRef forKey:@"activityRef"];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.cronTrigger forKey:@"cronTrigger"];

    [dict setObjectIfNotNil:[self.endsOn ISO8601String] forKey:@"endsOn"];

    [dict setObjectIfNotNil:self.expires forKey:@"expires"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.scheduleType forKey:@"scheduleType"];

    [dict setObjectIfNotNil:[self.startsOn ISO8601String] forKey:@"startsOn"];

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
