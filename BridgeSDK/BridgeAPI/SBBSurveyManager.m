//
//  SBBSurveyManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
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

#import "SBBSurveyManager.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "NSDate+SBBAdditions.h"

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

- (NSURLSessionDataTask *)getSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerGetCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager get:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id survey = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(survey, error);
    }
  }];
}

- (NSURLSessionDataTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerGetCompletionBlock)completion
{
  NSString *version = [createdOn ISO8601StringUTC];
  NSString *ref = [NSString stringWithFormat:@"/api/v2/surveys/%@/revisions/%@", guid, version];
  return [self getSurveyByRef:ref completion:completion];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurvey:(SBBSurvey *)survey completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
    return [self submitAnswers:surveyAnswers toSurvey:survey withResponseIdentifier:nil completion:completion];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurvey:(SBBSurvey *)survey withResponseIdentifier:(NSString *)identifier completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
    return [self submitAnswers:surveyAnswers toSurveyByGuid:survey.guid createdOn:survey.createdOn withResponseIdentifier:identifier completion:completion];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
    return [self submitAnswers:surveyAnswers toSurveyByRef:ref withResponseIdentifier:nil completion:completion];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByRef:(NSString *)ref withResponseIdentifier:(NSString *)identifier completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSString *refWithResponseIdentifier = ref;
    if (identifier.length) {
        refWithResponseIdentifier = [NSString stringWithFormat:@"%@/%@", ref, identifier];
    }
    id jsonAnswers = [self.objectManager bridgeJSONFromObject:surveyAnswers];
    return [self.networkManager post:refWithResponseIdentifier headers:headers parameters:jsonAnswers completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        id identifierHolder = [self.objectManager objectFromBridgeJSON:responseObject];
        if (completion) {
            completion(identifierHolder, error);
        }
    }];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
    return [self submitAnswers:surveyAnswers toSurveyByGuid:guid createdOn:createdOn withResponseIdentifier:nil completion:completion];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByGuid:(NSString *)surveyGuid createdOn:(NSDate *)createdOn withResponseIdentifier:(NSString *)responseIdentifier completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
    NSString *version = [createdOn ISO8601StringUTC];
    NSString *ref = [NSString stringWithFormat:@"/api/v2/surveys/%@/revisions/%@", surveyGuid, version];
    return [self submitAnswers:surveyAnswers toSurveyByRef:ref withResponseIdentifier:responseIdentifier completion:completion];
}

- (NSURLSessionDataTask *)getSurveyResponse:(NSString *)identifier completion:(SBBSurveyManagerGetResponseCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  NSString *ref = [NSString stringWithFormat:@"/api/v2/surveyresponses/%@", identifier];
  return [self.networkManager get:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id surveyResponse = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(surveyResponse, error);
    }
  }];
}

- (NSURLSessionDataTask *)addAnswers:(NSArray *)surveyAnswers toSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  id jsonAnswers = [self.objectManager bridgeJSONFromObject:surveyAnswers];
  NSString *ref = [NSString stringWithFormat:@"/api/v2/surveyresponses/%@", guid];
  return [self.networkManager post:ref headers:headers parameters:jsonAnswers completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)deleteSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  NSString *ref = [NSString stringWithFormat:@"/api/v2/surveyresponses/%@", guid];
  return [self.networkManager delete:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

@end
