//
//  SBBActivityManager.m
//  BridgeSDK
//
//	Copyright (c) 2015-2017, Sage Bionetworks
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
#import "SBBDateTimeRangeResourceList.h"

#define ACTIVITY_API V4_API_PREFIX @"/activities"

NSString * const kSBBActivityAPI =       ACTIVITY_API;
NSInteger const kMaxDateRange =     14; // server supports requesting a span of < 15 days at a time

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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self getScheduledActivitiesForDaysAhead:daysAhead cachingPolicy:policy withCompletion:completion];
#pragma clang diagnostic pop
}

- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self getScheduledActivitiesForDaysAhead:daysAhead daysBehind:1 cachingPolicy:policy withCompletion:completion];
#pragma clang diagnostic pop
}

// for backward compatibility for laggards still using the deprecated daysAhead/daysBehind methods
- (NSArray *)filterTasks:(NSArray *)tasks forDaysAhead:(NSInteger)daysAhead andDaysBehind:(NSInteger)daysBehind excludeStillValid:(BOOL)excludeValid
{
    NSDate *now = [NSDate date];
    NSDate *todayStart = [[NSCalendar currentCalendar] startOfDayForDate:now];
    NSDate *windowStart, *windowEnd;
    [self startDate:&windowStart andEndDate:&windowEnd fromDaysAhead:daysAhead andDaysBehind:daysBehind];
    
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
        // "valid things" are defined as the subset of the above things that the server would have returned
        // from the old /v3/activities endpoint.
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
    // It's in the date range [startDate, endDate) if:
    //  - it never expires or expires on or after startDate AND
    //  - it was scheduled before endDate
    NSString *scheduledOnKey = NSStringFromSelector(@selector(scheduledOn));
    NSString *expiresOnKey = NSStringFromSelector(@selector(expiresOn));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == nil OR %K >= %@) AND %K < %@",
                              expiresOnKey,
                              expiresOnKey, startDate,
                              scheduledOnKey, endDate];
    
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

- (void)startDate:(NSDate **)startDate andEndDate:(NSDate **)endDate fromDaysAhead:(NSInteger)daysAhead andDaysBehind:(NSInteger)daysBehind
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    if (startDate) {
        NSDate *startOfToday = [calendar startOfDayForDate:now];
        *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-daysBehind toDate:startOfToday options:0];
    }
    
    if (endDate) {
        NSDate *endOfToday = [calendar nextDateAfterDate:now matchingHour:0 minute:0 second:0 options:NSCalendarMatchNextTimePreservingSmallerUnits];
        *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:daysAhead toDate:endOfToday options:0];
    }
}

