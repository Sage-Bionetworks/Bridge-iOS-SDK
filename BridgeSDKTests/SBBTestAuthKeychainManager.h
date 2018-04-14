//
//  SBBTestAuthKeychainManager.h
//  BridgeSDK
//
//  Copyright (c) 2014-2018 Sage Bionetworks. All rights reserved.
//

#import "SBBAuthManager.h"
#import "SBBAuthManagerInternal.h"

@interface SBBTestAuthKeychainManager : NSObject<SBBAuthKeychainManagerProtocol>

@property (nonatomic, strong) NSMutableDictionary *keychain;

@end
