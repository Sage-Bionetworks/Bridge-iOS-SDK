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
#import "BridgeSDK+Internal.h"
#import "SBBUserManagerInternal.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBParticipantManagerInternal.h"
#import "ModelObjectInternal.h"
#import <objc/runtime.h>

#define AUTH_API V3_API_PREFIX @"/auth"

NSString * const kSBBAuthSignUpAPI =       AUTH_API @"/signUp";
NSString * const kSBBAuthResendAPI =       AUTH_API @"/resendEmailVerification";
NSString * const kSBBAuthSignInAPI =       AUTH_API @"/signIn";
NSString * const kSBBAuthSignOutAPI =      AUTH_API @"/signOut";
NSString * const kSBBAuthRequestResetAPI = AUTH_API @"/requestResetPassword";
NSString * const kSBBAuthResetAPI =        AUTH_API @"/resetPassword";

NSString *kBridgeKeychainService = @"SageBridge";
NSString *kBridgeAuthManagerFirstRunKey = @"SBBAuthManagerFirstRunCompleted";

static NSString *envSessionTokenKeyFormat[] = {
    @"SBBSessionToken-%@",
    @"SBBSessionTokenStaging-%@",
    @"SBBSessionTokenDev-%@",
    @"SBBSessionTokenCustom-%@"
};

static NSString *envEmailKeyFormat[] = {
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


@implementation SBBSignUp

- (void)saveToCoreDataCacheWithObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // stub this out to prevent attempting to save non-cacheable object to CoreData cache
    return;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
    [dict setObjectIfNotNil:self.password forKey:@"password"];
    
    return dict;
}

@end


