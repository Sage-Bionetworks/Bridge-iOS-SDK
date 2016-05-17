//
//  SBBTaskManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/5/15.
//
//	Copyright (c) 2015, Sage Bionetworks
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

#import "SBBActivityManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "SBBObjectManagerInternal.h"
#import "SBBBridgeObjects.h"
#import "NSDate+SBBAdditions.h"
#import "NSError+SBBAdditions.h"
#import "BridgeSDKInternal.h"

#define ACTIVITY_API GLOBAL_API_PREFIX @"/activities"

NSString * const kSBBActivityAPI =       ACTIVITY_API;
NSTimeInterval const kSBB24Hours =       86400;
NSInteger const     kDaysToCache =       7;
NSInteger const     kMaxAdvance  =       4; // server only supports 4 days ahead

@interface SBBActivityManager()<SBBActivityManagerInternalProtocol>

@property (nonatomic, readonly) id<SBBCacheManagerProtocol> cacheManager;

@end

@implementation SBBActivityManager

@synthesize cacheManager = _cacheManager;

+ (instancetype)defaultComponent
{
    static SBBActivityManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSURLSessionDataTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead withCompletion:(SBBActivityManagerGetCompletionBlock)completion {
    SBBCachingPolicy policy = gSBBUseCache ? SBBCachingPolicyFallBackToCached : SBBCachingPolicyNoCaching;
    return [self getScheduledActivitiesForDaysAhead:daysAhead cachingPolicy:policy withCompletion:completion];
}

- (NSURLSessionDataTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    return [self getScheduledActivitiesForDaysAhead:daysAhead daysBehind:1 cachingPolicy:policy withCompletion:completion];
}

- (NSURLSessionDataTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead daysBehind:(NSInteger)daysBehind cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    return [self getScheduledActivitiesForDaysAhead:daysAhead daysBehind:daysBehind cachingPolicy:policy andWait:NO withCompletion:completion];
}

- (NSArray *)filterTasks:(NSArray *)tasks forDaysAhead:(NSInteger)daysAhead andDaysBehind:(NSInteger)daysBehind excludeStillValid:(BOOL)excludeValid
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *windowStart = [cal startOfDayForDate:[NSDate dateWithTimeIntervalSinceNow:-daysBehind * kSBB24Hours]];
    NSDate *todayStart = [cal startOfDayForDate:[NSDate date]];
    NSDate *now = [NSDate date];
    NSDate *todayEnd = [cal startOfDayForDate:[NSDate dateWithTimeIntervalSinceNow:kSBB24Hours]];
    NSDate *windowEnd = [cal startOfDayForDate:[todayEnd dateByAddingTimeInterval:daysAhead * kSBB24Hours]];
    
    // things that either expired during the daysBefore period, or expire after that but start before the end of daysAhead
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K != nil AND %K > %@ AND %K < %@) OR ((%K == nil OR %K >= %@) AND %K < %@)",
                              NSStringFromSelector(@selector(expiresOn)),
                              NSStringFromSelector(@selector(expiresOn)), windowStart,
                              NSStringFromSelector(@selector(expiresOn)), todayStart,
                              NSStringFromSelector(@selector(expiresOn)),
                              NSStringFromSelector(@selector(expiresOn)), todayStart,
                              NSStringFromSelector(@selector(scheduledOn)), windowEnd];
    NSArray *filtered = [tasks filteredArrayUsingPredicate:predicate];
    if (excludeValid) {
        // "valid things" are defined as the subset of the above things that the server would return.
        // valid things expire after now and are not marked as finished. the flag is
        // set so we want to exclude those things.
        predicate = [NSPredicate predicateWithFormat:@"NOT ((%K == nil OR %K >= %@) AND %K == nil)",
                     NSStringFromSelector(@selector(expiresOn)),
                     NSStringFromSelector(@selector(expiresOn)), now,
                     NSStringFromSelector(@selector(finishedOn))
                     ];
        filtered = [filtered filteredArrayUsingPredicate:predicate];
    }
    
    return filtered;
}

- (void)mapSubObjectsInTaskList:(NSMutableArray *)taskList
{
    if ([self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
        // in case object mapping has been set up
        for (NSInteger i = 0; i < taskList.count; ++i) {
            taskList[i] = [((id<SBBObjectManagerInternalProtocol>)self.objectManager) mappedObjectForBridgeObject:taskList[i]];
        }
    }
}

- (id<SBBCacheManagerProtocol>)cacheManager
{
    if (!_cacheManager && gSBBUseCache && [self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
        _cacheManager = ((id<SBBObjectManagerInternalProtocol>)self.objectManager).cacheManager;
    }
    return _cacheManager;
}

// make sure to be on the cache IO queue before calling these next three methods, and stay there until after
// all three have been called!
- (SBBResourceList *)cachedTasksFromCacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    SBBResourceList *tasks = (SBBResourceList *)[cacheManager cachedObjectOfType:@"ResourceList" withId:@"ScheduledActivity" createIfMissing:NO];
    
    return tasks;
}

- (NSArray<SBBScheduledActivity *> *)savedTasksFromCachedTasks:(NSArray<SBBScheduledActivity *> *)cachedTasks
{
    return [self filterTasks:cachedTasks forDaysAhead:kMaxAdvance andDaysBehind:kDaysToCache excludeStillValid:YES];
}

- (void)addSavedTasks:(NSArray<SBBScheduledActivity *> *)savedTasks toResourceList:(SBBResourceList *)resourceList
{
    NSAssert([resourceList isKindOfClass:[SBBResourceList class]], @"resourceList must be an SBBResourceList object!");
    if (!savedTasks.count) {
        // nothing to do
        return;
    }
    
    [resourceList insertItems:savedTasks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, savedTasks.count)]];
    
    // ...and save it back to the cache for later.
    [resourceList saveToCoreDataCacheWithObjectManager:self.objectManager];
}

