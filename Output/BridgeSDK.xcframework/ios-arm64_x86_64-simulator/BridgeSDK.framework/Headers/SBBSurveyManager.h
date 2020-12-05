//
//  SBBSurveyManager.h
//  BridgeSDK
//
//	Copyright (c) 2014-2015, Sage Bionetworks
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
#import "SBBSurvey.h"

/*!
 Completion block called when retrieving a survey from the API.
 
 @param survey By default, an SBBSurvey object, unless the Survey type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerGetCompletionBlock)(id survey, NSError *error);

/*!
 Completion block called when submitting answers to a survey to the API.
 
 @param identifierHolder By default, an SBBIdentifierHolder object, unless the IdentifierHolder type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:. The identifier in question is the identifier of the SurveyResponse object created by submitting this set of answers, which can be used to later amend or delete the answers to this instance of taking the survey.
 @param error            An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerSubmitAnswersCompletionBlock)(id identifierHolder, NSError *error);

/*!
 Completion block called when retrieving a survey response from the API.
 
 @param surveyResponse By default, an SBBSurveyResponse object, unless the SurveyResponse type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerGetResponseCompletionBlock)(id surveyResponse, NSError *error);

/*!
 Completion block called when updating or deleting a survey response to the API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerEditResponseCompletionBlock)(id responseObject, NSError *error);

/*!
 *  This protocol defines the interface to the SBBSurveyManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBSurveyManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Fetch a survey from the Bridge API via an activityRef (href).
 
 @param ref        The href identifying the desired survey, obtained e.g. from the Schedules or Activities API.
 @param policy     Caching policy to use (ignored if the SDK was initialized with useCache=NO).
 @param completion An SBBSurveyManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)getSurveyByRef:(NSString *)ref cachingPolicy:(SBBCachingPolicy)policy completion:(SBBSurveyManagerGetCompletionBlock)completion;

/**
 This is a convenience method that assumes the default caching policy, which is SBBCachingPolicyCheckCacheFirst,
 if caching is enabled.
 */
- (NSURLSessionTask *)getSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerGetCompletionBlock)completion;

/*!
 Fetch a survey from the Bridge API by guid and version number.
 
 @param guid       The survey's guid.
 @param createdOn  The creation date and time of the version of the survey to fetch.
 @param policy     Caching policy to use (ignored if the SDK was initialized with useCache=NO).
 @param completion An SBBSurveyManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn cachingPolicy:(SBBCachingPolicy)policy completion:(SBBSurveyManagerGetCompletionBlock)completion;

/**
 This is a convenience method that assumes the default caching policy, which is SBBCachingPolicyCheckCacheFirst,
 if caching is enabled.
 */
- (NSURLSessionTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerGetCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge surveys API.
 */
@interface SBBSurveyManager : SBBBridgeAPIManager<SBBComponent, SBBSurveyManagerProtocol>

@end
