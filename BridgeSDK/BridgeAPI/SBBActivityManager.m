//
//  SBBTaskManager.m
//  BridgeSDK
//
//	Copyright (c) 2015-2016, Sage Bionetworks
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
#import "SBBBridgeAPIManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "SBBObjectManagerInternal.h"
#import "SBBBridgeObjects.h"
#import "NSDate+SBBAdditions.h"
#import "NSError+SBBAdditions.h"
#import "BridgeSDK+Internal.h"
#import "SBBBridgeInfo.h"
#import "ModelObjectInternal.h"
#import "SBBResourceListInternal.h"
#import "SBBForwardCursorPagedResourceListInternal.h"

#define ACTIVITY_API GLOBAL_API_PREFIX @"/activities"

NSString * const kSBBActivityAPI =       ACTIVITY_API;
NSString * const kSBBHistoricalActivityAPIFormat = ACTIVITY_API @"/%@";
NSTimeInterval const kSBB24Hours =       86400;
NSInteger const     kMaxAdvance  =       4; // server only supports 4 days ahead
NSInteger const     kFetchPageSize =     100;

@interface SBBActivityManager()<SBBActivityManagerInternalProtocol, SBBBridgeAPIManagerInternalProtocol>

@end

@implementation SBBActivityManager

+ (instancetype)defaultComponent
{
    static SBBActivityManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead withCompletion:(SBBActivityManagerGetCompletionBlock)completion {
    SBBCachingPolicy policy = gSBBUseCache ? SBBCachingPolicyFallBackToCached : SBBCachingPolicyNoCaching;
    return [self getScheduledActivitiesForDaysAhead:daysAhead cachingPolicy:policy withCompletion:completion];
}

- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    return [self getScheduledActivitiesForDaysAhead:daysAhead daysBehind:1 cachingPolicy:policy withCompletion:completion];
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

- (NSArray *)filterTasks:(NSArray *)tasks scheduledFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    NSString *comparisonKey = NSStringFromSelector(@selector(scheduledOn));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@ AND %K < %@",
                              comparisonKey, startDate,
                              comparisonKey, endDate];
    
    return [tasks filteredArrayUsingPredicate:predicate];
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

// make sure to be on the cache IO queue before calling these next three methods, and stay there until after
// all three have been called!
- (SBBResourceList *)cachedTasksFromCacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    SBBResourceList *tasks = (SBBResourceList *)[cacheManager cachedObjectOfType:[SBBResourceList entityName] withId:[self listIdentifier] createIfMissing:NO];
    
    return tasks;
}

