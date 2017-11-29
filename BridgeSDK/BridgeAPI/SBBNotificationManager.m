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
#import "SBBGuidHolder.h"
#import "SBBComponentManager.h"
#import "SBBObjectManager.h"
#import "BridgeSDK+Internal.h"
#import "SBBCacheManager.h"
#import "ModelObjectInternal.h"

#define NOTIFICATIONS_API V3_API_PREFIX @"/notifications"

NSString * const kSBBNotifiationsAPI        =   NOTIFICATIONS_API;
NSString * const kSBBNotifiationsGuidAPI    =   NOTIFICATIONS_API @"/%@";
NSString * const kSBBSubscriptionsAPI       =   NOTIFICATIONS_API @"/%@/subscriptions";

NSString * const kSBBNotificationGuidKey        = @"guid";
NSString * const kSBBNotificationTopicGuidsKey  = @"topicGuids";
NSString * const kSBBNotificationTypeKey        = @"type";
NSString * const kSBBNotificationDeviceIdKey    = @"deviceId";
NSString * const kSBBNotificationOsNameKey      = @"osName";
NSString * const kSBBNotificationOsNameValue    = @"iOS";

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
    SBBGuidHolder* registration = [self getExistingNotificationRegistration];
    
    NSString* notificationsApi = kSBBNotifiationsAPI;
    // Update existing notification registration if one exists
    if (registration != nil && registration.guid != nil) {
        notificationsApi = [NSString stringWithFormat:kSBBNotifiationsGuidAPI, registration.guid];
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *params = @{
                             kSBBNotificationDeviceIdKey: deviceId,
                             kSBBNotificationOsNameKey: kSBBNotificationOsNameValue
                             };
    return [self.networkManager post:notificationsApi headers:headers parameters:params completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        SBBGuidHolder* guidHolder = nil;
        if (error == nil && responseObject != nil) {
            guidHolder = [self toCachedObjectFromBridgeJson:responseObject andDeviceId:deviceId];
        }
        if (completion) {
            completion(guidHolder, error);
        }
    }];
}

- (NSURLSessionTask *)updateRegistrationWithDeviceId:(NSString *)deviceId subscribeToTopicGuids:(NSArray *)topicGuids completion:(SBBNotificationManagerPostDeviceIdCompletionBlock)completion
{
    return [self updateRegistrationWithDeviceId:deviceId completion:^(SBBGuidHolder* guidHolder, NSError *error) {
        if (error == nil && guidHolder != nil) {
            [self subscribeToTopicGuids:topicGuids withRegistration:guidHolder completion:^(id bridgeResponse, NSError *error) {
                if (completion) {
                    completion(guidHolder, error);
                }
            }];
        } else {
            if (completion) {
                completion(guidHolder, error);
            }
        }
    }];
}

- (NSURLSessionTask *)subscribeToTopicGuids:(NSArray *)topicGuids withRegistration: (SBBGuidHolder*)guidHolder completion:(SBBNotificationManagerCompletionBlock)completion
{
    // Subscribe to topics if registration guid exists
    if (guidHolder != nil && guidHolder.guid != nil) {
        NSString* notificationsApi = [NSString stringWithFormat:kSBBSubscriptionsAPI, guidHolder.guid];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [self.authManager addAuthHeaderToHeaders:headers];
        NSDictionary *params = @{ kSBBNotificationTopicGuidsKey: topicGuids };
        return [self.networkManager post:notificationsApi headers:headers parameters:params completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (completion) {
                completion(responseObject, error);
            }
        }];
    } else {
        NSLog(@"We have no way to delete this device ID since we do not have a registration cached");
        return nil;
    }
}

- (NSURLSessionTask *)deleteNotificationRegistrationWithCompletion:(SBBNotificationManagerCompletionBlock)completion
{
    SBBGuidHolder* registration = [self getExistingNotificationRegistration];
    
    // Delete existing notification registration if one exists
    if (registration != nil && registration.guid != nil) {
        NSString* notificationsApi = [NSString stringWithFormat:kSBBNotifiationsGuidAPI, registration.guid];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [self.authManager addAuthHeaderToHeaders:headers];
        NSDictionary *params = @{ @"deviceId": registration.deviceId };
        return [self.networkManager delete:notificationsApi headers:headers parameters:params completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (error == nil) {
                [self clearNotificationInfoFromCache];
                NSLog(@"Successfully unregistered device for push notifications");
            } else {
                NSLog(@"Failed to unregister device for push notifications");
            }
            if (completion) {
                completion(responseObject, error);
            }
        }];
    } else {
        NSLog(@"We have no way to unregister device for push notifications since we do not have a registration cached");
        return nil;
    }
}

- (SBBGuidHolder*) toCachedObjectFromBridgeJson:(id)bridgeDictionary andDeviceId:(NSString*)deviceId {
    if (![bridgeDictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Error: notification registartion bridge response MUST be a dictionary");
        return nil;
    }
    NSMutableDictionary* bridgeResponse = [((NSDictionary*)bridgeDictionary) mutableCopy];
    bridgeResponse[@"deviceId"] = deviceId;
    SBBGuidHolder* guidHolder = (SBBGuidHolder*)[self.cacheManager cachedObjectFromBridgeJSON:bridgeResponse];
    return guidHolder;
}

- (SBBGuidHolder*) getExistingNotificationRegistration {
    SBBBridgeObject* bridgeObject = [self.cacheManager cachedSingletonObjectOfType:[SBBGuidHolder entityName] createIfMissing:NO];
    if (bridgeObject != nil && [bridgeObject isKindOfClass:[SBBGuidHolder class]]) {
        return (SBBGuidHolder*)bridgeObject;
    }
    return nil;
}

- (void)clearNotificationInfoFromCache
{
    NSString *registrationType = [SBBGuidHolder entityName];
    
    // remove them from cache. note: we use the Bridge type (which is the same as the CoreData entity name) as the unique key
    // to treat a class as a singleton for caching purposes.
    [self.cacheManager.cacheIOContext performBlock:^{
        [self.cacheManager removeFromCacheObjectOfType:registrationType withId:registrationType];
    }];
}

#pragma clang diagnostic pop

@end
