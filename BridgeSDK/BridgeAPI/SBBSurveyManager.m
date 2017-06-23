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
#import "SBBObjectManagerInternal.h"
#import "NSDate+SBBAdditions.h"
#import "BridgeSDK+Internal.h"
#import "ModelObjectInternal.h"
#import "SBBErrors.h"

#define SURVEY_API_FORMAT V3_API_PREFIX @"/surveys/%@/revisions/%@"

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
    // parse the guid and createdOn out of the ref string
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.*/surveys/([^/]*)/revisions/(.*)$" options:0 error:&error];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:ref options:0 range:NSMakeRange(0, ref.length)];
    // match[0].range is the range of the entire regex match, the capture ones are index 1 and 2
    if (matches.count != 1 || matches[0].numberOfRanges != 3) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeNotAValidSurveyRef userInfo:@{@"ref": ref}]);
        }
        return nil;
    }
    
    NSTextCheckingResult *match = matches[0];
    NSString *guid = [ref substringWithRange:[match rangeAtIndex:1]];
    NSString *createdOnString = [ref substringWithRange:[match rangeAtIndex:2]];
    return [self getSurveyWithGuid:guid createdOnString:createdOnString ref:ref cachingPolicy:policy completion:completion];

}

- (NSURLSessionTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerGetCompletionBlock)completion
{
    return [self getSurveyByGuid:guid createdOn:createdOn cachingPolicy:SBBCachingPolicyCheckCacheFirst completion:completion];
}

- (NSURLSessionTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn cachingPolicy:(SBBCachingPolicy)policy completion:(SBBSurveyManagerGetCompletionBlock)completion
{
    // build a ref string from guid and createdOn
    NSString *revision = [createdOn ISO8601StringUTC];
    NSString *ref = [NSString stringWithFormat:kSBBSurveyAPIFormat, guid, revision];
    return [self getSurveyWithGuid:guid createdOnString:revision ref:ref cachingPolicy:policy completion:completion];
}

// internal methods
- (SBBSurvey *)fetchSurveyFromCacheWithGuid:(NSString *)guid createdOnString:(NSString *)createdOnString
{
    NSString *surveyId = [guid stringByAppendingString:createdOnString];
    SBBSurvey *survey = (SBBSurvey *)[self.cacheManager cachedObjectOfType:[SBBSurvey entityName] withId:surveyId createIfMissing:NO];
    return survey;
}

- (NSURLSessionTask *)getSurveyWithGuid:(NSString *)guid createdOnString:(NSString *)createdOnString ref:(NSString *)ref cachingPolicy:(SBBCachingPolicy)policy completion:(SBBSurveyManagerGetCompletionBlock)completion
{
    SBBSurvey *cachedSurvey = nil;
    if (gSBBUseCache) {
        // fetch from cache
        cachedSurvey = [self fetchSurveyFromCacheWithGuid:guid createdOnString:createdOnString];
        
        // if we're going straight to cache, just pass it along and get out
        // if we're checking the cache first, and it's there, also just pass it along and get out
        if (policy == SBBCachingPolicyCachedOnly ||
            (policy == SBBCachingPolicyCheckCacheFirst && cachedSurvey != nil)) {
            if (completion) {
                id survey = [(id<SBBObjectManagerInternalProtocol>)self.objectManager mappedObjectForBridgeObject:cachedSurvey];
                completion(survey, nil);
            }
            
            return nil;
        }
    }
    
    // now try the server
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager get:ref headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        id survey = [self.objectManager objectFromBridgeJSON:responseObject];
        
        // if we're falling back to cache and we didn't get it back, pass along the previously cached version
        if (!survey) {
            survey = cachedSurvey;
        }
        
        if (completion) {
            completion(survey, error);
        }
    }];
}

@end
