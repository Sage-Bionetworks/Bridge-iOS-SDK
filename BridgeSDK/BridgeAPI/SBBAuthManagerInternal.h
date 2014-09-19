//
//  SBBAuthManagerInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/16/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBAuthManager.h"

extern SBBEnvironment gSBBDefaultEnvironment;

@interface SBBAuthManager(internal)


/**
 *  This method is used by other API manager components to inject the session token header for authentication.
 *
 *  @param headers A mutable dictionary containing HTTP header key-value (string) pairs, to which to add the auth header.
 */
- (void)addAuthHeaderToHeaders:(NSMutableDictionary *)headers;

@end