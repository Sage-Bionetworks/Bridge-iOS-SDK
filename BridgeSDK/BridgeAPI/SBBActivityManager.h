//
//  SBBActivityManager.h
//  BridgeSDK
//
//	Copyright (c) 2015, Sage Bionetworks
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
#import "SBBScheduledActivity.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 Completion block called when retrieving scheduled activities from the API.
 
 @param activitiesList By default, an array of SBBScheduledActivity objects, unless the ScheduledActivity type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:.
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBActivityManagerGetCompletionBlock)(NSArray * _Nullable activitiesList, NSError * _Nullable error);

/*!
 Completion block called when updating a ScheduledActivity's status to the API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBActivityManagerUpdateCompletionBlock)(_Nullable id responseObject, NSError * _Nullable error);

/*!
 This protocol defines the interface to the SBBActivityManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBActivityManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Gets all the participant's scheduled activities in the specified date range, filling in any that the server hadn't previously scheduled because that part of the date range had never been previously requested.
 
 @param scheduledFrom   The earlier end of the desired date range for activities to be retrieved.
 @param scheduledTo     The later end of the desired date range for activities to be retrieved.
 @param policy          Caching policy to use (ignored if the SDK was initialized with useCache=NO).
 @param completion      An SBBActivityManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)getScheduledActivitiesFrom:(NSDate *)scheduledFrom to:(NSDate *)scheduledTo cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion;

/*!
 This is a convenience method that assumes the default caching policy, which is SBBCachingPolicyFallBackToCached, if caching is enabled.
 */
- (NSURLSessionTask *)getScheduledActivitiesFrom:(NSDate *)scheduledFrom to:(NSDate *)scheduledTo withCompletion:(SBBActivityManagerGetCompletionBlock)completion;

/*!
 Gets all available, started, or scheduled activities for a user. The "daysAhead" parameter allows you to retrieve activities that are scheduled in the future for the indicated number of days past today (to a maximum of four days, at this time). This allows certain kinds of UIs (e.g. "You have N activities tomorrow" or "You have completed N of X activities today", even when the activities are not yet to be performed). A "daysBehind" parameter allows you to retain previously-cached activities that have not yet been completed that expired within the indicated number of days in the past. This allows UIs that say, e.g., "You left N activities uncompleted yesterday." Scheduled activities will be returned in the timezone of the device at the time of the request. Once a task is finished, or expires (the time has passed for it to be started), or becomes invalid due to a schedule change on the server, it will be removed from the list of scheduled activities returned from Bridge, and (except for previously-fetched but unfinished tasks within daysBehind) will also be removed from the list passed to this method's completion handler.
  
 @deprecated For backward compatibility only. Use getScheduledActivitiesFrom:to:cachingPolicy:withCompletion: instead.

 @param daysAhead   A number of days in the future (0-4) for which to retrieve available/started/scheduled activities.
 @param daysBehind  A number of days in the past (no limit) for which to include previously-cached but expired and unfinished activities (ignored if the SDK was initialized with useCache=NO).
 @param policy      Caching policy to use (ignored if the SDK was initialized with useCache=NO).
 @param completion  An SBBActivityManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead daysBehind:(NSInteger)daysBehind cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion __attribute__((deprecated("use getScheduledActivitiesFrom:to:cachingPolicy:withCompletion: instead")));

/**
 This is a convenience method that assumes a default value of 1 for daysBehind.
 
 @deprecated For backward compatibility only. Use getScheduledActivitiesFrom:to:cachingPolicy:withCompletion: instead.
 */
- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion __attribute__((deprecated("use getScheduledActivitiesFrom:to:cachingPolicy:withCompletion: instead")));

/**
 This is a convenience method that assumes the default caching policy, which is SBBCachingPolicyFallBackToCached,
 if caching is enabled. Also implies a default value of 1 for daysBehind.

 @deprecated For backward compatibility only. Use getScheduledActivitiesFrom:to:withCompletion: instead.
*/
- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead withCompletion:(SBBActivityManagerGetCompletionBlock)completion __attribute__((deprecated("use getScheduledActivitiesFrom:to:withCompletion: instead")));

