//
//  SBBSchedule.h
//
//  $Id$
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

@property (nonatomic, strong) NSString* activityRef;

@property (nonatomic, strong) NSString* activityType;

@property (nonatomic, strong) NSString* cronTrigger;

@property (nonatomic, strong) NSDate* endsOn;

@property (nonatomic, strong) NSString* expires;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* scheduleType;

@property (nonatomic, strong) NSDate* startsOn;

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
