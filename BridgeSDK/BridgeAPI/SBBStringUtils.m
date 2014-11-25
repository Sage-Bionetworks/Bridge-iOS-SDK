//
//  SBBStringUtils.m
//  BridgeSDK
//
//  Created by Dwayne Jeng on 11/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBStringUtils.h"

@implementation SBBStringUtils

+ (BOOL)isNullOrEmpty:(NSString*)str
{
  return (str == nil) || (str == (NSString*)[NSNull null]) || ([str length] == 0);
}

@end
