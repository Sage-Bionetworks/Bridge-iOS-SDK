//
//  SBBDateTimeRangeResourceList.m
//
//	Copyright (c) 2014-2018 Sage Bionetworks
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

#import "SBBDateTimeRangeResourceList.h"
#import "SBBObjectManagerInternal.h"
#import "ModelObjectInternal.h"

@implementation SBBDateTimeRangeResourceList

#pragma mark Abstract method overrides

// Custom logic goes here.
- (void)reconcileWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerInternalProtocol>)objectManager
{
    // This is how ScheduledActivity lists are returned in the /v4/activities API.
    // For items[], we want to accumulate the ScheduledActivities for a given forward cursor paged list
    // as the pages are loaded from Bridge, rather than overwriting items[] with just the current page of
    // activities each time.
    // For total, the server can be canonical and it will get updated as we insert saved items from our cache.
    // For startTime and endTime, there's really no good way to handle those that makes sense, since there
    // could be huge gaps in what's in the cache if date ranges were requested non-contiguously, so we'll
    // just let them be canonical from the server and resolve to ignore them once in the cache.
    NSArray<SBBScheduledActivity *> *savedItems = [self.items copy];
    
    // now update ourself from the dictionary
    [self updateWithDictionaryRepresentation:dictionary objectManager:objectManager];
    
    // Since ScheduledActivity objects always originate on the server, never in the app, if we have any
    // in our local cache that we're no longer getting back from the server, we should delete them locally
    // as well, since that most likely means there was some kind of problem that required cleanup on the
    // server and the missing ones are no longer canonically valid. We'll look at the startTime and endTime
    // and remove our cached items in that date range (inclusive on the lower bound, exclusive on the upper),
    // then add in the newly-retrieved ones, and sort by date(s) before setting back as the cached object's items[].
    
    NSString *scheduledOnKey = NSStringFromSelector(@selector(scheduledOn));
    NSString *expiresOnKey = NSStringFromSelector(@selector(expiresOn));
    NSString *persistentKey = NSStringFromSelector(@selector(persistentValue));
    NSString *finishedOnKey = NSStringFromSelector(@selector(finishedOn));
    
    // The endpoint we use to retrieve scheduled activities (/v4/activities with a date range) will return all
    // items whose schedule period (scheduledOn..expiresOn) overlaps the requested date range, regardless of having
    // been started or finished. Tasks that don't expire are treated as expiring at the end of time for this purpose.
    //
    // The one exception is that persistent task instancess (which can't have an expiresOn date) that have been marked
    // finished will only be included in the results if their scheduledOn time is in the requested date range, since
    // the number of these over the course of a study is unbounded and we don't want every single one to come back in
    // every query regardless of date range.
    //
    // So the logic here is: Save the ones the server wouldn't have returned or superseded in this query, and merge those
    // back in with the ones that it did return. The ones we need to save were scheduled before the start of the range
    // and either expired before the start of the range, or if persistent, have been marked finished; or else are not
    // scheduled until at or beyond the end of the requested range.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K < %@ && ((%K != nil && %K < %@) OR (%K == TRUE && %K != nil))) OR %K >= %@",
                              scheduledOnKey, self.startTime,
                              expiresOnKey,
                              expiresOnKey, self.startTime,
                              persistentKey,
                              finishedOnKey,
                              scheduledOnKey, self.endTime];
    savedItems = [savedItems filteredArrayUsingPredicate:predicate];
    savedItems = [savedItems arrayByAddingObjectsFromArray:self.items];
    
    savedItems = [savedItems sortedArrayUsingComparator:^NSComparisonResult(SBBScheduledActivity * _Nonnull obj1, SBBScheduledActivity *  _Nonnull obj2) {
        NSComparisonResult compareScheduled = [obj1.scheduledOn compare:obj2.scheduledOn];
        if (compareScheduled == NSOrderedSame) {
            NSDate *secondary1 = obj1.finishedOn ?: obj1.startedOn ?: obj1.expiresOn ?: NSDate.distantFuture;
            NSDate *secondary2 = obj2.finishedOn ?: obj2.startedOn ?: obj2.expiresOn ?: NSDate.distantFuture;
            return [secondary1 compare:secondary2];
        } else {
            return compareScheduled;
        }
    }];
    
    [self removeItemsObjects];
    for (SBBScheduledActivity *scheduledActivity in savedItems) {
        [self addItemsObject:scheduledActivity];
    }
}

@end
