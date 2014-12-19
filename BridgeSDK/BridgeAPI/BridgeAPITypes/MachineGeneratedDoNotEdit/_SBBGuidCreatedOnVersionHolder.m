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

#import "SBBActivity.h"

@interface _SBBGuidCreatedOnVersionHolder()

@end

/** \ingroup DataModel */

@implementation _SBBGuidCreatedOnVersionHolder

- (instancetype)init
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

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

        self.guid = [dictionary objectForKey:@"guid"];

        self.version = [dictionary objectForKey:@"version"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.activity awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setActivity: (SBBActivity*) activity_ settingInverse: (BOOL) setInverse
{
    if (activity_ == nil) {
        [_activity setSurvey: nil settingInverse: NO];
    }

    _activity = activity_;

    if (setInverse == YES) {
        [_activity setSurvey: (SBBGuidCreatedOnVersionHolder*)self settingInverse: NO];
    }
}

- (void) setActivity: (SBBActivity*) activity_
{
    [self setActivity: activity_ settingInverse: YES];
}

- (SBBActivity*) activity
{
    return _activity;
}

@synthesize activity = _activity;

@end