@interface SBBAuthManager()

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
        NSUserDefaults *defaults = [BridgeSDK sharedUserDefaults];
        BOOL firstRunDone = [defaults boolForKey:kBridgeAuthManagerFirstRunKey];
        if (!firstRunDone) {
            [self.class resetAuthKeychain];
            [defaults setBool:YES forKey:kBridgeAuthManagerFirstRunKey];
            [defaults synchronize];
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

- (void)setAuthDelegate:(id<SBBAuthManagerDelegateProtocol>)delegate
{
    _authDelegate = delegate;
    
    // give it the current UserSessionInfo on startup (creating one as a placeholder for onboarding if the participant is not already signed in)
    if ([delegate respondsToSelector:@selector(authManager:didReceiveUserSessionInfo:)] && gSBBUseCache) {
        NSString *userSessionInfoType = SBBUserSessionInfo.entityName;
        SBBUserSessionInfo *info = (SBBUserSessionInfo *)[self.cacheManager cachedSingletonObjectOfType:userSessionInfoType createIfMissing:NO];
        if (info) {
            
            self.placeholderSessionInfo = nil;
        } else {
            info = self.placeholderSessionInfo;
        }
        
        [delegate authManager:nil didReceiveUserSessionInfo:info];
    }
}

- (id<SBBCacheManagerProtocol>)cacheManager {
    if (!_cacheManager) {
        if ([self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
            _cacheManager = ((id<SBBObjectManagerInternalProtocol>)self.objectManager).cacheManager;
        } else {
            _cacheManager = SBBComponent(SBBCacheManager);
        }
    }
    
    return _cacheManager;
}

- (id<SBBObjectManagerProtocol>)objectManager {
    if (!_objectManager) {
        _objectManager = SBBComponent(SBBObjectManager);
    }
    
    return _objectManager;
}


- (SBBUserSessionInfo *)placeholderSessionInfo {
    // If we're using cache, and not authed yet, and we've set an auth delegate that expects to receive
    // UserSessionInfo updates, the app is in the onboarding phase and may find it useful to have a
    // StudyParticipant object to pre-populate before calling signUp. In that case, we create a blank placeholder
    // SBBUserSessionInfo with SBBStudyParticipant, and SBBStudyParticipantCustomAttributes (if any have been declared),
    // to give to the delegate. Otherwise, we just return whatever we have (presumably nil but we really don't care).
    if (!_placeholderSessionInfo) {
        SBBUserSessionInfo *info = [[SBBUserSessionInfo alloc] init];
        info.studyParticipant = [[SBBStudyParticipant alloc] init];
        
        // if the custom attributes object has any properties (they'd be defined in a category), include it as well
        unsigned int numProperties;
        objc_property_t *properties = class_copyPropertyList(SBBStudyParticipantCustomAttributes.class, &numProperties);
        free(properties);
        
        if (numProperties > 0) {
            info.studyParticipant.attributes = [[SBBStudyParticipantCustomAttributes alloc] init];
        }
        _placeholderSessionInfo = info;
    }

    return _placeholderSessionInfo;
}

- (NSString *)sessionToken
{
    if (_authDelegate) {
        return [_authDelegate sessionTokenForAuthManager:self];
    } else {
        return _sessionToken;
    }
}

- (NSURLSessionTask *)signUpStudyParticipant:(SBBSignUp *)signUp completion:(SBBNetworkManagerCompletionBlock)completion
{
    // If there's a placeholder StudyParticipant object, it may be partially filled-in, so let's start with that
    SBBStudyParticipant *studyParticipant = self.placeholderSessionInfo.studyParticipant;
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    NSMutableDictionary *attributesJson = [NSMutableDictionary dictionary];
    NSMutableSet<NSString *> *dataGroups = [NSMutableSet set];
    NSString *attributesKey = NSStringFromSelector(@selector(attributes));
    NSString *dataGroupsKey = NSStringFromSelector(@selector(dataGroups));
    if (studyParticipant) {
        json = [[self.objectManager bridgeJSONFromObject:studyParticipant] mutableCopy];
        attributesJson = [[json valueForKey:attributesKey] mutableCopy];
        dataGroups = [studyParticipant.dataGroups mutableCopy];
    }
    
    // now overwrite with entries from signUp object
    NSDictionary *signUpJson = [signUp dictionaryRepresentation];
    NSDictionary *signUpAttributesJson = [signUpJson valueForKey:attributesKey];
    NSSet<NSString *> *signUpDataGroups = signUp.dataGroups;
    [json addEntriesFromDictionary:signUpJson];
    
    // also merge attributes and dataGroups by overwriting with entries from signUp
    [attributesJson addEntriesFromDictionary:signUpAttributesJson];
    [json setValue:attributesJson forKey:attributesKey];
    [dataGroups unionSet:signUpDataGroups];
    NSArray *dataGroupsArray = [dataGroups allObjects];
    [json setValue:dataGroupsArray forKey:dataGroupsKey];
    
    json[@"study"] = [SBBBridgeInfo shared].studyIdentifier;
    return [_networkManager post:kSBBAuthSignUpAPI headers:nil parameters:json completion:completion];
}

- (NSURLSessionTask *)signUpWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password dataGroups:(NSArray<NSString *> *)dataGroups completion:(SBBNetworkManagerCompletionBlock)completion
{
    SBBSignUp *signUp = [[SBBSignUp alloc] init];
    signUp.email = email;
    // username is long-since deprecated on Bridge server; ignore
    signUp.password = password;
    signUp.dataGroups = [NSSet setWithArray:dataGroups];
    return [self signUpStudyParticipant:signUp completion:completion];
}

- (NSURLSessionTask *)signUpWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self signUpWithEmail:email username:username password:password dataGroups:nil completion:completion];
#pragma clang diagnostic pop
}

- (NSURLSessionTask *)resendEmailVerification:(NSString *)email completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [_networkManager post:kSBBAuthResendAPI headers:nil parameters:@{@"study":[SBBBridgeInfo shared].studyIdentifier, @"email":email} completion:completion];
}

- (void)resetUserSessionInfo
{
    // clear the placeholder session info so it will be recreated fresh
    _placeholderSessionInfo = nil;
    
    // now, if there's an auth delegate and it expects UserSessionInfo updates, set it again
    // so it will get a fresh set of placeholders.
    id<SBBAuthManagerDelegateProtocol> delegate = self.authDelegate;
    if (gSBBUseCache && !self.isAuthenticated && [delegate respondsToSelector:@selector(authManager:didReceiveUserSessionInfo:)]) {
        [self setAuthDelegate:delegate];

    }
}

- (NSURLSessionTask *)signInWithUsername:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [self signInWithEmail:username password:password completion:completion];
}

