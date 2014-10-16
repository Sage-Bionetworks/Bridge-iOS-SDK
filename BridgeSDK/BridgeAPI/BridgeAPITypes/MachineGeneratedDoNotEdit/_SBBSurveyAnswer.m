//
//  SBBSurveyAnswer.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyAnswer.h instead.
//

#import "_SBBSurveyAnswer.h"

@interface _SBBSurveyAnswer()

@end

/** \ingroup DataModel */

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

    self.answer = [dictionary objectForKey:@"answer"];

    self.answeredOn = [dictionary objectForKey:@"answeredOn"];

    self.client = [dictionary objectForKey:@"client"];

    self.declined = [dictionary objectForKey:@"declined"];

    self.questionGuid = [dictionary objectForKey:@"questionGuid"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
	[dict setObjectIfNotNil:self.answer forKey:@"answer"];
	[dict setObjectIfNotNil:self.answeredOn forKey:@"answeredOn"];
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
