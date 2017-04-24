//
//  NSDate+SBBAdditions.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/29/14.
//
//	Copyright (c) 2014, Sage Bionetworks
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

#import "NSDate+SBBAdditions.h"

@implementation NSDate (SBBAdditions)

+ (NSDateFormatter *)ISO8601formatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:enUSPOSIXLocale];
    });
    
    return formatter;
}

+ (NSDateFormatter *)ISO8601UTCformatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[self ISO8601formatter] copy];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    });
    
    return formatter;
}

+ (NSDateFormatter *)ISO8601DateOnlyformatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[self ISO8601formatter] copy];
        [formatter setDateFormat:@"yyyy-MM-dd"];
    });
    
    return formatter;
}

+ (NSDateFormatter *)ISO8601TimeOnlyformatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[self ISO8601formatter] copy];
        [formatter setDateFormat:@"HH:mm:ss.SSS"];
    });
    
    return formatter;
}

+ (NSDateFormatter *)ISO8601DateTimeOnlyformatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[self ISO8601formatter] copy];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    });
    
    return formatter;
}

+ (NSDateFormatter *)ISO8601OffsetOnlyformatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"xxx"]; // ZZZZZ gives 'Z' for GMT-0, xxx gives '+00:00' but otherwise identical
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:enUSPOSIXLocale];
    });
    
    return formatter;
}

+ (instancetype)dateWithISO8601String:(NSString *)iso8601string
{
    NSDate *date = [[self ISO8601formatter] dateFromString:iso8601string];
    // check for missing TZ specifier
    if (!date) {
        date = [[self ISO8601DateTimeOnlyformatter] dateFromString:iso8601string];
    }
    // check for missing time of day entirely
    if (!date) {
        date = [[self ISO8601DateOnlyformatter] dateFromString:iso8601string];
    }
  return date;
}

- (NSString *)ISO8601String
{
    return [[[self class] ISO8601formatter] stringFromDate:self];
}

- (NSString *)ISO8601StringUTC
{
    return [[[self class] ISO8601UTCformatter] stringFromDate:self];
}

- (NSString *)ISO8601DateOnlyString
{
    return [[[self class] ISO8601DateOnlyformatter] stringFromDate:self];
}

- (NSString *)ISO8601TimeOnlyString
{
    return [[[self class] ISO8601TimeOnlyformatter] stringFromDate:self];
}

- (NSString *)ISO8601DateTimeOnlyString
{
    return [[[self class] ISO8601DateTimeOnlyformatter] stringFromDate:self];
}

- (NSString *)ISO8601OffsetString
{
    return [[[self class] ISO8601OffsetOnlyformatter] stringFromDate:self];
}

@end