- (NSURLSessionTask *)signInWithEmail:(NSString *)email password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [_networkManager post:kSBBAuthSignInAPI headers:nil parameters:@{@"study":[SBBBridgeInfo shared].studyIdentifier, @"email":email, @"password":password, @"type":@"SignIn"} completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        // check for and handle app version out of date error (n.b.: our networkManager instance is a vanilla one, and we need
        // a Bridge network manager for this)
        id<SBBBridgeNetworkManagerProtocol> bridgeNetworkManager = (id<SBBBridgeNetworkManagerProtocol>)SBBComponent(SBBBridgeNetworkManager);
        BOOL handledUnsupportedAppVersionError = [bridgeNetworkManager checkForAndHandleUnsupportedAppVersionHTTPError:error];
        if (handledUnsupportedAppVersionError) {
            // don't call the completion handler, just bail
            return;
        }
        
        // Save session token in the keychain
        // ??? Save credentials in the keychain?
        NSString *sessionToken = responseObject[@"sessionToken"];
        if (sessionToken.length) {
            // Sign-in was successful.
            
            if (_authDelegate) {
                [_authDelegate authManager:self didGetSessionToken:sessionToken forEmail:email andPassword:password];
            } else {
                dispatchSyncToAuthQueue(^{
                    _sessionToken = sessionToken;
                });
                dispatchSyncToKeychainQueue(^{
                    UICKeyChainStore *store = [self.class sdkKeychainStore];
                    [store setString:_sessionToken forKey:self.sessionTokenKey];
                    [store setString:email forKey:self.emailKey];
                    [store setString:password forKey:self.passwordKey];
                    
                    [store synchronize];
                });
            }
            
            // If a user's StudyParticipant object is edited in the researcher UI, the session will be invalidated.
            // Since client-writable objects are not updated from the server once first cached, we need to clear this
            // out of our cache before reading the response object into the cache so we will get the server-side changes.
            // We wait until now to do it because until sign-in succeeds, to the best of our knowledge what's in
            // the cache is still valid; and if the user's email is retrievable (if auth delegate exists, it implements
            // emailForAuthManager:) then that is used in generating the persistent store path so we need to do this
            // here, were we know it will be available.
            
            [(id <SBBUserManagerInternalProtocol>)SBBComponent(SBBUserManager) clearUserInfoFromCache];
            [(id <SBBParticipantManagerInternalProtocol>)SBBComponent(SBBParticipantManager) clearUserInfoFromCache];
            
            // This method's signature was set in stone before UserSessionInfo existed, let alone StudyParticipant
            // (which UserSessionInfo now extends), so we can't return the values directly from here. But we do
            // want to update them in the cache, which calling objectFromBridgeJSON: will do.
            
            // ETA since the StudyParticipant is stored encrypted and uses the login password
            // as the encryption key, we need to do this after checking/calling the auth delegate
            // and/or storing the password to the keychain ourselves. emm2017-01-19
            
            // As a result, we also have to wait until here to tell the auth delegate about the new UserSessionInfo,
            // rather than just passing it to the delegate in the above call in place of the sessionToken. emm2017-06-01
            id sessionInfo = [self.objectManager objectFromBridgeJSON:responseObject];
            [self notifyDelegateOfNewSessionInfo:sessionInfo];
        }
        
        if (completion) {
            completion(task, responseObject, error);
        }
    }];
}

- (void)notifyDelegateOfNewSessionInfo:(id)sessionInfo
{
    if ([_authDelegate respondsToSelector:@selector(authManager:didReceiveUserSessionInfo:)]) {
        [_authDelegate authManager:self didReceiveUserSessionInfo:sessionInfo];
    }
}

- (NSURLSessionTask *)signOutWithCompletion:(SBBNetworkManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self addAuthHeaderToHeaders:headers];
    return [_networkManager post:kSBBAuthSignOutAPI headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        // Remove the session token and credentials from the keychain
        // ??? Do we want to not do this in case of error?
        if (_authDelegate) {
            [_authDelegate authManager:self didGetSessionToken:nil forEmail:nil andPassword:nil];
        } else {
            dispatchSyncToKeychainQueue(^{
                UICKeyChainStore *store = [self.class sdkKeychainStore];
                [store removeItemForKey:self.sessionTokenKey];
                [store removeItemForKey:self.emailKey];
                [store removeItemForKey:self.passwordKey];
                [store synchronize];
            });
            // clear the in-memory copy of the session token, too
            dispatchSyncToAuthQueue(^{
                _sessionToken = nil;
            });
        }
        
        [self.cacheManager resetCache];

        if ([_authDelegate respondsToSelector:@selector(authManager:didReceiveUserSessionInfo:)]) {
            [_authDelegate authManager:self didReceiveUserSessionInfo:nil];
        }

        if (completion) {
            completion(task, responseObject, error);
        }
    }];
}

