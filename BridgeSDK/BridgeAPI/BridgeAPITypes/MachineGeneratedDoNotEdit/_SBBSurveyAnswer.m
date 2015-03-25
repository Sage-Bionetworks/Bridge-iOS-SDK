//
//  SBBSurveyAnswer.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyAnswer.h instead.
//

#import "_SBBSurveyAnswer.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurveyAnswer()

@end

@implementation _SBBSurveyAnswer

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)declinedValue
{
	return [self.declined boolValue];
}

- (void)setDeclinedValue:(BOOL)value_
{
	self.declined = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.answeredOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"answeredOn"]];

        self.answers = [dictionary objectForKey:@"answers"];

        self.client = [dictionary objectForKey:@"client"];

        self.declined = [dictionary objectForKey:@"declined"];

        self.questionGuid = [dictionary objectForKey:@"questionGuid"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:[self.answeredOn ISO8601String] forKey:@"answeredOn"];

    [dict setObjectIfNotNil:self.answers forKey:@"answers"];

    [dict setObjectIfNotNil:self.client forKey:@"client"];

    [dict setObjectIfNotNil:self.declined forKey:@"declined"];

    [dict setObjectIfNotNil:self.questionGuid forKey:@"questionGuid"];

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