- (NSURLSessionTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead daysBehind:(NSInteger)daysBehind cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    NSDate *startDate, *endDate;
    [self startDate:&startDate andEndDate:&endDate fromDaysAhead:daysAhead andDaysBehind:daysBehind];
    return [self getScheduledActivitiesFrom:startDate to:endDate cachingPolicy:policy withCompletion:completion];
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
- (NSURLSessionTask *)fetchHistoricalActivitiesFrom:(NSDate *)start to:(NSDate *)end accumulatedItems:(NSMutableArray *)accumulatedItems objectManager:(id<SBBObjectManagerProtocol>)objectManager completion:(SBBActivityManagerGetCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *finish = [calendar dateByAddingUnit:NSCalendarUnitDay value:kMaxDateRange toDate:start options:0];
    NSDate *stop = [finish compare:end] == NSOrderedAscending ? finish : end;
    
    // IA-286 Don't request activities across a daylight saving time transition in a single REST API call; Bridge requires
    // the timezone offset part of startTime and endTime to be the same, and will respond with a 400 error if they are not.
    NSDate *nextTransition = [NSTimeZone.localTimeZone nextDaylightSavingTimeTransitionAfterDate:start];
    
    // Make sure the NSDates we use for the end of this range and the start of the next one will convert to ISO8601 with the
    // right time zone offset to match the other end of their respective range, by using the instant 1 mSec before the
    // transition for the endTime of this range, and the transition itself for the startTime of the next range.
    // (The actual time of the transition converts to ISO8601 with the post-transition timezone offset.)
    NSDate *justBefore = [nextTransition dateByAddingTimeInterval:-0.001];
    
    BOOL willTransition = ([nextTransition compare:stop] == NSOrderedAscending);
    
    if (willTransition) {
        // use the instant just before the transition as the end of this range
        stop = justBefore;
    }
    NSDictionary *parameters = @{
                                 @"startTime": [start ISO8601String],
                                 @"endTime": [stop ISO8601String]
                                 };
    
    if (willTransition) {
        // ...and now set up to use the transition as the start of the next range
        stop = nextTransition;
    }
    
    return [self.networkManager get:kSBBActivityAPI headers:headers parameters:parameters completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) {
#if DEBUG
            NSLog(@"Error fetching scheduled activities from Bridge from %@ to %@:\n%@\nResponse:\n%@", parameters[@"startTime"], parameters[@"endTime"], error, responseObject);
#endif
            if (completion) {
                completion(responseObject, error);
            }
        } else {
            NSDictionary *objectJSON = responseObject;
            if (gSBBUseCache) {
                // Set an identifier in the JSON so we can find the cached object later--since
                // DateTimeRangeResourceList doesn't come with anything by which to distinguish one
                // from another if the items[] list is empty.
                NSMutableDictionary *objectWithListIdentifier = [responseObject mutableCopy];
                
                // -- get the identifier key path we need to set from the cache manager core data entity description
                //    rather than hardcoding it with a string literal
                NSEntityDescription *entityDescription = [SBBDateTimeRangeResourceList entityForContext:self.cacheManager.cacheIOContext];
                NSString *entityIDKeyPath = entityDescription.userInfo[@"entityIDKeyPath"];
                
                // -- set it in the JSON to this Activity Manager's list identifier
                [objectWithListIdentifier setValue:[self listIdentifier] forKeyPath:entityIDKeyPath];
                objectJSON = [objectWithListIdentifier copy];
            }
            
            // convert result to an object (reading the results into cache if we're doing that)
            // so we can accumulate the results (if we're doing that)
            SBBDateTimeRangeResourceList *dtrrList = (SBBDateTimeRangeResourceList *)[objectManager objectFromBridgeJSON:objectJSON];
            if (accumulatedItems) {
                // if we're not caching or are ignoring cache, accumulate the raw list of items from Bridge
                // as we go
                [accumulatedItems addObjectsFromArray:dtrrList.items];
            }
            
            // see if we're done
            if ([stop isEqualToDate:end]) {
                if (completion) {
                    if (accumulatedItems) {
                        completion([accumulatedItems copy], nil);
                    } else {
                        completion(dtrrList.items, nil);
                    }
                }
            } else {
                // keep going
                [self fetchHistoricalActivitiesFrom:stop to:end accumulatedItems:accumulatedItems objectManager:objectManager completion:completion];
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

- (SBBDateTimeRangeResourceList *)cachedDateTimeRangeList
{
    SBBDateTimeRangeResourceList *dtrrl = (SBBDateTimeRangeResourceList *)[self.cacheManager cachedObjectOfType:SBBDateTimeRangeResourceList.entityName withId:[self listIdentifier] createIfMissing:NO];

    return dtrrl;
}

- (id<SBBObjectManagerProtocol>)nonCachingObjectManager
{
    SBBObjectManager *original = (SBBObjectManager *)self.objectManager;
    if (![original isKindOfClass:[SBBObjectManager class]]) {
        return original; // don't mess with a custom object manager that doesn't inherit from ours
    }
    SBBObjectManager *objectManager = [SBBObjectManager objectManager];
    objectManager.bypassCache = YES;
    
    // make sure it does the same mappings
    objectManager.classForType = [original.classForType mutableCopy];
    objectManager.typeForClass = [original.typeForClass mutableCopy];
    objectManager.mappingsForType = [original.mappingsForType mutableCopy];
    
    return objectManager;
}

- (NSURLSessionTask *)getScheduledActivitiesFrom:(NSDate *)scheduledFrom to:(NSDate *)scheduledTo cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    // if we're going straight to cache, just get it and get out
    if (gSBBUseCache && policy == SBBCachingPolicyCachedOnly) {
        if (completion) {
            SBBDateTimeRangeResourceList *list = [self cachedDateTimeRangeList];
            NSArray *requestedTasks = [self filterAndMapTasks:list.items scheduledFrom:scheduledFrom to:scheduledTo];
            completion(requestedTasks, nil);
        }
        
        return nil;
    }
    
    NSMutableArray *accumulatedItems = nil;
    id<SBBObjectManagerProtocol> objectManager = self.objectManager;
    
    if (!gSBBUseCache || policy == SBBCachingPolicyNoCaching) {
        objectManager = [self nonCachingObjectManager];
        accumulatedItems = [NSMutableArray array];
        
    }
    
    return [self fetchHistoricalActivitiesFrom:scheduledFrom to:scheduledTo accumulatedItems:accumulatedItems objectManager:objectManager completion:^(NSArray * _Nullable activitiesList, NSError * _Nullable error) {
        if (completion) {
            NSArray *requestedTasks = [self filterAndMapTasks:activitiesList scheduledFrom:scheduledFrom to:scheduledTo];
            completion(requestedTasks, error);
        }
    }];
}

- (NSURLSessionTask *)getScheduledActivitiesFrom:(NSDate *)scheduledFrom to:(NSDate *)scheduledTo withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    SBBCachingPolicy policy = gSBBUseCache ? SBBCachingPolicyFallBackToCached : SBBCachingPolicyNoCaching;

    return [self getScheduledActivitiesFrom:scheduledFrom to:scheduledTo cachingPolicy:policy withCompletion:completion];
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
