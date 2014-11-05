//
//  SBBDecimalConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBDecimalConstraints.h instead.
//

#import "_SBBDecimalConstraints.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBDecimalConstraints()

@end

/** \ingroup DataModel */

@implementation _SBBDecimalConstraints

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (double)maxValueValue
{
	return [self.maxValue doubleValue];
}

- (void)setMaxValueValue:(double)value_
{
	self.maxValue = [NSNumber numberWithDouble:value_];
}

- (double)minValueValue
{
	return [self.minValue doubleValue];
}

- (void)setMinValueValue:(double)value_
{
	self.minValue = [NSNumber numberWithDouble:value_];
}

- (double)stepValue
{
	return [self.step doubleValue];
}

- (void)setStepValue:(double)value_
{
	self.step = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.maxValue = [dictionary objectForKey:@"maxValue"];

        self.minValue = [dictionary objectForKey:@"minValue"];

        self.step = [dictionary objectForKey:@"step"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.maxValue forKey:@"maxValue"];

    [dict setObjectIfNotNil:self.minValue forKey:@"minValue"];

    [dict setObjectIfNotNil:self.step forKey:@"step"];

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