- (NSURLSessionDataTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead daysBehind:(NSInteger)daysBehind cachingPolicy:(SBBCachingPolicy)policy andWait:(BOOL)wait withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    // if we're going straight to cache, just get it and get out
    if (policy == SBBCachingPolicyCachedOnly) {
        SBBResourceList *tasks = [self cachedTasksFromCacheManager:self.cacheManager];
        
        if (completion) {
            NSMutableArray *requestedTasks = [[self filterTasks:tasks.items forDaysAhead:daysAhead andDaysBehind:daysBehind excludeStillValid:NO] mutableCopy];
            [self mapSubObjectsInTaskList:requestedTasks];
            completion(requestedTasks, nil);
        }
        
        return nil;
    }

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    // if caching, always request the maximum days ahead from the server so we have them cached
    NSInteger fetchDaysAhead = gSBBUseCache ? kMaxAdvance : daysAhead;
    return [self.networkManager get:kSBBActivityAPI headers:headers parameters:@{@"daysAhead": @(fetchDaysAhead), @"offset": [[NSDate date] ISO8601OffsetString]} completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (gSBBUseCache) {
            [self.cacheManager.cacheIOContext performBlock:^{
                SBBResourceList *tasks = [self cachedTasksFromCacheManager:self.cacheManager];
                
                // before processing updated data, save all tasks from the past kDaysToCache days,
                // and finished ones from today (or later?) (because the server doesn't give us those)
                NSArray<SBBScheduledActivity *> *savedTasks = [self savedTasksFromCachedTasks:tasks.items];

                // now process the new data into the cache
                if (!error) {
                    [self.objectManager objectFromBridgeJSON:responseObject];
                }
                
                // we've either updated the cached tasks list from the server, or not, as the case may be;
                // in either case, we want to pass the cached tasks list to the completion handler.
                tasks = (SBBResourceList *)[self.cacheManager cachedObjectOfType:@"ResourceList" withId:@"ScheduledActivity" createIfMissing:NO];
                
                // ...ok, if we *did* update from the server though, we want to add back any we saved from before.
                if (!error && savedTasks.count) {
                    [self addSavedTasks:savedTasks toResourceList:tasks];
                }
                
                if (completion) {
                    NSMutableArray *requestedTasks = [[self filterTasks:tasks.items forDaysAhead:daysAhead andDaysBehind:daysBehind excludeStillValid:NO] mutableCopy];
                    [self mapSubObjectsInTaskList:requestedTasks];
                    
                    // now get the heck out of the cacheIOContext queue
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                        completion(requestedTasks, error);
                    });
                }
            }];
        } else {
            // not caching, do it the old-fashioned way (-ish)
            SBBResourceList *tasks = nil;
            if (!error) {
                tasks = [self.objectManager objectFromBridgeJSON:responseObject];
            }
            if (completion) {
                completion(tasks.items, error);
            }
        }
    }];
}

- (NSURLSessionDataTask *)startScheduledActivity:(SBBScheduledActivity *)scheduledActivity asOf:(NSDate *)startDate withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    scheduledActivity.startedOn = startDate;
    return [self updateScheduledActivities:@[scheduledActivity] withCompletion:completion];
}

- (NSURLSessionDataTask *)finishScheduledActivity:(SBBScheduledActivity *)scheduledActivity asOf:(NSDate *)finishDate withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    scheduledActivity.finishedOn = finishDate;
    return [self updateScheduledActivities:@[scheduledActivity] withCompletion:completion];
}

- (NSURLSessionDataTask *)deleteScheduledActivity:(SBBScheduledActivity *)scheduledActivity withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    return [self finishScheduledActivity:scheduledActivity asOf:[NSDate date] withCompletion:completion];
}

- (NSURLSessionDataTask *)updateScheduledActivities:(NSArray *)scheduledActivities withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    id jsonTasks = [self.objectManager bridgeJSONFromObject:scheduledActivities];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager post:kSBBActivityAPI headers:headers parameters:jsonTasks completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
#if DEBUG
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Update tasks HTTP response code: %ld", (long)httpResponse.statusCode);
#endif
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

// Note: this method blocks until it gets its turn in the cache IO context queue
- (void)flushUncompletedActivities
{
    if (gSBBUseCache) {
        if ([self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
            [self.cacheManager.cacheIOContext performBlockAndWait:^{
                SBBResourceList *cachedTasks = [self cachedTasksFromCacheManager:self.cacheManager];
                NSArray<SBBScheduledActivity *> *savedTasks = [self savedTasksFromCachedTasks:cachedTasks.items];
                
                // clear out all its items and just add back the ones we saved
                [cachedTasks removeItemsObjects];
                [self addSavedTasks:savedTasks toResourceList:cachedTasks];
            }];
        }
    }
}

@end
