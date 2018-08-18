//
//  SBBDateRangeResourceList.m
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

#import "SBBDateRangeResourceList.h"
#import "SBBObjectManagerInternal.h"
#import "ModelObjectInternal.h"

@implementation SBBDateRangeResourceList

#pragma mark Abstract method overrides

// Custom logic goes here.
- (void)reconcileWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerInternalProtocol>)objectManager
{
    // This is how ReportData lists are returned in the /v3/users/self/reports/{identifier} API.
    // For items[], we want to merge the ReportData items for a given date range resource list
    // when the date range is loaded from Bridge, rather than overwriting items[] with just the
    // current date range of items each time.
    NSArray<SBBReportData *> *savedItems = [self.items copy];
    
    // now update ourself from the dictionary
    [self updateWithDictionaryRepresentation:dictionary objectManager:objectManager];
    
    // Since ReportData objects generally originate from the app, the client copies are canonical,
    // so we'll restore the saved ones, replacing any from the server with matching localDates.
    NSMutableArray<SBBReportData *> *newItems = [self.items mutableCopy];
    NSString *localDateKey = NSStringFromSelector(@selector(localDate));
    for (SBBReportData *savedReportData in savedItems) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", localDateKey, savedReportData.localDate];
        [newItems filterUsingPredicate:predicate];
        [newItems addObject:savedReportData];
    }
    
    [newItems sortUsingSelector:@selector(localDate)];
    
    [self removeItemsObjects];
    for (SBBReportData *newReportData in newItems) {
        [self addItemsObject:newReportData];
    }
}

@end
