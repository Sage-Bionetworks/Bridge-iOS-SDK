//
//  SBBTaskManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 5/5/15.
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
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"
#import "SBBTask.h"

/*!
 Completion block called when retrieving user tasks from the API.
 
 @param tasksList By default, an SBBResourceList object, unless the ResourceList type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:. The item property (or whatever it was mapped to) contains an NSArray of SBBTask objects and the total (or mapped-to) property contains an NSNumber indicating how many Tasks were retrieved--again, unless the Task type has been mapped to a different class.
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBTaskManagerGetCompletionBlock)(id tasksList, NSError *error);

/*!
 Completion block called when updating a Task's status to the API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBTaskManagerUpdateCompletionBlock)(id responseObject, NSError *error);

/*!
 This protocol defines the interface to the SBBTaskManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBTaskManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Get all available, started, or scheduled tasks for a user. The "until" parameter allows you to retrieve tasks that are scheduled in the future up to the date/time supplied (to a maximum of four days, at this time). This allows certain kinds of UIs (e.g. "You have N tasks tomorrow" or "You have compiled N of X tasks today", even when the tasks are not yet to be performed). Once a task is finished, or expires (the time has passed for it to be started), it will be removed from the list of tasks returned to the user.
 
 @param until      A date/time (usually in the near future) up to which to retrieve available/started/scheduled tasks.
 @param completion An SBBTaskManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getTasksUntil:(NSDate *)until withCompletion:(SBBTaskManagerGetCompletionBlock)completion;

/*!
 Mark a Task as started, as of the time this method is called.
 
 This method notifies the server API that the task was started, and calls the completion block upon success (or failure) of that notification.
 
 @param task       The Task to be marked as started.
 @param startDate  The date/time as of which the Task was started.
 @param completion An SBBTaskManagerUpdateCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)startTask:(SBBTask *)task asOf:(NSDate *)startDate withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion;

/*!
 Mark a Task as finished, as of the time this method is called.
 
 Marking a Task as finished without first marking it as having been started has tells the server to just delete the task.
 
 This method notifies the server API that the task was finished, and calls the completion block upon success (or failure) of that notification.
 
 @param task       The Task to be marked as started.
 @param finishDate The date/time as of which the Task was finished.
 @param completion An SBBTaskManagerUpdateCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)finishTask:(SBBTask *)task asOf:(NSDate *)finishDate withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion;

/*!
 Delete a Task from the list of available/started/scheduled tasks.
 
 This method is equivalent to marking the task as finished as of the time the method is called, which has the effect of removing it from the list of available/started/scheduled tasks whether or not it had been previously marked as started, but does not actually delete it from the server if it had previously been marked as started. It is provided as a convenience method.
 
 This method notifies the server API to delete the task, and calls the completion block upon success (or failure) of that notification.
 
 @param task       The Task to be deleted.
 @param completion An SBBTaskManagerUpdateCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)deleteTask:(SBBTask *)task withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion;

/*!
 Update multiple tasks' statuses with the API at one time.
 
 Only the startedOn and finishedOn fields of Tasks are user-writable, so only changes to those fields will have any effect on the server state.
 
 @param tasks      The list of Tasks whose statuses are to be updated to the API.
 @param completion An SBBTaskManagerUpdateCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)updateTasks:(NSArray *)tasks withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion;

@end

/*!
 This class handles communication with the Bridge Task API.
 */
@interface SBBTaskManager : SBBBridgeAPIManager<SBBComponent, SBBTaskManagerProtocol>

@end
