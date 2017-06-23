//
//  SBBUserManager.m
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

#import "SBBUserManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "BridgeSDK+Internal.h"
#import "NSDate+SBBAdditions.h"
#import "SBBDataGroups.h"
#import "SBBCacheManager.h"
#import "SBBActivityManagerInternal.h"
#import "SBBUserProfile.h"
#import "SBBDataGroups.h"
#import "ModelObjectInternal.h"

#define USER_API V3_API_PREFIX @"/users/self"

NSString * const kSBBUserProfileAPI =       USER_API;
NSString * const kSBBUserExternalIdAPI =    USER_API @"/externalId";
NSString * const kSBBUserDataSharingAPI =   USER_API @"/dataSharing";
NSString * const kSBBUserDataEmailDataAPI = USER_API @"/emailData";
NSString * const kSBBUserDataGroupsAPI =    USER_API @"/dataGroups";

NSString * const kSBBUserDataSharingScopeKey = @"scope";
NSString* const kSBBUserDataSharingScopeStrings[] = {
    @"no_sharing",
    @"sponsors_and_partners",
    @"all_qualified_researchers"
};

@interface SBBUserManager()<SBBUserManagerInternalProtocol>

@end

@implementation SBBUserManager

@synthesize activityManager = _activityManager;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (instancetype)defaultComponent
{
  static SBBUserManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (id<SBBActivityManagerInternalProtocol>)activityManager
{
    if (!_activityManager) {
        _activityManager = (id<SBBActivityManagerInternalProtocol>)SBBComponent(SBBActivityManager);
    }
    
    return _activityManager;
}

- (NSURLSessionTask *)getUserProfileWithCompletion:(SBBUserManagerGetProfileCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager get:kSBBUserProfileAPI headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
    id userProfile = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(userProfile, error);
    }
  }];
}

- (NSURLSessionTask *)updateUserProfileWithProfile:(id)profile completion:(SBBUserManagerCompletionBlock)completion
{
  id jsonProfile = [self.objectManager bridgeJSONFromObject:profile];
  if (!jsonProfile) {
    NSLog(@"Unable to create Bridge JSON UserProfile object from %@", profile);
    return nil;
  }
  
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager post:kSBBUserProfileAPI headers:headers parameters:jsonProfile completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionTask *)addExternalIdentifier:(NSString *)externalID completion:(SBBUserManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *params = @{
                                @"identifier": externalID,
                                @"type": @"ExternalIdentifier"
                             };
    return [self.networkManager post:kSBBUserExternalIdAPI headers:headers parameters:params completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)emailDataToUserFrom:(NSDate *)startDate to:(NSDate *)endDate completion:(SBBUserManagerCompletionBlock)completion
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
    return [self.networkManager post:kSBBUserDataEmailDataAPI headers:headers parameters:params completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)dataSharing:(SBBUserDataSharingScope)scope completion:(SBBUserManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *parameters = @{kSBBUserDataSharingScopeKey: kSBBUserDataSharingScopeStrings[scope]};
    return [self.networkManager post:kSBBUserDataSharingAPI headers:headers parameters:parameters completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)getDataGroupsWithCompletion:(SBBUserManagerGetGroupsCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager get:kSBBUserDataGroupsAPI headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        id dataGroups = [self.objectManager objectFromBridgeJSON:responseObject];
        if (completion) {
            completion(dataGroups, error);
        }
    }];
}

- (NSURLSessionTask *)updateDataGroupsWithGroups:(id)dataGroups completion:(SBBUserManagerCompletionBlock)completion
{
    id jsonGroups = [self.objectManager bridgeJSONFromObject:dataGroups];
    if (!jsonGroups) {
        NSLog(@"Unable to create Bridge JSON DataGroups object from %@", dataGroups);
        return nil;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager post:kSBBUserDataGroupsAPI headers:headers parameters:jsonGroups completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (!error) {
            // updating data groups generally invalidates your schedule so we need to flush the cache
            if ([self.activityManager conformsToProtocol:@protocol(SBBActivityManagerInternalProtocol)]) {
                [self.activityManager flushUncompletedActivities];
            }
        }
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (void)addToDataGroups:(NSArray<NSString *> *)dataGroups completion:(SBBUserManagerCompletionBlock)completion
{
    [self getDataGroupsWithCompletion:^(id oldDataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving current data groups from Bridge:\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            SBBDataGroups *newDataGroups = oldDataGroups;
            if (![newDataGroups isKindOfClass:[SBBDataGroups class]]) {
                // use a clean object manager with no mappings to retrieve the SBBDataGroups object from the
                // returned object, if it's been mapped
                newDataGroups = [[SBBObjectManager objectManager] objectFromBridgeJSON:[self.objectManager bridgeJSONFromObject:dataGroups]];
            }
            
            newDataGroups.dataGroups = [newDataGroups.dataGroups setByAddingObjectsFromArray:dataGroups];
            [self updateDataGroupsWithGroups:newDataGroups completion:completion];
        }
    }];
}

- (void)removeFromDataGroups:(NSArray<NSString *> *)dataGroups completion:(SBBUserManagerCompletionBlock)completion
{
    [self getDataGroupsWithCompletion:^(id oldDataGroups, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving current data groups from Bridge:\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            SBBDataGroups *newDataGroups = oldDataGroups;
            if (![newDataGroups isKindOfClass:[SBBDataGroups class]]) {
                // use a clean object manager with no mappings to retrieve the SBBDataGroups object from the
                // returned object, if it's been mapped
                newDataGroups = [[SBBObjectManager objectManager] objectFromBridgeJSON:[self.objectManager bridgeJSONFromObject:dataGroups]];
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return ![dataGroups containsObject:evaluatedObject];
            }];
            newDataGroups.dataGroups = [newDataGroups.dataGroups filteredSetUsingPredicate:predicate];
            [self updateDataGroupsWithGroups:newDataGroups completion:completion];
        }
    }];
}

- (void)clearUserInfoFromCache
{
    NSString *profileType = [SBBUserProfile entityName];
    NSString *dataGroupsType = [SBBDataGroups entityName];
    
    // remove them from cache. note: we use the Bridge type (which is the same as the CoreData entity name) as the unique key
    // to treat a class as a singleton for caching purposes.
    [self.cacheManager removeFromCacheObjectOfType:profileType withId:profileType];
    [self.cacheManager removeFromCacheObjectOfType:dataGroupsType withId:dataGroupsType];
}

#pragma clang diagnostic pop

@end
