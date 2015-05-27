//
//  SBBBridgeNetworkManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/26/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeNetworkManager.h"
#import "SBBNetworkManagerInternal.h"
#import "SBBAuthManagerInternal.h"
#import "SBBErrors.h"

@interface SBBBridgeNetworkManager ()

@property (nonatomic, strong, readonly) id<SBBAuthManagerInternalProtocol> authManager;

@end

@implementation SBBBridgeNetworkManager

+ (instancetype)defaultComponent
{
    static SBBBridgeNetworkManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initWithAuthManager:SBBComponent(SBBAuthManager)];
    });
    
    return shared;
}

- (instancetype)initWithAuthManager:(id<SBBAuthManagerInternalProtocol>)authManager
{
    if (self = [super init]) {
        _authManager = authManager;
    }
    
    return self;
}

- (void)handleHTTPError:(NSError *)error task:(NSURLSessionDataTask *)task retryObject:(APCNetworkRetryObject *)retryObject
{
    if (retryObject && retryObject.retryBlock && error.code == kSBBServerNotAuthenticated && [_authManager isAuthenticated])
    {
        // clear the stored session token if any, and attempt reauth
        [_authManager clearSessionToken];
        [_authManager ensureSignedInWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            if (error) {
                [super handleHTTPError:error task:task retryObject:retryObject];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    retryObject.retryBlock();
                    // don't count this against retries
                });
            }
        }];
    } else {
        [super handleHTTPError:error task:task retryObject:retryObject];
    }
}

@end
