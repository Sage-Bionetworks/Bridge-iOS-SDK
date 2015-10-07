//
//  SBBSurvey.m
//
//	Copyright (c) 2014, 2015 Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurvey.h instead.
//

#import "_SBBSurvey.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurvey()

@end

@implementation _SBBSurvey

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)publishedValue
{
	return [self.published boolValue];
}

- (void)setPublishedValue:(BOOL)value_
{
	self.published = [NSNumber numberWithBool:value_];
}

- (double)versionValue
{
	return [self.version doubleValue];
}

- (void)setVersionValue:(double)value_
{
	self.version = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

        self.elements = [dictionary objectForKey:@"elements"];

        self.guid = [dictionary objectForKey:@"guid"];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

        self.name = [dictionary objectForKey:@"name"];

        self.published = [dictionary objectForKey:@"published"];

        self.version = [dictionary objectForKey:@"version"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.elements forKey:@"elements"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:[self.modifiedOn ISO8601String] forKey:@"modifiedOn"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

    [dict setObjectIfNotNil:self.published forKey:@"published"];

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
