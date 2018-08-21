//
//  SBBActivityEventManager.h
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

#import <BridgeSDK/BridgeSDK.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 Completion block called when creating an activity event in Bridge.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBActivityEventManagerCompletionBlock)(_Nullable id responseObject, NSError * _Nullable error);

/*!
 Completion block called when getting the activity events list.
 
 @param activityEventsList By default, an array of SBBActivityEvent objects, unless the ActivityEvent type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:.
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBActivityEventManagerGetCompletionBlock)( NSArray * _Nullable activityEventsList, NSError * _Nullable error);

/*!
 This protocol defines the interface to the SBBActivityEventManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBActivityEventManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Create an activity event in Bridge.
 
 @param eventKey The event key for the activity event.
 @param timestamp The date/time with which to timestamp the event.
 @param completion An SBBActivityEventManagerCompletionBlock to be called upon completion. Optional.
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)createActivityEvent:(NSString *)eventKey withTimestamp:(NSDate *)timestamp completion:(nullable SBBActivityEventManagerCompletionBlock)completion;

/*!
 Get all the activity events for this participant from Bridge.
 
 @param completion An SBBActivityEventManagerGetCompletionBlock to be called upon completion.
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)getActivityEvents:(nullable SBBActivityEventManagerGetCompletionBlock)completion;

@end

/*!
 This class handles communication with the Bridge ActivityEvents API.
 */
@interface SBBActivityEventManager : SBBBridgeAPIManager <SBBComponent, SBBActivityEventManagerProtocol>

@end

NS_ASSUME_NONNULL_END
