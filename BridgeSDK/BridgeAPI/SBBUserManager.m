//
//  SBBUserManager.m
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

#import "SBBUserManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "BridgeSDKInternal.h"
#import "NSDate+SBBAdditions.h"

#define USER_API GLOBAL_API_PREFIX @"/users/self"

NSString * const kSBBUserProfileAPI =       USER_API;
NSString * const kSBBUserExternalIdAPI =    USER_API @"/externalId";
NSString * const kSBBUserDataSharingAPI =   USER_API @"/dataSharing";
NSString * const kSBBUserDataEmailDataAPI = USER_API @"/emailData";

NSString * const kSBBUserDataSharingScopeKey = @"scope";
NSString* const kSBBUserDataSharingScopeStrings[] = {
    @"no_sharing",
    @"sponsors_and_partners",
    @"all_qualified_researchers"
};

@implementation SBBUserManager

+ (instancetype)defaultComponent
{
  static SBBUserManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (NSURLSessionDataTask *)getUserProfileWithCompletion:(SBBUserManagerGetCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager get:kSBBUserProfileAPI headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id userProfile = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(userProfile, error);
    }
  }];
}

- (NSURLSessionDataTask *)updateUserProfileWithProfile:(id)profile completion:(SBBUserManagerCompletionBlock)completion
{
  id jsonProfile = [self.objectManager bridgeJSONFromObject:profile];
  if (!jsonProfile) {
    NSLog(@"Unable to create Bridge JSON UserProfile object from %@", profile);
    return nil;
  }
  
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager post:kSBBUserProfileAPI headers:headers parameters:jsonProfile completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)addExternalIdentifier:(NSString *)externalID completion:(SBBUserManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *params = @{
                                @"identifier": externalID,
                                @"type": @"ExternalIdentifier"
                             };
    return [self.networkManager post:kSBBUserExternalIdAPI headers:headers parameters:params completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionDataTask *)emailDataToUserFrom:(NSDate *)startDate to:(NSDate *)endDate completion:(SBBUserManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSString *startDateString = [startDate ISO8601DateOnlyString];
    NSString *endDateString = [endDate ISO8601DateOnlyString];
    NSDictionary *params = @{
                             @"startDate": startDateString,
                             @"endDate": endDateString,
                             @"type": @"DateRange"
                             };
    return [self.networkManager post:kSBBUserDataEmailDataAPI headers:headers parameters:params completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionDataTask *)dataSharing:(SBBUserDataSharingScope)scope completion:(SBBUserManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *parameters = @{kSBBUserDataSharingScopeKey: kSBBUserDataSharingScopeStrings[scope]};
    return [self.networkManager post:kSBBUserDataSharingAPI headers:headers parameters:parameters completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

@end
