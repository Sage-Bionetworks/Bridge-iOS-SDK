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
#import "BridgeSDKInternal.h"

#define ACTIVITY_API GLOBAL_API_PREFIX @"/activities"

NSString * const kSBBActivityAPI =       ACTIVITY_API;
NSTimeInterval const kSBB24Hours =       86400;

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

- (NSURLSessionDataTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead withCompletion:(SBBActivityManagerGetCompletionBlock)completion {
    SBBCachingPolicy policy = gSBBUseCache ? SBBCachingPolicyFallBackToCached : SBBCachingPolicyNoCaching;
    return [self getScheduledActivitiesForDaysAhead:daysAhead cachingPolicy:policy withCompletion:completion];
}

- (NSURLSessionDataTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    return [self getScheduledActivitiesForDaysAhead:daysAhead daysBehind:0 cachingPolicy:policy withCompletion:completion];
}

- (NSURLSessionDataTask *)getScheduledActivitiesForDaysAhead:(NSInteger)daysAhead daysBehind:(NSInteger)daysBehind cachingPolicy:(SBBCachingPolicy)policy withCompletion:(SBBActivityManagerGetCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    __block SBBResourceList *tasks = nil;
    NSArray *daysBehindTasks = [NSArray array];
    id<SBBCacheManagerProtocol> cacheManager = nil;
    if (policy != SBBCachingPolicyNoCaching) {
        if ([self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
            cacheManager = ((id<SBBObjectManagerInternalProtocol>)self.objectManager).cacheManager;
        }
        tasks = (SBBResourceList *)[cacheManager cachedSingletonObjectOfType:@"ResourceList" createIfMissing:NO];
        
        // if we're going straight to cache, we're done
        if (policy == SBBCachingPolicyCachedOnly) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(tasks, nil);
                }
            });
            return nil;
        }
        
        // otherwise, keep unfinished tasks from yesterday so we can show them in the Yesterday section
        // (because the server doesn't give us those)
        if (daysBehind > 0) {
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDate *today = [cal startOfDayForDate:[NSDate date]];
            NSDate *windowStartDate = [cal startOfDayForDate:[NSDate dateWithTimeIntervalSinceNow:-daysBehind * kSBB24Hours]];
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                SBBScheduledActivity *activity = (SBBScheduledActivity *)evaluatedObject;
                if (!activity.expiresOn) {
                    // if it never expires it would still be in the list from the server
                    return NO;
                }
                
                NSComparisonResult compareToToday = [activity.expiresOn compare:today];
                NSComparisonResult compareToStart = [activity.expiresOn compare:windowStartDate];
                BOOL withinDaysBehind = ((compareToToday == NSOrderedAscending) || (compareToToday == NSOrderedSame)) && ((compareToStart == NSOrderedDescending) || (compareToStart == NSOrderedSame));
                
                return withinDaysBehind && activity.finishedOn == nil;
            }];
            
            daysBehindTasks = [tasks.items filteredArrayUsingPredicate:predicate];
        }
    }

    return [self.networkManager get:kSBBActivityAPI headers:headers parameters:@{@"daysAhead": @(daysAhead), @"offset": [[NSDate date] ISO8601OffsetString]} completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        tasks = [self.objectManager objectFromBridgeJSON:responseObject];
        if (policy == SBBCachingPolicyFallBackToCached) {
            // we've either updated the cached tasks list from the server, or not, as the case may be;
            // in either case, we want to pass the cached tasks list to the completion handler.
            tasks = (SBBResourceList *)[cacheManager cachedSingletonObjectOfType:@"ResourceList" createIfMissing:NO];
            
            // ...ok, if we *did* update from the server though, we want to add back the ones left over from
            // the daysBehind window.
            if (!error && daysBehindTasks.count) {
                [tasks insertItems:daysBehindTasks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, daysBehindTasks.count)]];
                
                // ...and save it back to the cache for later.
                [tasks saveToCoreDataCacheWithObjectManager:self.objectManager];
            }
        }
        if (completion) {
            completion(tasks, error);
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

@end
