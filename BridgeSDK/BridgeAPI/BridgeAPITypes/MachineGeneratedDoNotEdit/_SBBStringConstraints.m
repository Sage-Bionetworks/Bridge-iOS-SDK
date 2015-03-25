//
//  SBBStringConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBStringConstraints.h instead.
//

#import "_SBBStringConstraints.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBStringConstraints()

@end

@implementation _SBBStringConstraints

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)maxLengthValue
{
	return [self.maxLength longLongValue];
}

- (void)setMaxLengthValue:(int64_t)value_
{
	self.maxLength = [NSNumber numberWithLongLong:value_];
}

- (int64_t)minLengthValue
{
	return [self.minLength longLongValue];
}

- (void)setMinLengthValue:(int64_t)value_
{
	self.minLength = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.maxLength = [dictionary objectForKey:@"maxLength"];

        self.minLength = [dictionary objectForKey:@"minLength"];

        self.pattern = [dictionary objectForKey:@"pattern"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.maxLength forKey:@"maxLength"];

    [dict setObjectIfNotNil:self.minLength forKey:@"minLength"];

    [dict setObjectIfNotNil:self.pattern forKey:@"pattern"];

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
