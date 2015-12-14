//
//  SBBAuthManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/11/14.
//
//	Copyright (c) 2014, Sage Bionetworks
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
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBAuthManager.h"
#import "SBBAuthManagerInternal.h"
#import "UICKeyChainStore.h"
#import "NSError+SBBAdditions.h"
#import "SBBComponentManager.h"
#import "BridgeSDKInternal.h"

#define AUTH_API GLOBAL_API_PREFIX @"/auth"

NSString * const kSBBAuthSignUpAPI =       AUTH_API @"/signUp";
NSString * const kSBBAuthResendAPI =       AUTH_API @"/resendEmailVerification";
NSString * const kSBBAuthSignInAPI =       AUTH_API @"/signIn";
NSString * const kSBBAuthSignOutAPI =      AUTH_API @"/signOut";
NSString * const kSBBAuthRequestResetAPI = AUTH_API @"/requestResetPassword";
NSString * const kSBBAuthResetAPI =        AUTH_API @"/resetPassword";

NSString *gSBBAppStudy = nil;

NSString *kBridgeKeychainService = @"SageBridge";
NSString *kBridgeAuthManagerFirstRunKey = @"SBBAuthManagerFirstRunCompleted";

static NSString *envSessionTokenKeyFormat[] = {
    @"SBBSessionToken-%@",
    @"SBBSessionTokenStaging-%@",
    @"SBBSessionTokenDev-%@",
    @"SBBSessionTokenCustom-%@"
};

static NSString *envUsernameKeyFormat[] = {
    @"SBBUsername-%@",
    @"SBBUsernameStaging-%@",
    @"SBBusernameDev-%@",
    @"SBBusernameCustom-%@"
};

static NSString *envPasswordKeyFormat[] = {
    @"SBBPassword-%@",
    @"SBBPasswordStaging-%@",
    @"SBBPasswordDev-%@",
    @"SBBPasswordCustom-%@"
};


dispatch_queue_t AuthQueue()
{
    static dispatch_queue_t q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("org.sagebase.BridgeAuthQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return q;
}

// use with care--not protected. Used for serializing access to the auth manager's internal
// copy of the accountAccessToken.
void dispatchSyncToAuthQueue(dispatch_block_t dispatchBlock)
{
    dispatch_sync(AuthQueue(), dispatchBlock);
}

dispatch_queue_t KeychainQueue()
{
    static dispatch_queue_t q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("org.sagebase.BridgeAuthKeychainQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return q;
}

// use with care--not protected. Used for serializing access to the auth credentials stored in the keychain.
// This method can be safely called from within the AuthQueue, but the provided dispatch block must
// never dispatch back to the AuthQueue either directly or indirectly, to prevent deadlocks.
void dispatchSyncToKeychainQueue(dispatch_block_t dispatchBlock)
{
    dispatch_sync(KeychainQueue(), dispatchBlock);
}


@interface SBBAuthManager()

@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) id<SBBNetworkManagerProtocol> networkManager;

+ (void)resetAuthKeychain;

- (instancetype)initWithBaseURL:(NSString *)baseURL;
- (instancetype)initWithNetworkManager:(id<SBBNetworkManagerProtocol>)networkManager;

@end

@implementation SBBAuthManager
@synthesize authDelegate = _authDelegate;
@synthesize sessionToken = _sessionToken;

+ (instancetype)defaultComponent
{
    static SBBAuthManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id<SBBNetworkManagerProtocol> networkManager = SBBComponent(SBBNetworkManager);
        shared = [[self alloc] initWithNetworkManager:networkManager];
        [shared setupForEnvironment];
    });
    
    return shared;
}

+ (instancetype)authManagerForEnvironment:(SBBEnvironment)environment study:(NSString *)study baseURLPath:(NSString *)baseURLPath
{
    SBBNetworkManager *networkManager = [SBBNetworkManager networkManagerForEnvironment:environment study:study
                                                                            baseURLPath:baseURLPath];
    SBBAuthManager *authManager = [[self alloc] initWithNetworkManager:networkManager];
    [authManager setupForEnvironment];
    return authManager;
}

