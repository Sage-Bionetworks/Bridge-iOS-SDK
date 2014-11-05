//
//  SBBUploadSession.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUploadSession.h instead.
//

#import "_SBBUploadSession.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBUploadSession()

@end

/** \ingroup DataModel */

@implementation _SBBUploadSession

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

        self.expires = [NSDate dateWithISO8601String:[dictionary objectForKey:@"expires"]];

        self.id = [dictionary objectForKey:@"id"];

        self.url = [dictionary objectForKey:@"url"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:[self.expires ISO8601String] forKey:@"expires"];

    [dict setObjectIfNotNil:self.id forKey:@"id"];

    [dict setObjectIfNotNil:self.url forKey:@"url"];

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
