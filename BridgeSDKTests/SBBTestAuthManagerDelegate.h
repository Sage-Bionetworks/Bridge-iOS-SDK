//
//  SBBTestAuthManagerDelegate.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/2/14.
//  Copyright (c) 2014-2017 Sage Bionetworks. All rights reserved.
//

#import "SBBAuthManager.h"

@interface SBBTestAuthManagerDelegate : NSObject<SBBAuthManagerDelegateProtocol>

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *sessionToken;

@property (nonatomic, strong) id sessionInfo;

@end
