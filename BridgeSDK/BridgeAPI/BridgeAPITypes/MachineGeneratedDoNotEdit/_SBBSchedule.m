//
//  SBBSchedule.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSchedule.h instead.
//

#import "_SBBSchedule.h"
#import "NSDate+SBBAdditions.h"

#import "SBBActivity.h"

@interface _SBBSchedule()
@property (nonatomic, strong, readwrite) NSArray *activities;

@end

/** \ingroup DataModel */

@implementation _SBBSchedule

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.activityRef = [dictionary objectForKey:@"activityRef"];

        self.activityType = [dictionary objectForKey:@"activityType"];

        self.cronTrigger = [dictionary objectForKey:@"cronTrigger"];

        self.endsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"endsOn"]];

        self.expires = [dictionary objectForKey:@"expires"];

        self.label = [dictionary objectForKey:@"label"];

        self.scheduleType = [dictionary objectForKey:@"scheduleType"];

        self.startsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startsOn"]];

		for(id objectRepresentationForDict in [dictionary objectForKey:@"activities"])
		{

SBBActivity *activitiesObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

			[self addActivitiesObject:activitiesObj];
		}
	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.activityRef forKey:@"activityRef"];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.cronTrigger forKey:@"cronTrigger"];

    [dict setObjectIfNotNil:[self.endsOn ISO8601String] forKey:@"endsOn"];

    [dict setObjectIfNotNil:self.expires forKey:@"expires"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.scheduleType forKey:@"scheduleType"];

    [dict setObjectIfNotNil:[self.startsOn ISO8601String] forKey:@"startsOn"];

    if([self.activities count] > 0)
	{

		NSMutableArray *activitiesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.activities count]];
		for(SBBActivity *obj in self.activities)
		{
			[activitiesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:activitiesRepresentationsForDictionary forKey:@"activities"];

	}

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBActivity *activitiesObj in self.activities)
	{
		[activitiesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void)addActivitiesObject:(SBBActivity*)value_ settingInverse: (BOOL) setInverse
{
    if(self.activities == nil)
	{

		self.activities = [NSMutableArray array];

	}

	[(NSMutableArray *)self.activities addObject:value_];
	if (setInverse == YES) {
	    [value_ setSchedule: (SBBSchedule*)self settingInverse: NO];
	}
}
- (void)addActivitiesObject:(SBBActivity*)value_
{
    [self addActivitiesObject:(SBBActivity*)value_ settingInverse: YES];
}

- (void)removeActivitiesObjects
{

	self.activities = [NSMutableArray array];

}

- (void)removeActivitiesObject:(SBBActivity*)value_ settingInverse: (BOOL) setInverse
{
    if (setInverse == YES) {
        [value_ setSchedule: nil settingInverse: NO];
    }
    [(NSMutableArray *)self.activities removeObject:value_];
}

- (void)removeActivitiesObject:(SBBActivity*)value_
{
    [self removeActivitiesObject:(SBBActivity*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBActivity*)value inActivitiesAtIndex:(NSUInteger)idx {
    [self insertObject:value inActivitiesAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBActivity*)value inActivitiesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.activities insertObject:value atIndex:idx];
    if (setInverse == YES) {
    [value setSchedule:(SBBSchedule*)self settingInverse: NO];
    }
}

- (void)removeObjectFromActivitiesAtIndex:(NSUInteger)idx {
    [self removeObjectFromActivitiesAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromActivitiesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBActivity *object = [self.activities objectAtIndex:idx];
    [self removeActivitiesObject:object settingInverse:YES];
}

- (void)insertActivities:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertActivities:value atIndexes:indexes settingInverse:YES];
}

- (void)insertActivities:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.activities insertObjects:value atIndexes:indexes];
    if (setInverse == YES) {
        for (SBBActivity* object in value) {
            [object setSchedule:(SBBSchedule*)self settingInverse: NO];
        }
    }
}

- (void)removeActivitiesAtIndexes:(NSIndexSet *)indexes {
    [self removeActivitiesAtIndexes:indexes settingInverse:YES];
}

- (void)removeActivitiesAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsRemoved = [(NSMutableArray *)self.activities objectsAtIndexes:indexes];
        for (SBBActivity* object in objectsRemoved) {
            [object setSchedule:nil settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.activities removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInActivitiesAtIndex:(NSUInteger)idx withObject:(SBBActivity*)value {
    [self replaceObjectInActivitiesAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInActivitiesAtIndex:(NSUInteger)idx withObject:(SBBActivity*)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    SBBActivity* objectReplaced = [(NSMutableArray *)self.activities objectAtIndex:idx];
    [objectReplaced setSchedule:nil settingInverse: NO];
    [value setSchedule:(SBBSchedule*)self settingInverse: NO];
    }
    [(NSMutableArray *)self.activities replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceActivitiesAtIndexes:(NSIndexSet *)indexes withActivities:(NSArray *)value {
    [self replaceActivitiesAtIndexes:indexes withActivities:value settingInverse:YES];
}

- (void)replaceActivitiesAtIndexes:(NSIndexSet *)indexes withActivities:(NSArray *)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsReplaced = [(NSMutableArray *)self.activities objectsAtIndexes:indexes];
        for (SBBActivity* object in objectsReplaced) {
            [object setSchedule:nil settingInverse: NO];
        }
        for (SBBActivity* object in value) {
            [object setSchedule:(SBBSchedule*)self settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.activities replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