- (NSArray<SBBScheduledActivity *> *)savedTasksFromCachedTasks:(NSArray<SBBScheduledActivity *> *)cachedTasks
{
    SBBBridgeInfo *bridgeInfo = [SBBBridgeInfo shared];
    return [self filterTasks:cachedTasks forDaysAhead:bridgeInfo.cacheDaysAhead andDaysBehind:bridgeInfo.cacheDaysBehind excludeStillValid:YES];
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

- (NSString *)listIdentifier
{
    return [SBBScheduledActivity entityName];
}

- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead daysBehind:(NSInteger)daysBehind cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
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
    
    // If caching, always request the maximum days ahead from the server so we have them cached
    // and if the desiredDaysAhead is more than the max allowed, then fetch a minimum number of
    // items per schedule.
    NSInteger desiredDaysAhead = gSBBUseCache ? [SBBBridgeInfo shared].cacheDaysAhead : daysAhead;
    NSInteger fetchDaysAhead = MIN(kMaxAdvance, desiredDaysAhead);
    NSInteger fetchMinimumPerSchedule = (fetchDaysAhead < desiredDaysAhead) ? kMaxAdvance : 0;
    NSDictionary *parameters = @{@"daysAhead": @(fetchDaysAhead),
                                 @"minimumPerSchedule": @(fetchMinimumPerSchedule),
                                 @"offset": [[NSDate date] ISO8601OffsetString]};
    return [self.networkManager get:kSBBActivityAPI headers:headers parameters:parameters completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (gSBBUseCache) {
            [self.cacheManager.cacheIOContext performBlock:^{
                SBBResourceList *tasks = [self cachedTasksFromCacheManager:self.cacheManager];
                
                // before processing updated data, save all tasks from the past kDaysToCache days,
                // and finished ones from today (or later?) (because the server doesn't give us those)
                NSArray<SBBScheduledActivity *> *savedTasks = [self savedTasksFromCachedTasks:tasks.items];

                // now process the new data into the cache
                if (!error) {
                    // first, set an identifier in the JSON so we can find the cached object later--since
                    // ResourceList doesn't come with anything by which to distinguish one from another if the
                    // items[] list is empty.
                    NSMutableDictionary *objectWithEntityID = [responseObject mutableCopy];
                    
                    // -- get the identifier key path we need to set from the cache manager core data entity description
                    //    rather than hardcoding it with a string literal
                    NSEntityDescription *entityDescription = [SBBResourceList entityForContext:self.cacheManager.cacheIOContext];
                    NSString *entityIDKeyPath = entityDescription.userInfo[@"entityIDKeyPath"];
                    
                    // -- set it in the JSON to the identifier for the list this manager manages
                    [objectWithEntityID setValue:[self listIdentifier] forKeyPath:entityIDKeyPath];
                    
                    // -- now process into the cache
                    [self.objectManager objectFromBridgeJSON:objectWithEntityID];
                }
                
                // we've either updated the cached tasks list from the server, or not, as the case may be;
                // in either case, we want to pass the cached tasks list to the completion handler.
                tasks = (SBBResourceList *)[self.cacheManager cachedObjectOfType:@"ResourceList" withId:[self listIdentifier] createIfMissing:NO];
                
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

- (NSURLSessionTask *)startScheduledActivity:(SBBScheduledActivity *)scheduledActivity asOf:(NSDate *)startDate withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    scheduledActivity.startedOn = startDate;
    return [self updateScheduledActivities:@[scheduledActivity] withCompletion:completion];
}

- (NSURLSessionTask *)finishScheduledActivity:(SBBScheduledActivity *)scheduledActivity asOf:(NSDate *)finishDate withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    scheduledActivity.finishedOn = finishDate;
    return [self updateScheduledActivities:@[scheduledActivity] withCompletion:completion];
}

- (NSURLSessionTask *)deleteScheduledActivity:(SBBScheduledActivity *)scheduledActivity withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    return [self finishScheduledActivity:scheduledActivity asOf:[NSDate date] withCompletion:completion];
}

- (NSURLSessionTask *)setClientData:(id<SBBJSONValue>)clientData forScheduledActivity:(SBBScheduledActivity *)scheduledActivity withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    // If it's not valid JSON, call the completion block with the error and return nil
    NSError *error = nil;
    if (![clientData validateJSONWithError:&error]) {
        if (completion) {
            completion(clientData, error);
        }
        return nil;
    }
    
    // otherwise, set it and update to Bridge
    scheduledActivity.clientData = clientData;
    return [self updateScheduledActivities:@[scheduledActivity] withCompletion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        // if we set clientData to [NSNull null], now that we're done updating to Bridge set it to nil in the PONSO object
        if (scheduledActivity.clientData == [NSNull null]) {
            scheduledActivity.clientData = nil;
        }
        
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)updateScheduledActivities:(NSArray *)scheduledActivities withCompletion:(SBBActivityManagerUpdateCompletionBlock)completion
{
    id jsonTasks = [self.objectManager bridgeJSONFromObject:scheduledActivities];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    if (gSBBUseCache) {
        // Update the activities in the local cache
        [self.cacheManager.cacheIOContext performBlock:^{
            for (SBBScheduledActivity *scheduledActivity in scheduledActivities) {
                [scheduledActivity saveToCoreDataCacheWithObjectManager:self.objectManager];
            }
        }];
    }
    
    // Activities can be started/finished without a network connection, so this has to be able to do that too
    return [self.networkManager post:kSBBActivityAPI headers:headers parameters:jsonTasks background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
#if DEBUG
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Update tasks HTTP response code: %ld", (long)httpResponse.statusCode);
#endif
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

// pass in an initialized NSMutableArray in accumulatedItems either if not caching, or ignoring cache
- (NSURLSessionTask *)fetchHistoricalActivitiesForGuid:(NSString *)activityGuid withParameters:(NSDictionary *)parameters offsetBy:(NSDate *)offsetBy accumulatedItems:(NSMutableArray *)accumulatedItems completion:(SBBActivityManagerGetCompletionBlock)completion
{
    if (offsetBy) {
        NSString *offsetString = [offsetBy ISO8601DateTimeOnlyString];
        NSMutableDictionary *parametersWithOffset = [parameters mutableCopy];
        parametersWithOffset[NSStringFromSelector(@selector(offsetBy))] = offsetString;
        parameters = [parametersWithOffset copy];
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSString *endpoint = [NSString stringWithFormat:kSBBHistoricalActivityAPIFormat, activityGuid];
    
    return [self.networkManager get:endpoint headers:headers parameters:parameters completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) {
            if (gSBBUseCache) {
                // clear lastOffsetBy__ for the next time we fetch this activity's history
                SBBForwardCursorPagedResourceList *list = [self cachedListForActivityGuid:activityGuid];
                list.lastOffsetBy__ = nil;
                [list saveToCoreDataCacheWithObjectManager:self.objectManager];
            }
            if (completion) {
                completion(responseObject, error);
            }
        } else {
            NSDictionary *objectJSON = responseObject;
            if (gSBBUseCache) {
                // first, set an identifier in the JSON so we can find the cached object later--since
                // ForwardCursorPagedResourceList doesn't come with anything by which to distinguish one
                // from another if the items[] list is empty.
                NSMutableDictionary *objectWithActivityGuid = [responseObject mutableCopy];
                
                // -- get the identifier key path we need to set from the cache manager core data entity description
                //    rather than hardcoding it with a string literal
                NSEntityDescription *entityDescription = [SBBForwardCursorPagedResourceList entityForContext:self.cacheManager.cacheIOContext];
                NSString *entityIDKeyPath = entityDescription.userInfo[@"entityIDKeyPath"];
                
                // -- set it in the JSON to the activityGuid we're fetching
                [objectWithActivityGuid setValue:activityGuid forKeyPath:entityIDKeyPath];
                objectJSON = [objectWithActivityGuid copy];
            }
            
            // -- now process into the cache (if caching), and in any case, get the PONSO object
            //    so we can check if we're done yet
            SBBForwardCursorPagedResourceList *fcprl = (SBBForwardCursorPagedResourceList *)[self.objectManager objectFromBridgeJSON:objectJSON];
            
            // -- now see if we're done, and act accordingly
            if (fcprl.hasNextValue) {
                // not done, keep paging in more activities
                NSDate *newOffset = fcprl.offsetBy;
                if (accumulatedItems) {
                    // if we're not caching or are ignoring cache, accumulate the raw list of items from Bridge
                    // as we go
                    [accumulatedItems addObjectsFromArray:fcprl.items];
                }
                [self fetchHistoricalActivitiesForGuid:activityGuid withParameters:parameters offsetBy:newOffset accumulatedItems:accumulatedItems completion:completion];
            } else {
                // done, call completion
                if (completion) {
                    if (accumulatedItems) {
                        completion([accumulatedItems copy], error);
                    } else {
                        completion(fcprl.items, error);
                    }
                }
            }
        }
    }];
}

- (NSArray *)filterAndMapTasks:(NSArray *)tasks scheduledFrom:(NSDate *)scheduledFrom to:(NSDate *)scheduledTo
{
    if (![tasks isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *requestedTasks = [[self filterTasks:tasks scheduledFrom:scheduledFrom to:scheduledTo] mutableCopy];
    [self mapSubObjectsInTaskList:requestedTasks];
    return [requestedTasks copy];
}

- (SBBForwardCursorPagedResourceList *)cachedListForActivityGuid:(NSString *)activityGuid
{
    SBBForwardCursorPagedResourceList *fcprl = (SBBForwardCursorPagedResourceList *)[self.cacheManager cachedObjectOfType:[SBBForwardCursorPagedResourceList entityName] withId:activityGuid createIfMissing:NO];

    return fcprl;
}

- (NSURLSessionTask *)getScheduledActivitiesForGuid:(NSString *)activityGuid scheduledFrom:(NSDate *)scheduledFrom to:(NSDate *)scheduledTo cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    // if we're going straight to cache, just get it and get out
    if (gSBBUseCache && policy == SBBCachingPolicyCachedOnly) {
        if (completion) {
            SBBForwardCursorPagedResourceList *list = [self cachedListForActivityGuid:activityGuid];
            NSArray *requestedTasks = [self filterAndMapTasks:list.items scheduledFrom:scheduledFrom to:scheduledTo];
            completion(requestedTasks, nil);
        }
        
        return nil;
    }
    
    NSDictionary *parameters = @{@"scheduledOnStart": [scheduledFrom ISO8601String],
                                 @"scheduledOnEnd": [scheduledTo ISO8601String],
                                 @"pageSize": @(kFetchPageSize)};
    NSMutableArray *accumulatedItems = nil;
    if (!gSBBUseCache || policy == SBBCachingPolicyNoCaching) {
        accumulatedItems = [NSMutableArray array];
    }
    return [self fetchHistoricalActivitiesForGuid:activityGuid withParameters:parameters offsetBy:nil accumulatedItems:accumulatedItems completion:^(NSArray * _Nullable activitiesList, NSError * _Nullable error) {
        if (completion) {
            NSArray *requestedTasks = [self filterAndMapTasks:activitiesList scheduledFrom:scheduledFrom to:scheduledTo];
            completion(requestedTasks, error);
        }
    }];
}

- (NSURLSessionTask *)getScheduledActivitiesForGuid:(NSString *)activityGuid scheduledFrom:(NSDate *)scheduledFrom to:(NSDate *)scheduledTo withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    SBBCachingPolicy policy = gSBBUseCache ? SBBCachingPolicyFallBackToCached : SBBCachingPolicyNoCaching;

    return [self getScheduledActivitiesForGuid:activityGuid scheduledFrom:scheduledFrom to:scheduledTo cachingPolicy:policy withCompletion:completion];
}

// Note: this method blocks until it gets its turn in the cache IO context queue
- (void)flushUncompletedActivities
{
    if (gSBBUseCache) {
        if ([self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
            [self.cacheManager.cacheIOContext performBlockAndWait:^{
                SBBResourceList *cachedTasks = [self cachedTasksFromCacheManager:self.cacheManager];
                if (!cachedTasks) {
                    // nothing to do here
                    return;
                }
                
                NSArray<SBBScheduledActivity *> *savedTasks = [self savedTasksFromCachedTasks:cachedTasks.items];
                
                // clear out all its items and just add back the ones we saved
                [cachedTasks removeItemsObjects];
                [self addSavedTasks:savedTasks toResourceList:cachedTasks];
            }];
        }
    }
}

@end
