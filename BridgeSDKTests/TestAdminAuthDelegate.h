//
//  TestAdminAuthDelegate.h
//  BridgeSDK
//
//  Created by Erin Mounts on 7/21/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

@import BridgeSDK;

@interface TestAdminAuthDelegate : NSObject <SBBAuthManagerDelegateProtocol>

@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

@end