+ (instancetype)authManagerWithNetworkManager:(id<SBBNetworkManagerProtocol>)networkManager
{
    SBBAuthManager *authManager = [[self alloc] initWithNetworkManager:networkManager];
    [authManager setupForEnvironment];
    return authManager;
}

+ (instancetype)authManagerWithBaseURL:(NSString *)baseURL
{
    id<SBBNetworkManagerProtocol> networkManager = [[SBBNetworkManager alloc] initWithBaseURL:baseURL];
    SBBAuthManager *authManager = [[self alloc] initWithNetworkManager:networkManager];
    [authManager setupForEnvironment];
    return authManager;
}

// reset the auth keychain--should be called on first access after first launch; also can be used to clear credentials for testing
+ (void)resetAuthKeychain
{
    dispatchSyncToKeychainQueue(^{
        UICKeyChainStore *store = [self sdkKeychainStore];
        [store removeAllItems];
        [store synchronize];
    });
}

// Find the bundle seed ID of the app that's using our SDK.
// Adapted from this StackOverflow answer: http://stackoverflow.com/a/11841898/931658

+ (NSString *)bundleSeedID {
    static NSString *_bundleSeedID = nil;
    
    // This is always called in the non-concurrent keychain queue, so the dispatch_once
    // construct isn't necessary to ensure it doesn't happen in two threads simultaneously;
    // also apparently it can fail under rare circumstances (???), so we'll handle it this
    // way instead so the app can at least potentially recover the next time it tries.
    // Apps that use an auth delegate to get and store credentials (which currently is
    // all of them) should only call this on first run, once, and it really doesn't matter
    // if it fails because it won't be used.
    if (!_bundleSeedID) {
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               (__bridge id)(kSecClassGenericPassword), kSecClass,
                               @"bundleSeedID", kSecAttrAccount,
                               @"", kSecAttrService,
                               (id)kCFBooleanTrue, kSecReturnAttributes,
                               nil];
        CFDictionaryRef result = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status == errSecItemNotFound)
            status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status == errSecSuccess) {
            NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge id)(kSecAttrAccessGroup)];
            NSArray *components = [accessGroup componentsSeparatedByString:@"."];
            _bundleSeedID = [[components objectEnumerator] nextObject];
        }
        if (result) {
            CFRelease(result);
        }
    }
    
    return _bundleSeedID;
}

+ (NSString *)sdkKeychainAccessGroup
{
    NSString *bundleSeedID = [self bundleSeedID];
    if (!bundleSeedID) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@.org.sagebase.Bridge", bundleSeedID];
}

+ (UICKeyChainStore *)sdkKeychainStore
{
    NSString *accessGroup = self.sdkKeychainAccessGroup;
    if (!accessGroup) {
        return nil;
    }
    return [UICKeyChainStore keyChainStoreWithService:kBridgeKeychainService accessGroup:accessGroup];
}

- (void)setupForEnvironment
{
    if (!_authDelegate) {
        dispatchSyncToAuthQueue(^{
            _sessionToken = [self sessionTokenFromKeychain];
        });
    }
}

- (instancetype)initWithNetworkManager:(SBBNetworkManager *)networkManager
{
    if (self = [super init]) {
        _networkManager = networkManager;
        
        //Clear keychain on first run in case of reinstallation
        BOOL firstRunDone = [[NSUserDefaults standardUserDefaults] boolForKey:kBridgeAuthManagerFirstRunKey];
        if (!firstRunDone) {
            [self.class resetAuthKeychain];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBridgeAuthManagerFirstRunKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)baseURL
{
    SBBNetworkManager *networkManager = [[SBBNetworkManager alloc] initWithBaseURL:baseURL];
    if (self = [self initWithNetworkManager:networkManager]) {
        //
    }
    
    return self;
}

- (NSString *)sessionToken
{
    if (_authDelegate) {
        return [_authDelegate sessionTokenForAuthManager:self];
    } else {
        return _sessionToken;
    }
}

- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password dataGroups:(NSArray<NSString *> *)dataGroups completion:(SBBNetworkManagerCompletionBlock)completion
{
    NSMutableDictionary *params = [@{@"study":gSBBAppStudy, @"email":email, @"username":username, @"password":password, @"type":@"SignUp"} mutableCopy];
    if (dataGroups) {
        [params setObject:dataGroups forKey:@"dataGroups"];
    }
    return [_networkManager post:kSBBAuthSignUpAPI headers:nil parameters:params completion:completion];
}

- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [self signUpWithEmail:email username:username password:password dataGroups:nil completion:completion];
}

- (NSURLSessionDataTask *)resendEmailVerification:(NSString *)email completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [_networkManager post:kSBBAuthResendAPI headers:nil parameters:@{@"study":gSBBAppStudy, @"email":email} completion:completion];
}

