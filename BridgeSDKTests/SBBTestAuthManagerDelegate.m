//
//  SBBTestAuthManagerDelegate.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/2/14.
//  Copyright (c) 2014-2017 Sage Bionetworks. All rights reserved.
//

#import "SBBTestAuthManagerDelegate.h"

@implementation SBBTestAuthManagerDelegate

- (NSString *)sessionTokenForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    return _sessionToken;
}

- (void)authManager:(id<SBBAuthManagerProtocol>)authManager didGetSessionToken:(NSString *)sessionToken forEmail:(nullable NSString *)email andPassword:(nullable NSString *)password
{
    _sessionToken = sessionToken;
    _email = email;
    _password = password;
}

- (void)authManager:(id<SBBAuthManagerProtocol>)authManager didReceiveUserSessionInfo:(id)sessionInfo
{
    _sessionInfo = sessionInfo;
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
