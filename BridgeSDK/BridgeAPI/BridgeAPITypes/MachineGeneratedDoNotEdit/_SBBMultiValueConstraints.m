//
//  SBBMultiValueConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBMultiValueConstraints.h instead.
//

#import "_SBBMultiValueConstraints.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBMultiValueConstraints()

@end

/** \ingroup DataModel */

@implementation _SBBMultiValueConstraints

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)allowMultipleValue
{
	return [self.allowMultiple boolValue];
}

- (void)setAllowMultipleValue:(BOOL)value_
{
	self.allowMultiple = [NSNumber numberWithBool:value_];
}

- (BOOL)allowOtherValue
{
	return [self.allowOther boolValue];
}

- (void)setAllowOtherValue:(BOOL)value_
{
	self.allowOther = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.allowMultiple = [dictionary objectForKey:@"allowMultiple"];

        self.allowOther = [dictionary objectForKey:@"allowOther"];

        self.enumeration = [dictionary objectForKey:@"enumeration"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.allowMultiple forKey:@"allowMultiple"];

    [dict setObjectIfNotNil:self.allowOther forKey:@"allowOther"];

    [dict setObjectIfNotNil:self.enumeration forKey:@"enumeration"];

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
