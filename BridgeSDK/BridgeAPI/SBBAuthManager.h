//
//  SBBAuthManager.h
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

#import <Foundation/Foundation.h>
#import "SBBComponent.h"
#import "SBBNetworkManager.h"

/// Global study identifier, specific to each app. Must be set before attempting to access Bridge APIs, usually by calling the BridgeSDK setupWithStudy: class method.
extern  NSString * _Nonnull gSBBAppStudy;

@protocol SBBAuthManagerProtocol;

#pragma mark SBBAuthManagerDelegateProtocol

/*!
 *  This protocol defines the interfaces for the Auth Manager delegate.
 *
 *  Without an Auth Manager delegate, the default SBBAuthManager implementation will keep track of the login
 *  credentials (username and password) and the current session token in the keychain. Implement an Auth Manager
 *  delegate if you want to handle storing those items yourself; in that case the default SBBAuthManager
 *  implementation will not keep track of any of those items itself.
 *
 *  Note that if you implement an Auth Manager delegate at all, you would need to implement at least some of the
 *  optional methods in the delegate protocol to preserve the Bridge SDK's ability to automatically handle
 *  refreshing the session token whenever an API call indicates that it has expired (by returning a 401 HTTP
 *  status code). See the individual method documentation below for details.
 */
@protocol SBBAuthManagerDelegateProtocol <NSObject>
@required

/*!
 *  This delegate method should return the session token for the current signed-in user session,
 *  or nil if not currently signed in to any account.
 *
 *  @note This method is required.
 *
 *  @param authManager The auth manager instance making the delegate request.
 *
 *  @return The session token, or nil.
 */
- (nullable NSString *)sessionTokenForAuthManager:(nonnull id<SBBAuthManagerProtocol>)authManager;

/*!
 *  The auth manager will call this delegate method when it obtains a new session token, so that the delegate
 *  can store it appropriately and return it later in sessionTokenForAuthManager: calls.
 *
 *  @note This method is required.
 *
 *  @param authManager The auth manager instance making the delegate request.
 *  @param sessionToken The session token just obtained by the auth manager.
 */
- (void)authManager:(nullable id<SBBAuthManagerProtocol>)authManager didGetSessionToken:(nullable NSString *)sessionToken;

@optional

/*!
 *  If you implement this delegate method, the auth manager will call it rather than authManager:didGetSessionToken:
 *  when it obtains a new session token, so that the delegate can store the username and password used,
 *  to be returned later in the usernameForAuthManager: and passwordForAuthManager: calls.
 *
 *  @note This method is optional. It provides a convenient interface for keeping track of the auth credentials used in the most recent successful signIn, for re-use when automatically refreshing an expired session token.
 *
 *  @param authManager The auth manager instance making the delegate request.
 *  @param sessionToken The session token just obtained by the auth manager.
 */
- (void)authManager:(nullable id<SBBAuthManagerProtocol>)authManager didGetSessionToken:(nullable NSString *)sessionToken forUsername:(nullable NSString *)username andPassword:(nullable NSString *)password;

/*!
 *  This delegate method should return the username for the user account last signed up for or signed in to,
 *  or nil if the user has never signed up or signed in on this device.
 *
 *  @note This method is optional. If both this and passwordForAuthManager: are provided by the delegate, the SDK can handle refreshing the session token automatically when 401 status codes are received from the Bridge API.
 *
 *  @param authManager The auth manager instance making the delegate request.
 *
 *  @return The username, or nil.
 */
- (nullable NSString *)usernameForAuthManager:(nullable id<SBBAuthManagerProtocol>)authManager;

/*!
 *  This delegate method should return the password for the user account last signed up for or signed in to,
 *  or nil if the user has never signed up or signed in on this device.
 *
 *  @note This method is optional. If both this and usernameForAuthManager: are provided by the delegate, the SDK can handle refreshing the session token automatically when 401 status codes are received from the Bridge API.
 *
 *  @param authManager The auth manager instance making the delegate request.
 *
 *  @return The password, or nil.
 */
- (nullable NSString *)passwordForAuthManager:(nullable id<SBBAuthManagerProtocol>)authManager;

@end

#pragma mark SBBAuthManagerProtocol

