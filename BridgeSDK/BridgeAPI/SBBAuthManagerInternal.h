//
//  SBBAuthManagerInternal.h
//  BridgeSDK
//
//	Copyright (c) 2014-2018, Sage Bionetworks
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
#import "SBBCacheManager.h"
#import "SBBObjectManagerInternal.h"

extern NSString * const kSBBAuthSignUpAPI;
extern NSString * const kSBBAuthResendAPI;
extern NSString * const kSBBAuthSignInAPI;
extern NSString * const kSBBAuthReauthAPI;
extern NSString * const kSBBAuthEmailAPI;
extern NSString * const kSBBAuthEmailSignInAPI;
extern NSString * const kSBBAuthPhoneAPI;
extern NSString * const kSBBAuthPhoneSignInAPI;
extern NSString * const kSBBAuthSignOutAPI;
extern NSString * const kSBBAuthRequestResetAPI;
extern NSString * const kSBBAuthResetAPI;

@protocol SBBAuthKeychainManagerProtocol

- (void)clearKeychainStore;

- (void)setKeysAndValues:(NSDictionary<NSString *, NSString *> *)keysAndValues;
- (NSString *)valueForKey:(NSString *)key;
- (void)removeValuesForKeys:(NSArray<NSString *> *)keys;

@end

@protocol SBBAuthManagerInternalProtocol <SBBAuthManagerProtocol>

- (NSURLSessionTask *)attemptSignInWithStoredCredentialsWithCompletion:(SBBNetworkManagerCompletionBlock)completion;
- (void)setSessionToken:(NSString *)sessionToken;
- (void)clearSessionToken;
- (void)postNewSessionInfo:(id)sessionInfo;
- (BOOL)canAuthenticate;
- (void)attemptReauthWithCompletion:(SBBNetworkManagerCompletionBlock)completion;

@end

@interface SBBAuthManager()<SBBAuthManagerInternalProtocol>

@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) id<SBBNetworkManagerProtocol> networkManager;
@property (nonatomic, strong) id<SBBCacheManagerProtocol> cacheManager;
@property (nonatomic, strong) id<SBBObjectManagerProtocol> objectManager;
@property (nonatomic, strong) SBBUserSessionInfo *placeholderSessionInfo;

// so we can override the "keychain" for testing purposes
@property (nonatomic, strong) id<SBBAuthKeychainManagerProtocol> keychainManager;

- (instancetype)initWithBaseURL:(NSString *)baseURL;
- (instancetype)initWithNetworkManager:(id<SBBNetworkManagerProtocol>)networkManager;

- (void)postUserSessionUpdatedNotification;

- (NSString *)savedEmail;
- (NSString *)savedPassword;
- (NSString *)savedReauthToken;
- (NSString *)savedSessionToken;

- (NSString *)passwordKey;
- (NSString *)reauthTokenKey;
- (NSString *)sessionTokenKey;

@end
