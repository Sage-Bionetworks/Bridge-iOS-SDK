//
//  SBBNotificationManager.h
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

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"
#import "SBBGuidHolder.h"

/*!
 Completion block called when posting the device ID.
 
 @param guidHolder a SBBGuidHolder object in relation to our registered device Id
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBNotificationManagerPostDeviceIdCompletionBlock)(SBBGuidHolder* guidHolder, NSError *error);

/*!
 Completion block called when removing notification registration
 
 @param bridgeResponse from the server
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBNotificationManagerCompletionBlock)(id bridgeResponse, NSError *error);

/*!
 *  This protocol defines the interface to the SBBUserManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBNotificationManagerProtocol <SBBBridgeAPIManagerProtocol>

/*
 Should be called with a valid device Id after every app launch, just in case device Id
 has changed since the pervious run of the app
 The SBBNotificationManager handles the case of an existing device Id
 */
- (NSURLSessionTask *)updateRegistrationWithDeviceId:(NSString *)deviceId completion:(SBBNotificationManagerPostDeviceIdCompletionBlock)completion;

/*
 Should be called with a valid device Id after every app launch, just in case device Id
 has changed since the pervious run of the app
 The SBBNotificationManager handles the case of an existing device Id
 @param deviceId is the one returned in AppDelegate
 @param topicGuids a list of notification topics the user should subscribe to
 */
- (NSURLSessionTask *)updateRegistrationWithDeviceId:(NSString *)deviceId subscribeToTopicGuids:(NSArray *)topicGuids completion:(SBBNotificationManagerPostDeviceIdCompletionBlock)completion;

/*
 Should be called when the user signs out, will only send the request if notifications have been previously registered
 */
- (NSURLSessionTask *)deleteNotificationRegistrationWithCompletion:(SBBNotificationManagerCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge users API.
 */
@interface SBBNotificationManager : SBBBridgeAPIManager<SBBComponent, SBBNotificationManagerProtocol>

@end