/*!
 *  This protocol defines the interface to the SBBAuthManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBAuthManagerProtocol <NSObject>

@property (nonatomic, weak) id<SBBAuthManagerDelegateProtocol> authDelegate;

/*!
 * Sign up for an account with an email address, userName, password, and an optional list of data group tags. 
 * An email will be sent to the specified email address containing a link to verify that this is indeed that
 * person's email. The userName and password won't be valid for signing in until the email has been verified.
 *
 * @param email The email address to be associated with the account.
 * @param username The username to use for the account.
 * @param password The password to use for the account.
 * @param dataGroups An array of dataGroup tags to assign to the user at signup. Optional.
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion. Optional.
 * @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (nonnull NSURLSessionDataTask *)signUpWithEmail:(nonnull NSString *)email username:(nonnull NSString *)username password:(nonnull NSString *)password dataGroups:(nullable NSArray<NSString *> *)dataGroups completion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 * Sign up for an account with an email address, userName, and password. This is a convenience method
 * that calls signUpWithEmail:username:password:dataGroups:completion: with dataGroups set to nil.
 *
 * @param email The email address to be associated with the account.
 * @param username The username to use for the account.
 * @param password The password to use for the account.
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion. Optional.
 * @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (nonnull NSURLSessionDataTask *)signUpWithEmail:(nonnull NSString *)email username:(nonnull NSString *)username password:(nonnull NSString *)password completion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 Request Bridge to re-send the email verification link to the specified email address.
 
 A 404 Not Found HTTP status indicates there is no pending verification for that email address,
 either because it was not used to sign up for an account, or because it has already been verified.
 
 @param email      The email address for which to re-send the verification link.
 @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (nonnull NSURLSessionDataTask *)resendEmailVerification:(nonnull NSString *)email completion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 * Sign in to an existing account with a userName and password.
 *
 * @param username The username of the account being signed into.
 * @param password The password of the account.
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion. The responseObject will be an NSDictionary containing a Bridge API <a href="https://sagebionetworks.jira.com/wiki/display/BRIDGE/UserSessionInfo"> UserSessionInfo</a> object in case you need to refer to it, but the SBBAuthManager handles the session token for all Bridge API access via this SDK, so you can generally ignore it if you prefer. You can convert the responseObject to an SBBUserSessionInfo object (or whatever you've mapped it to) in your completion handler by calling [SBBComponent(SBBObjectManager) objectFromBridgeJSON:responseObject] (or substituting another instance of id<SBBObjectManagerProtocol> if you've set one up).
 * @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (nonnull NSURLSessionDataTask *)signInWithUsername:(nonnull NSString *)username password:(nonnull NSString *)password completion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 * Sign out of the user's Bridge account.
 *
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 * @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (nonnull NSURLSessionDataTask *)signOutWithCompletion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 * Call this at app launch to ensure the user is logged in to their account (if any).
 *
 * The completion block should check for error code kSBBNoCredentialsAvailable and ask the user to sign up/sign in.
 *
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 */
- (void)ensureSignedInWithCompletion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 Request that the password be reset for the account associated with the given email address. An email will be sent
 to that address with instructions for choosing a new password.
 
 @param email The email address associated with the account whose password is to be reset.
 @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (nonnull NSURLSessionDataTask *)requestPasswordResetForEmail:(nonnull NSString *)email completion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 Reset the password for this user's account.
 
 @param password The new password for this user's account.
 @param token    The sptoken sent to the user's email address in response to a requestPasswordResetForEmail: call.
 @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (nonnull NSURLSessionDataTask *)resetPasswordToNewPassword:(nonnull NSString *)password resetToken:(nonnull NSString *)token completion:(nullable SBBNetworkManagerCompletionBlock)completion;

/*!
 *  This method is used by other API manager components to inject the session token header for authentication.
 *
 *  @param headers A mutable dictionary containing HTTP header key-value (string) pairs, to which to add the auth header.
 */
- (void)addAuthHeaderToHeaders:(nonnull NSMutableDictionary *)headers;

@end

#pragma mark SBBAuthManager

/*!
 * This class handles communication with the Bridge authentication API, as well as maintaining
 * authentication credentials obtained therefrom.
 */
@interface SBBAuthManager : NSObject<SBBComponent, SBBAuthManagerProtocol>

/*!
 * Return the default (shared) component of this type (SBBAuthManager), configured with the gSBBAppURLPrefix and
 * the default environment. In debug builds, this is SBBEnvironmentStaging; in release builds, SBBEnvironmentProd.
 * Also configures the component to use the SBBNetworkManager currently registered the first time this is called,
 * or the default if none was registered yet.
 *
 * @return The default (shared) SBBAuthManager component.
 */
+ (nonnull instancetype)defaultComponent;

/*!
 * Return an SBBAuthManager component configured for the specified environment, appURLPrefix, and baseURLPath
 * with a default network manager.
 * 
 * Use this method directly only if you need to redirect your Bridge API accesses to a test server.
 *
 * @param environment The SBBEnvironment to use (prod, staging, dev).
 * @param study The app-specific study identifier to use (typically set in gSBBAppStudy).
 * @param baseURLPath The URL path to prefix with the app server prefix and environment string (e.g. @"sagebridge.org")
 * @return An SBBAuthManager component configured for an environment, appURLPrefix, and baseURLPath.
 */
+ (nonnull instancetype)authManagerForEnvironment:(SBBEnvironment)environment study:(nonnull NSString *)study baseURLPath:(nonnull NSString *)baseURLPath;

/*!
 * Return an SBBAuthManager component configured for the specified baseURL with a default network manager.
 *
 * Use this if you need to test against a custom server. Implies a custom environment for credential storage purposes.
 *
 * @param baseURL The baseURL to use.
 * @return An SBBAuthManager component configured with a specific network manager.
 */
+ (nonnull instancetype)authManagerWithBaseURL:(nonnull NSString *)baseURL;

/*!
 * Return an SBBAuthManager component configured with the specified network manager.
 *
 * Use this if you need to run with a custom network manager. Also implies a custom environment for credential storage purposes.
 *
 * @param networkManager The SBBNetworkManager to use.
 * @return An SBBAuthManager component configured with a specific network manager.
 */
+ (nonnull instancetype)authManagerWithNetworkManager:(nonnull id<SBBNetworkManagerProtocol>)networkManager;

@end
