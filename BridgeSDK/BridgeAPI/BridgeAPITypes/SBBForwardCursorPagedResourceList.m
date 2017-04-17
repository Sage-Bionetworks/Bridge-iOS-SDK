//
//  SBBForwardCursorPagedResourceList.m
//
//	Copyright (c) 2014-2016 Sage Bionetworks
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

#import "SBBForwardCursorPagedResourceList.h"
#import "SBBObjectManagerInternal.h"
#import "ModelObjectInternal.h"
#import "SBBForwardCursorPagedResourceListInternal.h"

@implementation SBBForwardCursorPagedResourceList

#pragma mark Abstract method overrides

// Custom logic goes here.
- (void)reconcileWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerInternalProtocol>)objectManager
{
    // For all but items[], the server value is canonical.
    // For items[], we want to accumulate the ScheduledActivities for a given forward cursor paged list
    // as the pages are loaded from Bridge, rather than overwriting items[] with just the current page of
    // activities each time.
    NSArray<SBBScheduledActivity *> *savedItems = self.items;
    
    [self updateWithDictionaryRepresentation:dictionary objectManager:objectManager];
    
    // Since ScheduledActivity objects always originate on the server, never in the app, if we have any
    // in our local cache that we're no longer getting back from the server, we should delete them locally
    // as well, since that most likely means there was some kind of problem that required cleanup on the
    // server and the missing ones are no longer canonically valid. We look at the offsetBy string to
    // determine the (inclusive) start date for the current page of items, and remove our cached items in
    // the date range between that and the previous offsetBy (or scheduledOnStart if not yet set), then
    // add in the newly-retrieved ones, and sort by scheduledOnStart descending before adding back to
    // the cached object's items[].
    NSDate *lastOffset = self.lastOffsetBy__;
    if (!lastOffset) {
        lastOffset = self.scheduledOnStart;
    }
    NSString *comparisonKey = NSStringFromSelector(@selector(scheduledOnStart));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K < %K OR %K >= %@",
                              comparisonKey, NSStringFromSelector(@selector(offsetBy)),
                              comparisonKey, lastOffset];
    savedItems = [savedItems filteredArrayUsingPredicate:predicate];
    [savedItems arrayByAddingObjectsFromArray:self.items];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:comparisonKey ascending:NO];
    savedItems = [savedItems sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self removeItemsObjects];
    for (SBBScheduledActivity *scheduledActivity in savedItems) {
        [self addItemsObject:scheduledActivity];
    }
    
    // update lastOffsetBy__ for the next pass
    self.lastOffsetBy__ = self.offsetBy;
}

@end
