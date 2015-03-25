//
//  SBBImage.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBImage.h instead.
//

#import "_SBBImage.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBImage()

@end

@implementation _SBBImage

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (double)heightValue
{
	return [self.height doubleValue];
}

- (void)setHeightValue:(double)value_
{
	self.height = [NSNumber numberWithDouble:value_];
}

- (double)widthValue
{
	return [self.width doubleValue];
}

- (void)setWidthValue:(double)value_
{
	self.width = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.height = [dictionary objectForKey:@"height"];

        self.source = [dictionary objectForKey:@"source"];

        self.width = [dictionary objectForKey:@"width"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.height forKey:@"height"];

    [dict setObjectIfNotNil:self.source forKey:@"source"];

    [dict setObjectIfNotNil:self.width forKey:@"width"];

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
