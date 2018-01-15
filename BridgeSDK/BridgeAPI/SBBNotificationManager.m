//
//  SBBNotificationManager.m
//  BridgeSDK
//
//    Copyright (c) 2017, Sage Bionetworks
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//        * Redistributions of source code must retain the above copyright
//          notice, this list of conditions and the following disclaimer.
//        * Redistributions in binary form must reproduce the above copyright
//          notice, this list of conditions and the following disclaimer in the
//          documentation and/or other materials provided with the distribution.
//        * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//          contributors may be used to endorse or promote products derived from
//          this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

#import "SBBNotificationManager.h"
#import "SBBBridgeAPIManagerInternal.h"
#import "SBBAuthManagerInternal.h"
#import "ModelObjectInternal.h"
#import "SBBNotificationRegistration.h"

#define NOTIFICATIONS_API V3_API_PREFIX @"/notifications"
#define NOTIFICATIONS_GUID_API NOTIFICATIONS_API @"/%@"

static NSString *kSBBNotificationsAPI = NOTIFICATIONS_API;
static NSString *kSBBNotificationsGuidAPIFormat = NOTIFICATIONS_GUID_API;
static NSString *kSBBSubscriptionsAPIFormat = NOTIFICATIONS_GUID_API @"/subscriptions";

static NSString *kSBBNotificationsOSName = @"iOS";
static NSString *kSBBNotificationTopicGuidsKey = @"topicGuids";
static NSString *kSBBSubscriptionRequest = @"SubscriptionRequest";

@interface SBBNotificationManager()

@property (nonatomic, strong) NSString *registrationGuid;

@end

@implementation SBBNotificationManager

+ (instancetype)defaultComponent
{
    static SBBNotificationManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSString *)registrationGuid
{
    if (!_registrationGuid && gSBBUseCache) {
        SBBNotificationRegistration *reg = (SBBNotificationRegistration *)[self.cacheManager cachedSingletonObjectOfType:[SBBNotificationRegistration entityName] createIfMissing:NO];
        _registrationGuid = reg.guid;
    }
    
    return _registrationGuid;
}

