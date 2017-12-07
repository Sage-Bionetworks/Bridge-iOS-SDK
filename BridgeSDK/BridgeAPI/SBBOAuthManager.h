//
//  SBBOAuthManager.h
//  BridgeSDK
//
//	Copyright (c) 2017, Sage Bionetworks
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

#import "SBBBridgeAPIManager.h"
#import "SBBOAuthAccessToken.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 Completion block called when retrieving an OAuth access token from the API.
 
 @param oauthAccessToken By default, an SBBOAuthAccessToken object, unless the OAuthAccessToken type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:.
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBOAuthManagerGetCompletionBlock)(SBBOAuthAccessToken * _Nullable oauthAccessToken, NSError * _Nullable error);

/*!
 This protocol defines the interface to the SBBOAuthManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBOAuthManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Obtain an OAuth Access Token for the given vendor ID and, optionally, an authorization code.
 
 The authorization code will have been obtained by your app from the vendor (e.g., Fitbit) via their OAuth 2.0 authorization code grant flow. The Bridge server will exchange this code for an access token and a refresh token.
 
 Once you've passed an authorization code to Bridge for a given vendor, you can obtain the current valid access token for that vendor by calling this method with nil as the authCode parameter. If the access token Bridge has on file has expired, it will use the refresh token to get a new one (and a new refresh token) and return the new one.
 
 Access to a locally-cached version of the OAuthAccessToken is not provided by this SDK since you would need a working Internet connection to make use of it anyway. You may, of course, cache it yourself if you so desire, but if you do, you will want to pay attention to the expiration date. As long as the owner of the oauth'ed vendor account doesn't manually revoke the authorization, once access is granted, barring network errors this method should always return a current valid access token.
 
 You might not bother with a completion block if the client doesn't actually need the access token for its own use--for example, you're just having the study participant grant access to their vendor data so Bridge can import it periodically and push it to Synapse tables.
 
 @param vendorId    The Bridge vendor ID for the vendor (e.g. "fitbit") from which you obtained the authorization code.
 @param authCode    The authorization code you obtained from the vendor via their OAuth 2.0 authorization code grant flow. Optional.
 @param completion  An SBBOAuthManagerUpdateCompletionBlock to be called upon completion. Optional.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)getAccessTokenForVendor:(NSString *)vendorId authCode:(nullable NSString *)authCode completion:(nullable SBBOAuthManagerUpdateCompletionBlock)completion;

@end

/*!
 This class handles communication with the Bridge OAuth API.
 */
@interface SBBOAuthManager : SBBBridgeAPIManager<SBBComponent, SBBOAuthManagerProtocol>

@end

NS_ASSUME_NONNULL_END
