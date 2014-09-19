//
//  SBBAuthManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/11/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBAuthManager.h"
#import "SBBAuthManagerInternal.h"
#import "UICKeyChainStore.h"
#import "NSError+SBBAdditions.h"

NSString *gSBBAppURLPrefix = nil;
SBBEnvironment gSBBDefaultEnvironment;

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

@property (nonatomic, strong) SBBNetworkManager *networkManager;
@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic) SBBEnvironment environment;

+ (NSString *)baseURLForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath;

+ (void)resetAuthKeychain;

- (instancetype)initWithBaseURL:(NSString *)baseURL;
- (instancetype)initWithNetworkManager:(SBBNetworkManager *)networkManager;

@end

@implementation SBBAuthManager

+ (NSString *)baseURLForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)path
{
  static NSString *envFormatStrings[] = {
    @"%@",
    @"%@-staging",
    @"%@-develop",
    @"%@-custom"
  };
  NSString *baseURL = nil;
  
  if ((NSInteger)environment < sizeof(envFormatStrings) / sizeof(NSString *)) {
    NSString *firstComponent = [NSString stringWithFormat:envFormatStrings[environment], prefix];
    baseURL = [NSString stringWithFormat:@"https://%@.%@", firstComponent, path];
  }
  
  return baseURL;
}

+ (instancetype)defaultComponent
{
  if (!gSBBAppURLPrefix) {
    return nil;
  }
  
  static SBBAuthManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    SBBEnvironment environment = gSBBDefaultEnvironment;
    
    NSString *baseURL = [self baseURLForEnvironment:environment appURLPrefix:gSBBAppURLPrefix baseURLPath:@"sagebridge.org"];
    shared = [[self alloc] initWithBaseURL:baseURL];
    shared.environment = environment;
  });
  
  return shared;
}

+ (instancetype)authManagerForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath
{
  NSString *baseURL = [self baseURLForEnvironment:environment appURLPrefix:prefix baseURLPath:baseURLPath];
  SBBAuthManager *authManager = [[self alloc] initWithBaseURL:baseURL];
  [authManager setupForEnvironment:environment];
  return authManager;
}

+ (instancetype)authManagerWithNetworkManager:(SBBNetworkManager *)networkManager
{
  SBBAuthManager *authManager = [[self alloc] initWithNetworkManager:networkManager];
  [authManager setupForEnvironment:SBBEnvironmentCustom];
  return authManager;
}

+ (instancetype)authManagerWithBaseURL:(NSString *)baseURL
{
  SBBAuthManager *authManager = [[self alloc] initWithBaseURL:baseURL];
  [authManager setupForEnvironment:SBBEnvironmentCustom];
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
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
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
    CFRelease(result);
  });
  
  return _bundleSeedID;
}

+ (NSString *)sdkKeychainAccessGroup
{
  return [NSString stringWithFormat:@"%@.org.sagebase.Bridge", [self bundleSeedID]];
}

+ (UICKeyChainStore *)sdkKeychainStore
{
  return [UICKeyChainStore keyChainStoreWithService:kBridgeKeychainService accessGroup:self.sdkKeychainAccessGroup];
}

- (void)setupForEnvironment:(SBBEnvironment)environment
{
  self.environment = environment;
  dispatchSyncToAuthQueue(^{
    self.sessionToken = [self sessionTokenFromKeychain];
  });
}

- (instancetype)initWithNetworkManager:(SBBNetworkManager *)networkManager
{
  if (self = [super init]) {
    _networkManager = networkManager;
    _environment = SBBEnvironmentCustom;
    
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

- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [_networkManager post:@"api/v1/auth/signUp" headers:nil parameters:@{@"email":email, @"username":username, @"password":password} completion:completion];
}

- (NSURLSessionDataTask *)signInWithUsername:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [_networkManager post:@"api/v1/auth/signIn" headers:nil parameters:@{@"username":username, @"password":password} completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    // Save session token in the keychain
    // ??? Save credentials in the keychain?
    _sessionToken = responseObject[@"sessionToken"];
    if (_sessionToken.length) {
      dispatchSyncToKeychainQueue(^{
        UICKeyChainStore *store = [self.class sdkKeychainStore];
        [store setString:_sessionToken forKey:self.sessionTokenKey];
        [store setString:username forKey:self.usernameKey];
        [store setString:password forKey:self.passwordKey];
        
        [store synchronize];
      });
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
  return [_networkManager get:@"api/v1/auth/signOut" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    // Remove the session token (and credentials?) from the keychain
    // ??? Do we want to not do this in case of error?
    dispatchSyncToKeychainQueue(^{
      UICKeyChainStore *store = [self.class sdkKeychainStore];
      [store removeItemForKey:self.sessionTokenKey];
      [store synchronize];
    });
    // clear the in-memory copy of the session token, too
    dispatchSyncToAuthQueue(^{
      self.sessionToken = nil;
    });
    
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
    NSString *username = [self usernameFromKeychain];
    NSString *password = [self passwordFromKeychain];
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
  return [NSString stringWithFormat:envSessionTokenKeyFormat[self.environment], gSBBAppURLPrefix];
}

- (NSString *)sessionTokenFromKeychain
{
  if (!gSBBAppURLPrefix) {
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
  return [NSString stringWithFormat:envUsernameKeyFormat[self.environment], gSBBAppURLPrefix];
}

- (NSString *)usernameFromKeychain
{
  if (!gSBBAppURLPrefix) {
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
  return [NSString stringWithFormat:envPasswordKeyFormat[self.environment], gSBBAppURLPrefix];
}

- (NSString *)passwordFromKeychain
{
  if (!gSBBAppURLPrefix) {
    return nil;
  }
  
  __block NSString *token = nil;
  dispatchSyncToKeychainQueue(^{
    token = [[self.class sdkKeychainStore] stringForKey:[self passwordKey]];
  });
  
  return token;
}

@end