- (NSURLSessionDataTask *)signInWithUsername:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [_networkManager post:kSBBAuthSignInAPI headers:nil parameters:@{@"study":gSBBAppStudy, @"username":username, @"password":password, @"type":@"SignIn"} completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        // Save session token in the keychain
        // ??? Save credentials in the keychain?
        NSString *sessionToken = responseObject[@"sessionToken"];
        if (sessionToken.length) {
            if (_authDelegate) {
                if ([_authDelegate respondsToSelector:@selector(authManager:didGetSessionToken:forUsername:andPassword:)]) {
                    [_authDelegate authManager:self didGetSessionToken:sessionToken forUsername:username andPassword:password];
                } else {
                    [_authDelegate authManager:self didGetSessionToken:sessionToken];
                }
            } else {
                dispatchSyncToAuthQueue(^{
                    _sessionToken = sessionToken;
                });
                dispatchSyncToKeychainQueue(^{
                    UICKeyChainStore *store = [self.class sdkKeychainStore];
                    [store setString:_sessionToken forKey:self.sessionTokenKey];
                    [store setString:username forKey:self.usernameKey];
                    [store setString:password forKey:self.passwordKey];
                    
                    [store synchronize];
                });
            }
        }
        
        if (completion) {
            completion(task, responseObject, error);
        }
    }];
}

- (NSURLSessionDataTask *)signOutWithCompletion:(SBBNetworkManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self addAuthHeaderToHeaders:headers];
    return [_networkManager post:kSBBAuthSignOutAPI headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        // Remove the session token (and credentials?) from the keychain
        // ??? Do we want to not do this in case of error?
        if (_authDelegate) {
            if ([_authDelegate respondsToSelector:@selector(authManager:didGetSessionToken:forUsername:andPassword:)] &&
                [_authDelegate respondsToSelector:@selector(usernameForAuthManager:)] &&
                [_authDelegate respondsToSelector:@selector(passwordForAuthManager:)]) {
                [_authDelegate authManager:self didGetSessionToken:nil forUsername:nil andPassword:nil];
            } else {
                [_authDelegate authManager:self didGetSessionToken:nil];
            }
        } else {
            dispatchSyncToKeychainQueue(^{
                UICKeyChainStore *store = [self.class sdkKeychainStore];
                [store removeItemForKey:self.sessionTokenKey];
                [store removeItemForKey:self.usernameKey];
                [store removeItemForKey:self.passwordKey];
                [store synchronize];
            });
            // clear the in-memory copy of the session token, too
            dispatchSyncToAuthQueue(^{
                _sessionToken = nil;
            });
        }
        
        if (completion) {
            completion(task, responseObject, error);
        }
    }];
}

- (void)ensureSignedInWithCompletion:(SBBNetworkManagerCompletionBlock)completion
{
    if ([self isAuthenticated]) {
        if (completion) {
            completion(nil, nil, nil);
        }
    }
    else
    {
        NSString *username = nil;
        NSString *password = nil;
        if (_authDelegate) {
            if ([_authDelegate respondsToSelector:@selector(usernameForAuthManager:)] &&
                [_authDelegate respondsToSelector:@selector(passwordForAuthManager:)]) {
                username = [_authDelegate usernameForAuthManager:self];
                password = [_authDelegate passwordForAuthManager:self];
            }
        } else {
            username = [self usernameFromKeychain];
            password = [self passwordFromKeychain];
        }
        
        if (!username.length || !password.length) {
            if (completion) {
                completion(nil, nil, [NSError SBBNoCredentialsError]);
            }
        }
        else
        {
            [self signInWithUsername:username password:password completion:completion];
        }
    }
}

