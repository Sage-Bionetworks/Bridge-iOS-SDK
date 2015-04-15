//
//  SBBProfileManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
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
 Completion block called when retrieving user profile from the API.
 
 @param userProfile By default, an SBBUserProfile object, unless the UserProfile type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBProfileManagerGetCompletionBlock)(id userProfile, NSError *error);

/*!
 Completion block called when updating user profile to the API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBProfileManagerUpdateCompletionBlock)(id responseObject, NSError *error);

/*!
 *  This protocol defines the interface to the SBBProfileManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBProfileManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 *  Fetch the UserProfile from the Bridge API.
 *
 *  @param completion An SBBProfileManagerGetCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getUserProfileWithCompletion:(SBBProfileManagerGetCompletionBlock)completion;

/*!
 *  Update the UserProfile to the Bridge API.
 *
 *  @param profile A client object representing the UserProfile as it should be updated.
 *  @param completion An SBBProfileManagerGetCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)updateUserProfileWithProfile:(id)profile completion:(SBBProfileManagerUpdateCompletionBlock)completion;

/*!
 *  Add an external identifier for a participant.
 *
 *  For research studies designed to enroll participants who are tracked outside of the Bridge-specific study, you can build
 *  your application to submit a unique external identifier to the Bridge Server for that user. This can happen any time after
 *  an email address has been validated. The identifier will be exported with research data, but not with exports that provide
 *  the identifies of the people in the study (like the participant roster). The identifier should be unique for the user in
 *  this study, but this is not validated by the Bridge server. The identifier can be updated, but never deleted (if absolutely
 *  necessary, set it to a "deleted" value like "N/A")
 *
 *  @param externalID An external identifier to allow this participant to be tracked outside of the Bridge-specific study.
 *  @param completion An SBBProfileManagerUpdateCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)addExternalIdentifier:(NSString *)externalID completion:(SBBProfileManagerUpdateCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge profile API.
 */
@interface SBBProfileManager : SBBBridgeAPIManager<SBBComponent, SBBProfileManagerProtocol>

@end
