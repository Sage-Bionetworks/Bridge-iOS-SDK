//
//  SBBSchedule.m
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
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSchedule.h instead.
//

#import "_SBBSchedule.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSchedule()

@end

@implementation _SBBSchedule

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

        self.activities = [dictionary objectForKey:@"activities"];

        self.cronTrigger = [dictionary objectForKey:@"cronTrigger"];

        self.delay = [dictionary objectForKey:@"delay"];

        self.endsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"endsOn"]];

        self.eventId = [dictionary objectForKey:@"eventId"];

        self.expires = [dictionary objectForKey:@"expires"];

        self.interval = [dictionary objectForKey:@"interval"];

        self.label = [dictionary objectForKey:@"label"];

        self.scheduleType = [dictionary objectForKey:@"scheduleType"];

        self.startsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startsOn"]];

        self.times = [dictionary objectForKey:@"times"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.activities forKey:@"activities"];

    [dict setObjectIfNotNil:self.cronTrigger forKey:@"cronTrigger"];

    [dict setObjectIfNotNil:self.delay forKey:@"delay"];

    [dict setObjectIfNotNil:[self.endsOn ISO8601String] forKey:@"endsOn"];

    [dict setObjectIfNotNil:self.eventId forKey:@"eventId"];

    [dict setObjectIfNotNil:self.expires forKey:@"expires"];

    [dict setObjectIfNotNil:self.interval forKey:@"interval"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.scheduleType forKey:@"scheduleType"];

    [dict setObjectIfNotNil:[self.startsOn ISO8601String] forKey:@"startsOn"];

    [dict setObjectIfNotNil:self.times forKey:@"times"];

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
