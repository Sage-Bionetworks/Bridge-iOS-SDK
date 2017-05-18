//
//  _SBBSchedule.h
//
//	Copyright (c) 2014-2017 Sage Bionetworks
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
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSchedule.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBActivity;

@protocol _SBBSchedule

@end

@interface _SBBSchedule : SBBBridgeObject

@property (nonatomic, strong) NSString* cronTrigger;

@property (nonatomic, strong) NSString* delay;

@property (nonatomic, strong) NSDate* endsOn;

@property (nonatomic, strong) NSString* eventId;

@property (nonatomic, strong) NSString* expires;

@property (nonatomic, strong) NSString* interval;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSNumber* persistent;

@property (nonatomic, assign) BOOL persistentValue;

@property (nonatomic, strong) NSString* scheduleType;

@property (nonatomic, strong) NSDate* startsOn;

@property (nonatomic, strong) NSArray* times;

@property (nonatomic, strong, readonly) NSArray *activities;

- (void)addActivitiesObject:(SBBActivity*)value_ settingInverse: (BOOL) setInverse;
- (void)addActivitiesObject:(SBBActivity*)value_;
- (void)removeActivitiesObjects;
- (void)removeActivitiesObject:(SBBActivity*)value_ settingInverse: (BOOL) setInverse;
- (void)removeActivitiesObject:(SBBActivity*)value_;

- (void)insertObject:(SBBActivity*)value inActivitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromActivitiesAtIndex:(NSUInteger)idx;
- (void)insertActivities:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeActivitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInActivitiesAtIndex:(NSUInteger)idx withObject:(SBBActivity*)value;
- (void)replaceActivitiesAtIndexes:(NSIndexSet *)indexes withActivities:(NSArray *)values;

@end
