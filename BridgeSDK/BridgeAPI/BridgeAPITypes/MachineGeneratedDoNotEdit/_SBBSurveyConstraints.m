//
//  SBBSurveyConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyConstraints.h instead.
//

#import "_SBBSurveyConstraints.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurveyConstraints()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyConstraints

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

        self.dataType = [dictionary objectForKey:@"dataType"];

        self.rules = [dictionary objectForKey:@"rules"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.dataType forKey:@"dataType"];

    [dict setObjectIfNotNil:self.rules forKey:@"rules"];

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
