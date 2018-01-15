//
//  SBBNotificationManager.h
//  BridgeSDK
//
//    Copyright (c) 2018, Sage Bionetworks
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//        * Redistributions of source code must retain the above copyright
//          notice, this list of conditions and the following disclaimer.
//        * Redistributions in binary form must reproduce the above copyright
//          notice, this list of conditions and the following disclaimer in the
//          documentation and/or other materials provided with the distribution.
//        * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//          contributors may be used to endorse or promote products derived from
//          this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

#import "SBBBridgeAPIManager.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 Completion block called when registering/unregistering for notifications.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBNotificationManagerCompletionBlock)(_Nullable id responseObject, NSError * _Nullable error);

/*!
 Completion block called when getting the topic subscription status list or updating subscriptions.
 
 @param statusList By default, an array of SBBSubscriptionStatus objects, unless the SubscriptionStatus type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:.
 @param subscribedGuids As a convenience, the completion handler includes an array of just those topicGuids to which this account is now subscribed.
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBNotificationManagerSubscriptionStatusCompletionBlock)( NSArray * _Nullable statusList,  NSArray<NSString *> * _Nullable subscribedGuids, NSError * _Nullable error);

/*!
 This protocol defines the interface to the SBBNotificationManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBNotificationManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Register the push notifications deviceId (provided by iOS when registering for push notifications) with Bridge.
 
 You should call this method in the AppDelegate's application:didRegisterForRemoteNotificationsWithDeviceToken: method (or application(_:didRegisterForRemoteNotificationsWithDeviceToken:) in Swift). If this account is not already registered with Bridge for push notifications, it will be registered. If it is, the registration will be updated in case the deviceToken has changed.
 
 @param deviceToken The device token passed in to the app delegate upon registering with iOS for push notifications via the AppDelegate's application:didRegisterForRemoteNotificationsWithDeviceToken: method (or application(_:didRegisterForRemoteNotificationsWithDeviceToken:) in Swift).
 @param completion An SBBNotificationManagerCompletionBlock to be called upon completion.
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)registerWithDeviceToken:(NSData *)deviceToken completion:(nullable SBBNotificationManagerCompletionBlock)completion;

/*!
 Unregister for push notifications from Bridge.
 
 You should call this method if the participant changes their notification permission settings to not allow push notifications.
 
 @param completion An SBBNotificationManagerCompletionBlock to be called upon completion.
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)unregisterWithCompletion:(nullable SBBNotificationManagerCompletionBlock)completion;

/*!
 Get current notification topic subscription statuses from Bridge.
 
 @param completion An SBBNotificationManagerSubscriptionStatusCompletionBlock to be called upon completion.
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)getSubscriptionStatuses:(nullable SBBNotificationManagerSubscriptionStatusCompletionBlock)completion;

/*!
 Update notification topic subscriptions to Bridge.
 
 If the app is not currently registered for push notifications with Bridge, this will return nil and will call the completion handler with error code SBBErrorCodeNotRegisteredForPushNotifications.
 
 @param topicGuids An array of topicGuid strings to which the account should be subscribed. Any topics whose guids are *not* in this array will be unsubscribed. Passing in an empty NSArray will unsubscribe the participant from all topics.
 @param completion An SBBNotificationManagerSubscriptionStatusCompletionBlock to be called upon completion.
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)subscribeToTopicGuids:(NSArray<NSString *> *)topicGuids completion:(SBBNotificationManagerSubscriptionStatusCompletionBlock)completion;

@end

/*!
 This class handles communication with the Bridge Notifications API.
 */
@interface SBBNotificationManager : SBBBridgeAPIManager <SBBComponent, SBBNotificationManagerProtocol>

@end

NS_ASSUME_NONNULL_END
