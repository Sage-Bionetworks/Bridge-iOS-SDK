//
//  SBBActivityEventManager.m
//  BridgeSDK
//
//    Copyright (c) 2018, Sage Bionetworks
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

#import "SBBActivityEventManager.h"
#import "SBBActivityEvent.h"
#import "SBBBridgeAPIManagerInternal.h"
#import "ModelObjectInternal.h"

#define ACTIVITYEVENTS_API V1_API_PREFIX @"/activityevents"

NSString * const kSBBActivityEventsAPI = ACTIVITYEVENTS_API;

@implementation SBBActivityEventManager

+ (instancetype)defaultComponent
{
    static SBBActivityEventManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSURLSessionTask *)createActivityEvent:(NSString *)eventKey withTimestamp:(NSDate *)timestamp completion:(SBBActivityEventManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSString *ISO8601Timestamp = timestamp.ISO8601String;
    NSDictionary *parameters = @{
                                 @"eventKey": eventKey,
                                 @"timestamp": ISO8601Timestamp
                                 };
    
    if (gSBBUseCache) {
        // write the ActivityEvent to local cache immediately
        [self.cacheManager.cacheIOContext performBlock:^{
            SBBActivityEvent *event = (SBBActivityEvent *)[self.cacheManager cachedObjectOfType:SBBActivityEvent.entityName withId:eventKey createIfMissing:YES];
            event.timestamp = timestamp;
            [event saveToCoreDataCacheWithObjectManager:self.objectManager];
        }];
    }
    
    return [self.networkManager post:kSBBActivityEventsAPI headers:headers parameters:parameters background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)getActivityEvents:(SBBActivityEventManagerGetCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    return [self.networkManager get:kSBBActivityEventsAPI headers:headers parameters:nil background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        NSArray<SBBActivityEvent *> *events = nil;
        if (!error) {
            // we don't care about the ResourceList object (and don't want to cache it), just want the items it contains
            id<SBBJSONValue> items = [responseObject valueForKey:NSStringFromSelector(@selector(items))];
            events = [self.objectManager objectFromBridgeJSON:items];
        } else if (gSBBUseCache) {
            // fall back to cache
            NSSortDescriptor *sortByTimestamp = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(timestamp)) ascending:YES];
            NSError *fetchError = nil;
            events = [self.cacheManager fetchCachedObjectsOfType:SBBActivityEvent.entityName predicate:nil sortDescriptors:sortByTimestamp fetchLimit:0 error:&fetchError];
            if (fetchError) {
                NSLog(@"Error fetching cached ActivityEvent objects: %@", fetchError);
                
                // we tried to fall back to cache and got another error, so let's pass that one to the completion handler
                error = fetchError;
            }
        }
        
        if (completion) {
            completion(events, error);
        }
    }];
}

@end