- (NSString *)savedEmail
{
    NSString *email = nil;
    if (_authDelegate) {
        if ([_authDelegate respondsToSelector:@selector(emailForAuthManager:)]) {
            email = [_authDelegate emailForAuthManager:self];
        } else if ([_authDelegate respondsToSelector:@selector(usernameForAuthManager:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            email = [_authDelegate usernameForAuthManager:self];
#pragma clang diagnostic pop
        }
    } else {
        email = [self emailFromKeychain];
    }
    
    return email;
}

- (NSString *)savedPassword
{
    NSString *password = nil;
    if (_authDelegate) {
        if ([_authDelegate respondsToSelector:@selector(passwordForAuthManager:)]) {
            password = [_authDelegate passwordForAuthManager:self];
        }
    } else {
        password = [self passwordFromKeychain];
    }
    
    return password;
}

- (NSURLSessionTask *)attemptSignInWithStoredCredentialsWithCompletion:(SBBNetworkManagerCompletionBlock)completion
{
    NSString *email = [self savedEmail];
    NSString *password = [self savedPassword];
    
    if (!email.length || !password.length) {
        if (completion) {
            completion(nil, nil, [NSError SBBNoCredentialsError]);
        }
        return nil;
    }
    else
    {
        return [self signInWithEmail:email password:password completion:completion];
    }
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
        [self attemptSignInWithStoredCredentialsWithCompletion:completion];
    }
}

- (NSURLSessionTask *)requestPasswordResetForEmail:(NSString *)email completion:(SBBNetworkManagerCompletionBlock)completion
{
    return [_networkManager post:kSBBAuthRequestResetAPI headers:nil parameters:@{@"study":[SBBBridgeInfo shared].studyIdentifier, @"email":email} completion:completion];
}

- (NSURLSessionTask *)resetPasswordToNewPassword:(NSString *)password resetToken:(NSString *)token completion:(SBBNetworkManagerCompletionBlock)completion
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
    return [NSString stringWithFormat:envSessionTokenKeyFormat[_networkManager.environment], [SBBBridgeInfo shared].studyIdentifier];
}

- (NSString *)sessionTokenFromKeychain
{
    if (![SBBBridgeInfo shared].studyIdentifier) {
        return nil;
    }
    
    __block NSString *token = nil;
    dispatchSyncToKeychainQueue(^{
        token = [[self.class sdkKeychainStore] stringForKey:[self sessionTokenKey]];
    });
    
    return token;
}

- (NSString *)emailKey
{
    return [NSString stringWithFormat:envEmailKeyFormat[_networkManager.environment], [SBBBridgeInfo shared].studyIdentifier];
}

- (NSString *)emailFromKeychain
{
    if (![SBBBridgeInfo shared].studyIdentifier) {
        return nil;
    }
    
    __block NSString *token = nil;
    dispatchSyncToKeychainQueue(^{
        token = [[self.class sdkKeychainStore] stringForKey:[self emailKey]];
    });
    
    return token;
}

- (NSString *)passwordKey
{
    return [NSString stringWithFormat:envPasswordKeyFormat[_networkManager.environment], [SBBBridgeInfo shared].studyIdentifier];
}

- (NSString *)passwordFromKeychain
{
    if (![SBBBridgeInfo shared].studyIdentifier) {
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
    if (_authDelegate) {
        NSString *email = [_authDelegate emailForAuthManager:self];
        NSString *password = [_authDelegate passwordForAuthManager:self];
        [_authDelegate authManager:self didGetSessionToken:sessionToken forEmail:email andPassword:password];
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

// used by SBBBridgeNetworkManager to auto-reauth when session tokens expire
- (void)clearSessionToken
{
    [self setSessionToken:nil];
}

@end
