//
//  SBBBridgeErrorUIDelegate.h
//  BridgeSDK
//
// Copyright (c) 2016, Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <BridgeSDK/SBBNetworkManager.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * If the error UI delegate conforms to this protocol then the methods included will be called as appropriate.
 */
@protocol SBBBridgeErrorUIDelegate <NSObject>

@optional
/**
 * Method called when the Bridge services return an error code that this version of the app is no longer supported.
 * If not implemented or returns @NO then the BridgeNetworkManager will just log the error to the console.
 * In any case it will also pass the error through to the completion handler of the call that triggered the error.
 * This method will only be called once per app launch.
 *
 * @return @YES if the error has been handled by the delegate.
 */
- (BOOL)handleUnsupportedAppVersionError:(NSError *)error networkManager:(id<SBBNetworkManagerProtocol> _Nullable)networkManager;

@optional
/**
 * Method called when the Bridge services return an error code that the user has not consented.
 * If not implemented or returns @NO then the BridgeNetworkManager will just log the error to the console.
 * In any case it will also pass the error through to the completion handler of the call that triggered the error.
 *
 * The sessionInfo object will be of type SBBUserSessionInfo unless the UserSessionInfo type has been mapped in
 * SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:.
 *
 * @return @YES if the error has been handled by the delegate.
 */
- (BOOL)handleUserNotConsentedError:(NSError*)error sessionInfo:(id)sessionInfo networkManager:(id<SBBNetworkManagerProtocol> _Nullable)networkManager;

@end

NS_ASSUME_NONNULL_END
