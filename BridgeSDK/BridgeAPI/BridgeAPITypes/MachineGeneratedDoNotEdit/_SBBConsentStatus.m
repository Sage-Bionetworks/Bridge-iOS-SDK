//
//  SBBConsentStatus.m
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
// Make changes to SBBConsentStatus.h instead.
//

#import "_SBBConsentStatus.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBConsentStatus()

@end

@implementation _SBBConsentStatus

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)consentedValue
{
	return [self.consented boolValue];
}

- (void)setConsentedValue:(BOOL)value_
{
	self.consented = [NSNumber numberWithBool:value_];
}

- (BOOL)requiredValue
{
	return [self.required boolValue];
}

- (void)setRequiredValue:(BOOL)value_
{
	self.required = [NSNumber numberWithBool:value_];
}

- (BOOL)signedMostRecentConsentValue
{
	return [self.signedMostRecentConsent boolValue];
}

- (void)setSignedMostRecentConsentValue:(BOOL)value_
{
	self.signedMostRecentConsent = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        self.consented = [dictionary objectForKey:@"consented"];

        self.name = [dictionary objectForKey:@"name"];

        self.required = [dictionary objectForKey:@"required"];

        self.signedMostRecentConsent = [dictionary objectForKey:@"signedMostRecentConsent"];

        self.subpopulationGuid = [dictionary objectForKey:@"subpopulationGuid"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.consented forKey:@"consented"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

    [dict setObjectIfNotNil:self.required forKey:@"required"];

    [dict setObjectIfNotNil:self.signedMostRecentConsent forKey:@"signedMostRecentConsent"];

    [dict setObjectIfNotNil:self.subpopulationGuid forKey:@"subpopulationGuid"];

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