- (NSURLSessionDataTask *)requestPasswordResetForEmail:(NSString *)email completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [_networkManager post:kSBBAuthRequestResetAPI headers:nil parameters:@{@"study":gSBBAppStudy, @"email":email} completion:completion];
}

- (NSURLSessionDataTask *)resetPasswordToNewPassword:(NSString *)password resetToken:(NSString *)token completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [_networkManager post:kSBBAuthResetAPI headers:nil parameters:@{@"password":password, @"sptoken":token, @"type":@"PasswordReset"} completion:completion];
}

#pragma mark Internal helper methods

- (BOOL)isAuthenticated
{
    return (self.sessionToken.length > 0);
}

- (void)addAuthHeaderToHeaders:(NSMutableDictionary *)headers
{
    if (self.isAuthenticated) {
        [headers setObject:self.sessionToken forKey:@"Bridge-Session"];
    }
}

#pragma mark Internal keychain-related methods

- (NSString *)sessionTokenKey
{
    return [NSString stringWithFormat:envSessionTokenKeyFormat[_networkManager.environment], gSBBAppStudy];
}

- (NSString *)sessionTokenFromKeychain
{
    if (!gSBBAppStudy) {
        return nil;
    }
    
    __block NSString *token = nil;
    dispatchSyncToKeychainQueue(^{
        token = [[self.class sdkKeychainStore] stringForKey:[self sessionTokenKey]];
    });
    
    return token;
}

- (NSString *)usernameKey
{
    return [NSString stringWithFormat:envUsernameKeyFormat[_networkManager.environment], gSBBAppStudy];
}

- (NSString *)usernameFromKeychain
{
    if (!gSBBAppStudy) {
        return nil;
    }
    
    __block NSString *token = nil;
    dispatchSyncToKeychainQueue(^{
        token = [[self.class sdkKeychainStore] stringForKey:[self usernameKey]];
    });
    
    return token;
}

- (NSString *)passwordKey
{
    return [NSString stringWithFormat:envPasswordKeyFormat[_networkManager.environment], gSBBAppStudy];
}

- (NSString *)passwordFromKeychain
{
    if (!gSBBAppStudy) {
        return nil;
    }
    
    __block NSString *token = nil;
    dispatchSyncToKeychainQueue(^{
        token = [[self.class sdkKeychainStore] stringForKey:[self passwordKey]];
    });
    
    return token;
}

#pragma mark SDK-private methods

// used internally for unit testing
- (void)clearKeychainStore
{
    dispatchSyncToKeychainQueue(^{
        UICKeyChainStore *store = [self.class sdkKeychainStore];
        [store removeAllItems];
        [store synchronize];
    });
}

// used internally for unit testing
- (void)setSessionToken:(NSString *)sessionToken
{
    if (sessionToken.length) {
        if (_authDelegate) {
            [_authDelegate authManager:self didGetSessionToken:sessionToken];
        } else {
            dispatchSyncToAuthQueue(^{
                _sessionToken = sessionToken;
            });
            dispatchSyncToKeychainQueue(^{
                UICKeyChainStore *store = [self.class sdkKeychainStore];
                [store setString:_sessionToken forKey:self.sessionTokenKey];
                
                [store synchronize];
            });
        }
    }
}

// used by SBBBridgeNetworkManager to auto-reauth when session tokens expire
- (void)clearSessionToken
{
    if (_authDelegate) {
        [_authDelegate authManager:self didGetSessionToken:nil];
    } else {
        dispatchSyncToAuthQueue(^{
            _sessionToken = nil;
        });
        dispatchSyncToKeychainQueue(^{
            UICKeyChainStore *store = [self.class sdkKeychainStore];
            [store setString:nil forKey:self.sessionTokenKey];
            
            [store synchronize];
        });
    }
}

@end
