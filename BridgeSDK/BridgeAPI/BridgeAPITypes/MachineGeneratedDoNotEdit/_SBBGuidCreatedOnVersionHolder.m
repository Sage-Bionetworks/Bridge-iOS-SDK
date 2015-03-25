//
//  SBBGuidCreatedOnVersionHolder.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBGuidCreatedOnVersionHolder.h instead.
//

#import "_SBBGuidCreatedOnVersionHolder.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBGuidCreatedOnVersionHolder()

@end

@implementation _SBBGuidCreatedOnVersionHolder

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)versionValue
{
	return [self.version longLongValue];
}

- (void)setVersionValue:(int64_t)value_
{
	self.version = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

        self.guid = [dictionary objectForKey:@"guid"];

        self.version = [dictionary objectForKey:@"version"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

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
