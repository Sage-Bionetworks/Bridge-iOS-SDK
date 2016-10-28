//
//  SBBSurveyManager.m
//  BridgeSDK
//
//	Copyright (c) 2014-2016, Sage Bionetworks
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

#import "SBBSurveyManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "NSDate+SBBAdditions.h"
#import "BridgeSDKInternal.h"

#define SURVEY_API_FORMAT GLOBAL_API_PREFIX @"/surveys/%@/revisions/%@"

NSString * const kSBBSurveyAPIFormat =                          SURVEY_API_FORMAT;

@implementation SBBSurveyManager

+ (instancetype)defaultComponent
{
    static SBBSurveyManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSURLSessionTask *)getSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerGetCompletionBlock)completion
{
    return [self getSurveyByRef:ref cachingPolicy:SBBCachingPolicyCheckCacheFirst completion:completion];
}

- (NSURLSessionTask *)getSurveyByRef:(NSString *)ref cachingPolicy:(SBBCachingPolicy)policy completion:(SBBSurveyManagerGetCompletionBlock)completion
{
    // if we're going straight to cache, just get it and get out
    if (policy == SBBCachingPolicyCachedOnly) {
        SBBSurvey *survey = [self.cacheManager cachedObjectOfType:@"Survey" withId:@"ScheduledActivity" createIfMissing:NO]];
        
        if (completion) {
            NSMutableArray *requestedTasks = [[self filterTasks:tasks.items forDaysAhead:daysAhead andDaysBehind:daysBehind excludeStillValid:NO] mutableCopy];
            [self mapSubObjectsInTaskList:requestedTasks];
            completion(requestedTasks, nil);
        }
        
        return nil;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager get:ref headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        id survey = [self.objectManager objectFromBridgeJSON:responseObject];
        if (completion) {
            completion(survey, error);
        }
    }];
}

- (NSURLSessionTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerGetCompletionBlock)completion
{
}

- (NSURLSessionTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn cachingPolicy:(SBBCachingPolicy)policy completion:(SBBSurveyManagerGetCompletionBlock)completion
{
    NSString *version = [createdOn ISO8601StringUTC];
    NSString *ref = [NSString stringWithFormat:kSBBSurveyAPIFormat, guid, version];
    return [self getSurveyByRef:ref cachingPolicy:policy completion:completion];
}

@end
