//
//  TestAdminAuthDelegate.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/21/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "TestAdminAuthDelegate.h"

@implementation TestAdminAuthDelegate

- (void)authManager:(id<SBBAuthManagerProtocol>)authManager didGetSessionToken:(NSString *)sessionToken
{
    _sessionToken = sessionToken;
}

- (NSString *)sessionTokenForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return _sessionToken;
}

@end
