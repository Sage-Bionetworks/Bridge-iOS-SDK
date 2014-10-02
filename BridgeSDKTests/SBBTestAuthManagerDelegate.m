//
//  SBBTestAuthManagerDelegate.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/2/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBTestAuthManagerDelegate.h"

@implementation SBBTestAuthManagerDelegate

- (NSString *)sessionTokenForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
  return _sessionToken;
}

- (void)authManager:(id<SBBAuthManagerProtocol>)authManager didGetSessionToken:(NSString *)sessionToken
{
  _sessionToken = sessionToken;
}

- (NSString *)usernameForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
  return _username;
}

- (NSString *)passwordForAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
  return _password;
}

@end