- (NSString *)deviceIdFromDeviceToken:(NSData *)deviceToken
{
    // see https://stackoverflow.com/a/20914740
    NSString *tokenString = [[[deviceToken description]
                              stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                              stringByReplacingOccurrencesOfString:@" " withString:@""];
    return tokenString;
}

- (NSURLSessionTask *)registerWithDeviceToken:(NSData *)deviceToken completion:(SBBNotificationManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    NSString *guid = self.registrationGuid;
    NSString *endpoint;
    NSString *deviceId = [self deviceIdFromDeviceToken:deviceToken];
    NSMutableDictionary *params = [@{
                                     NSStringFromSelector(@selector(osName)): kSBBNotificationsOSName,
                                     NSStringFromSelector(@selector(deviceId)): deviceId
                                          } mutableCopy];
    if (guid.length) {
        // the account is already registered with Bridge for push notifications so use the update endpoint
        endpoint = [NSString stringWithFormat:kSBBNotificationsGuidAPIFormat, guid];
        params[NSStringFromSelector(@selector(guid))] = guid;
    } else {
        // the account is not yet registered with Bridge for push notifications so use the create endpoint
        endpoint = kSBBNotificationsAPI;
    }
    
    return [self.networkManager post:endpoint headers:headers parameters:params background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
#if DEBUG
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Register for push notifications HTTP response code: %ld", (long)httpResponse.statusCode);
#endif
        id registration = nil;
        if (!error) {
            registration = [self.objectManager objectFromBridgeJSON:responseObject];
            _registrationGuid = ((NSDictionary *)responseObject)[NSStringFromSelector(@selector(guid))];
        }
        
        if (completion) {
            completion(registration, responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)unregisterWithCompletion:(SBBNotificationManagerCompletionBlock)completion
{
    NSString *guid = self.registrationGuid;
    if (!guid.length) {
        // the account is not registered with Bridge for push notifications so do nothing
        if (completion) {
            completion(nil, nil, [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeNotRegisteredForPushNotifications userInfo:nil]);
        }
        return nil;
    }
    
    // remove the NotificationRegistration singleton from cache
    if (gSBBUseCache) {
        NSString *NR = SBBNotificationRegistration.entityName;
        [self.cacheManager removeFromCacheObjectOfType:NR withId:NR];
    }
    
    // clear the local copy of the registration guid
    _registrationGuid = nil;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    NSString *endpoint = [NSString stringWithFormat:kSBBNotificationsGuidAPIFormat, guid];
    
    // fire it off in the background in case they're offline at the moment
    return [self.networkManager delete:endpoint headers:headers parameters:nil background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
#if DEBUG
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Unregister for push notifications HTTP response code: %ld", (long)httpResponse.statusCode);
#endif
        if (completion) {
            completion(nil, responseObject, error);
        }
    }];
}

- (NSArray *)topicGuidsFromBridgeJSON:(NSDictionary *)json
{
    // can't look at created objects for whether a topic is subscribed in case they were mapped
    // with different property names; we need to look at the Bridge JSON to be sure
    NSArray *statuses = json[NSStringFromSelector(@selector(items))];
    NSMutableArray *subscribedGuids = [NSMutableArray array];
    for (NSDictionary *statusDict in statuses) {
        NSString *topicGuid = statusDict[NSStringFromSelector(@selector(topicGuid))];
        NSNumber *subscribed = statusDict[NSStringFromSelector(@selector(subscribed))];
        if (subscribed.boolValue && topicGuid.length) {
            [subscribedGuids addObject:topicGuid];
        }
    }
    
    return [subscribedGuids copy];
}

- (NSURLSessionTask *)getSubscriptionStatuses:(SBBNotificationManagerSubscriptionStatusCompletionBlock)completion
{
    NSString *guid = self.registrationGuid;
    if (!guid.length) {
        // the account is not registered with Bridge for push notifications so do nothing
        if (completion) {
            completion(nil, nil, [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeNotRegisteredForPushNotifications userInfo:nil]);
        }
        return nil;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    NSString *endpoint = [NSString stringWithFormat:kSBBSubscriptionsAPIFormat, guid];
    return [self.networkManager get:endpoint headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
#if DEBUG
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Get subscription statuses HTTP response code: %ld", (long)httpResponse.statusCode);
#endif
        NSArray *subscriptions = nil;
        NSArray<NSString *> *topicGuids = nil;
        if (!error) {
            SBBSubscriptionStatusList *subscriptionStatusList = [self.objectManager objectFromBridgeJSON:responseObject];
            subscriptions = [subscriptionStatusList.items copy];
            topicGuids = [self topicGuidsFromBridgeJSON:responseObject];
        }
        
        if (completion) {
            completion(subscriptions, topicGuids, error);
        }
    }];
}

- (NSURLSessionTask *)subscribeToTopicGuids:(NSArray<NSString *> *)topicGuids completion:(SBBNotificationManagerSubscriptionStatusCompletionBlock)completion
{
    NSString *guid = self.registrationGuid;
    if (!guid.length) {
        // the account is not registered with Bridge for push notifications so do nothing
        if (completion) {
            completion(nil, nil, [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeNotRegisteredForPushNotifications userInfo:nil]);
        }
        return nil;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    NSString *endpoint = [NSString stringWithFormat:kSBBSubscriptionsAPIFormat, guid];
    NSDictionary *params = @{kSBBNotificationTopicGuidsKey: topicGuids, NSStringFromSelector(@selector(type)): kSBBSubscriptionRequest};
    // fire it off in the background in case they're offline at the moment
    return [self.networkManager post:endpoint headers:headers parameters:params background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
#if DEBUG
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Update subscriptions HTTP response code: %ld", (long)httpResponse.statusCode);
#endif
        NSArray *subscriptions = nil;
        NSArray<NSString *> *topicGuids = nil;
        if (!error) {
            SBBSubscriptionStatusList *subscriptionStatusList = [self.objectManager objectFromBridgeJSON:responseObject];
            subscriptions = [subscriptionStatusList.items copy];
            topicGuids = [self topicGuidsFromBridgeJSON:responseObject];
        }

        if (completion) {
            completion(subscriptions, topicGuids, error);
        }
    }];
}

@end
