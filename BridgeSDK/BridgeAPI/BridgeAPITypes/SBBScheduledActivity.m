//
//  SBBTask.m
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

#import "SBBScheduledActivity.h"
#import "ModelObjectInternal.h"

NSString * const SBBScheduledActivityStatusStringScheduled = @"scheduled";
NSString * const SBBScheduledActivityStatusStringAvailable = @"available";
NSString * const SBBScheduledActivityStatusStringStarted = @"started";
NSString * const SBBScheduledActivityStatusStringFinished = @"finished";
NSString * const SBBScheduledActivityStatusStringExpired = @"expired";
NSString * const SBBScheduledActivityStatusStringDeleted = @"deleted";

@implementation SBBScheduledActivity

#pragma mark Abstract method overrides

// Custom logic goes here.

- (SBBScheduledActivityStatus)statusEnum
{
    BOOL started = (self.startedOn != nil);
    BOOL finished = (self.finishedOn != nil);
    BOOL available = ([self.scheduledOn timeIntervalSinceNow] <= 0);
    BOOL expired = ([self.expiresOn timeIntervalSinceNow] >= 0);
    
    SBBScheduledActivityStatus status = SBBScheduledActivityStatusScheduled;
    if (started) {
        if (finished) {
            status = SBBScheduledActivityStatusFinished;
        } else {
            status = SBBScheduledActivityStatusStarted;
        }
    } else if (finished) {
        status = SBBScheduledActivityStatusDeleted;
    } else if (expired) {
        status = SBBScheduledActivityStatusExpired;
    } else if (available) {
        status = SBBScheduledActivityStatusAvailable;
    }
    return status;
}

- (NSString *)status
{
    static NSArray<NSString *> *stringsForStatuses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringsForStatuses =
        @[
          SBBScheduledActivityStatusStringScheduled,
          SBBScheduledActivityStatusStringAvailable,
          SBBScheduledActivityStatusStringStarted,
          SBBScheduledActivityStatusStringFinished,
          SBBScheduledActivityStatusStringExpired,
          SBBScheduledActivityStatusStringDeleted
          ];

    });
    
    return stringsForStatuses[[self statusEnum]];
}

- (BOOL)validateClientData:(id<SBBJSONValue> *)clientData error:(NSError **)error
{
    return [*clientData validateJSONWithError:error];
}

- (void)reconcileWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerInternalProtocol>)objectManager
{
    // For all but the client-writable fields, the server value is completely canonical.
    // For the client-writable fields, the client value is canonical unless it is nil.
    NSDate *savedStartedOn = self.startedOn;
    NSDate *savedFinishedOn = self.finishedOn;
    id<SBBJSONValue> savedClientData = self.clientData;
    
    [self updateWithDictionaryRepresentation:dictionary objectManager:objectManager];
    
    if (savedStartedOn) {
        self.startedOn = savedStartedOn;
    }
    
    if (savedFinishedOn) {
        self.finishedOn = savedFinishedOn;
    }
    
    if (savedClientData) {
        self.clientData = savedClientData;
    }
}

@end
