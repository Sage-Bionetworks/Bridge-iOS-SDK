//
//  SBBBridgeNetworkManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/26/15.
//
//	Copyright (c) 2015, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
    if (!gSBBAppStudy) {
        return nil;
    }
    
    static SBBBridgeNetworkManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initWithAuthManager:SBBComponent(SBBAuthManager)];
    });
    
    return shared;
}

- (instancetype)initWithAuthManager:(id<SBBAuthManagerInternalProtocol>)authManager
{
    SBBEnvironment environment = gSBBDefaultEnvironment;
    
    NSString *baseURL = [[self class] baseURLForEnvironment:environment appURLPrefix:kAPIPrefix baseURLPath:@"sagebridge.org"];
    NSString *bridgeStudy = gSBBAppStudy;
    if (self = [super initWithBaseURL:baseURL bridgeStudy:bridgeStudy]) {
        self.environment = environment;
        _authManager = authManager;
    }
    
    return self;
}

- (void)handleHTTPError:(NSError *)error task:(NSURLSessionDataTask *)task retryObject:(APCNetworkRetryObject *)retryObject
{
    if (retryObject && retryObject.retryBlock && error.code == kSBBServerNotAuthenticated && [_authManager isAuthenticated])
    {
#if DEBUG
        NSLog(@"Bridge API call returned status code 401; attempting to refresh session token");
#endif
        // clear the stored session token if any, and attempt reauth
        [_authManager clearSessionToken];
        [_authManager ensureSignedInWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            // ignore 412 Not Consented on signIn when auto-renewing the session token; some Bridge endpoints still work when not consented,
            // and those that don't will themselves return a 412 status code
            BOOL relevantError = (error && error.code != kSBBServerPreconditionNotMet);
            if (relevantError) {
#if DEBUG
                NSLog(@"Session token auto-refresh failed:\n%@", error);
#endif
                [super handleHTTPError:error task:task retryObject:retryObject];
            } else {
#if DEBUG
                NSLog(@"Session token auto-refresh succeeded, retrying original request");
#endif
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

- (NSDictionary *)headersPreparedForRetry:(NSDictionary *)headers
{
    NSMutableDictionary *preparedHeaders = [headers mutableCopy];
    
    // rewrite the auth headers in case the session token got refreshed
    [_authManager addAuthHeaderToHeaders:preparedHeaders];
    
    return preparedHeaders;
}

@end
