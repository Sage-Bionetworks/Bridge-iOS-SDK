//
//  SBBNotificationManager.m
//  BridgeSDK
//
//	Copyright (c) 2017, Sage Bionetworks
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

#import "SBBNotificationManagerInternal.h"
#import "SBBNotificationRegistration.h"
#import "SBBComponentManager.h"
#import "SBBObjectManager.h"
#import "BridgeSDK+Internal.h"
#import "SBBCacheManager.h"
#import "ModelObjectInternal.h"

#define NOTIFICATIONS_API V3_API_PREFIX @"/notifications"

NSString * const kSBBNotifiationsAPI        =   NOTIFICATIONS_API;
NSString * const kSBBNotifiationsGuidAPI    =   NOTIFICATIONS_API @"/%@";
NSString * const kSBBSubscriptionsAPI       =   NOTIFICATIONS_API @"/subscriptions";

NSString * const kSBBNotificationGuidKey        = @"guid";
NSString * const kSBBNotificationTopicGuidsKey  = @"topicGuids";
NSString * const kSBBNotificationTypeKey        = @"type";

@interface SBBNotificationManager()

@end

@implementation SBBNotificationManager

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (instancetype)defaultComponent
{
  static SBBNotificationManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (NSURLSessionTask *)updateRegistrationWithDeviceId:(NSString *)deviceId completion:(SBBNotificationManagerPostDeviceIdCompletionBlock)completion
{
    SBBNotificationRegistration* registration = [self getExistingNotificationRegistration];
    
    NSString* notificationsApi = kSBBNotifiationsAPI;
    // Update existing notification registration if one exists
    if (registration != nil && registration.guid != nil) {
        notificationsApi = [NSString stringWithFormat:kSBBNotifiationsGuidAPI, registration.guid];
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *params = @{ @"deviceId": deviceId };
    return [self.networkManager post:notificationsApi headers:headers parameters:params completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error == nil && responseObject != nil) {
            [self cacheNotificationRegistration:responseObject];
        }
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)deleteNotificationRegistrationWithCompletion:(SBBNotificationManagerPostDeviceIdCompletionBlock)completion
{
    SBBNotificationRegistration* registration = [self getExistingNotificationRegistration];
    
    // Delete existing notification registration if one exists
    if (registration != nil && registration.guid != nil) {
        NSString* notificationsApi = [NSString stringWithFormat:kSBBNotifiationsGuidAPI, registration.guid];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [self.authManager addAuthHeaderToHeaders:headers];
        NSDictionary *params = @{ @"deviceId": registration.deviceId };
        return [self.networkManager delete:notificationsApi headers:headers parameters:params completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (error == nil) {
                [self clearNotificationInfoFromCache];
            }
            if (completion) {
                completion(responseObject, error);
            }
        }];
    }
    
    NSLog(@"We have no way to delete this device ID since we do not have a registration cached");
    return nil;
}

- (void) cacheNotificationRegistration:(SBBNotificationRegistration*)registration {
    [self.cacheManager.cacheIOContext performBlock:^{
        [registration saveToCoreDataCacheWithObjectManager:self.objectManager];
    }];
}

- (SBBNotificationRegistration*) getExistingNotificationRegistration {
    // Check for existing notification registration
    NSString *registrationType = [SBBNotificationRegistration entityName];
    SBBBridgeObject* registrationObj = [self.cacheManager cachedSingletonObjectOfType:registrationType createIfMissing:NO];
    if (registrationObj != nil && [registrationObj isKindOfClass:[SBBNotificationRegistration class]]) {
        return (SBBNotificationRegistration*)registrationObj;
    }
    return nil;
}

- (void)clearNotificationInfoFromCache
{
    NSString *registrationType = [SBBNotificationRegistration entityName];
    
    // remove them from cache. note: we use the Bridge type (which is the same as the CoreData entity name) as the unique key
    // to treat a class as a singleton for caching purposes.
    [self.cacheManager removeFromCacheObjectOfType:registrationType withId:registrationType];
}

#pragma clang diagnostic pop

@end
