//
//  TestAdminAuthDelegate.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/21/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "TestAdminAuthDelegate.h"
#import "SBBAuthManager.h"

@implementation TestAdminAuthDelegate

- (void)authManager:(id<SBBAuthManagerProtocol>)authManager didGetSessionToken:(NSString *)sessionToken forEmail:(NSString *)email andPassword:(NSString *)password
{
    _sessionToken = sessionToken;
    _email = email;
    _password = password;
}

- (NSString *)sessionTokenForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return _sessionToken;
}

- (NSString *)emailForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return _email;
}

- (NSString *)passwordForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return _password;
}

@end
