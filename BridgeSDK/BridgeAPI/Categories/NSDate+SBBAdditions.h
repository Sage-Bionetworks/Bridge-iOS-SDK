//
//  NSDate+SBBAdditions.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SBBAdditions)

+ (instancetype)dateWithISO8601String:(NSString *)iso8601string;

- (NSString *)ISO8601String;

@end
