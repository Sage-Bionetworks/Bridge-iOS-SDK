//
//  SBBStringUtils.h
//  BridgeSDK
//
//  Created by Dwayne Jeng on 11/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#ifndef BridgeSDK_SBBStringUtils_h
#define BridgeSDK_SBBStringUtils_h

#import <Foundation/Foundation.h>

/*! Utility class for strings. */
@interface SBBStringUtils : NSObject

/*! Checks if a string is null or empty, with support for NSNull types. */
+ (BOOL)isNullOrEmpty:(NSString*)str;

@end

#endif
