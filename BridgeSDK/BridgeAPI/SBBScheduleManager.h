//
//  SBBScheduleManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/24/14.
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

/*!
 Completion block called when retrieving user schedules from the API.
 
 @param schedulesList By default, an SBBResourceList object, unless the ResourceList type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:. The item property (or whatever it was mapped to) contains an NSArray of SBBSchedule objects and the total (or mapped-to) property contains an NSNumber indicating how many Schedules were retrieved--again, unless the Schedule type has been mapped to a different class.
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBScheduleManagerGetCompletionBlock)(id schedulesList, NSError *error);

/*!
 This protocol defines the interface to the SBBScheduleManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBScheduleManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Fetch the list of Schedules for the user from the Bridge API.
 
 @param completion An SBBScheduleManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSchedulesWithCompletion:(SBBScheduleManagerGetCompletionBlock)completion;

@end


/*!
 This class handles communication with the Bridge Schedule API.
 */
@interface SBBScheduleManager : SBBBridgeAPIManager<SBBComponent, SBBScheduleManagerProtocol>

@end
