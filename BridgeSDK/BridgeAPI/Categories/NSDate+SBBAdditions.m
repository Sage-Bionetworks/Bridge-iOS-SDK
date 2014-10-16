//
//  NSDate+SBBAdditions.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
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

+ (instancetype)dateWithISO8601String:(NSString *)iso8601string
{
  return [[self ISO8601formatter] dateFromString:iso8601string];
}

- (NSString *)ISO8601String
{
  return [[[self class] ISO8601formatter] stringFromDate:self];
}

- (NSString *)ISO8601StringUTC
{
  return [[[self class] ISO8601UTCformatter] stringFromDate:self];
}

@end