/*!
 Mark a ScheduledActivity as started, as of the time this method is called.
 
 This method notifies the server API that the activity was started, and calls the completion block upon success (or failure) of that notification.
 
 @param scheduledActivity   The ScheduledActivity to be marked as started.
 @param startDate           The date/time as of which the Task was started.
 @param completion          An SBBActivityManagerUpdateCompletionBlock to be called upon completion. Optional.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)startScheduledActivity:(SBBScheduledActivity *)scheduledActivity asOf:(NSDate *)startDate withCompletion:(nullable SBBActivityManagerUpdateCompletionBlock)completion;

/*!
 Mark a ScheduledActivity as finished, as of the time this method is called.
 
 Marking a ScheduledActivity as finished without first marking it as having been started tells the server to just delete the scheduled activity.
 
 This method notifies the server API that the scheduled activity was finished, and calls the completion block upon success (or failure) of that notification.
 
 @param scheduledActivity   The ScheduledActivity to be marked as started.
 @param finishDate          The date/time as of which the Task was finished.
 @param completion          An SBBActivityManagerUpdateCompletionBlock to be called upon completion. Optional.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)finishScheduledActivity:(SBBScheduledActivity *)scheduledActivity asOf:(NSDate *)finishDate withCompletion:(nullable SBBActivityManagerUpdateCompletionBlock)completion;

/*!
 Delete a ScheduledActivity from the list of available/started/scheduled activities.
 
 This method is equivalent to marking the scheduled activity as finished as of the time the method is called, which has the effect of removing it from the list of available/started/scheduled activities whether or not it had been previously marked as started, but does not actually delete it from the server if it had previously been marked as started. It is provided as a convenience method.
 
 This method notifies the server API to delete the scheduled activity, and calls the completion block upon success (or failure) of that notification.
 
 @param scheduledActivity   The ScheduledActivity to be deleted.
 @param completion          An SBBActivityManagerUpdateCompletionBlock to be called upon completion. Optional.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)deleteScheduledActivity:(SBBScheduledActivity *)scheduledActivity withCompletion:(nullable SBBActivityManagerUpdateCompletionBlock)completion;

/*!
 Add client-specific JSON-serializable data to a ScheduledActivity.
 
 This data will be stored on this ScheduledActivity object on the Bridge server, for later retrieval via the getScheduledActivitiesForGuid:scheduledFrom:to:withCompletion: method. This is intended to allow storing small amounts of data summarizing the result of performing the activity, e.g. a single computed "score" or the like, and not the full raw results.
 
 The data can be of any JSON-serializable iOS type: NSString, NSNumber, NSNull, or an NSArray or NSDictionary containing only values of a JSON-serializable iOS type or collection thereof (and the keys of the NSDictionary must be of type NSString).
 
 @param clientData          A (relatively small) JSON-serializable object to store in Bridge with the ScheduledActivity. To set to nil, pass [NSNull null].
 @param scheduledActivity   The ScheduledActivity to which the clientData will be attached.
 @param completion          An SBBActivityManagerGetCompletionBlock to be called upon completion. Optional.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)setClientData:(nonnull id<SBBJSONValue>)clientData forScheduledActivity:(SBBScheduledActivity *)scheduledActivity withCompletion:(nullable SBBActivityManagerUpdateCompletionBlock)completion;

/*!
 Update multiple scheduled activities' statuses with the API at one time.
 
 Only the startedOn, finishedOn, and clientData fields of ScheduledActivity are user-writable, so only changes to those fields will have any effect on the server state.
 
 @param scheduledActivities The list of ScheduledActivity objects whose statuses are to be updated to the API.
 @param completion An SBBActivityManagerUpdateCompletionBlock to be called upon completion. Optional.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)updateScheduledActivities:(NSArray *)scheduledActivities withCompletion:(nullable SBBActivityManagerUpdateCompletionBlock)completion;

@end

/*!
 This class handles communication with the Bridge Scheduled Activities API.
 */
@interface SBBActivityManager : SBBBridgeAPIManager<SBBComponent, SBBActivityManagerProtocol>

@end

NS_ASSUME_NONNULL_END
