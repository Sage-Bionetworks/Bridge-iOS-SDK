//
//  _SBBSchedule.m
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
// Make changes to SBBSchedule.m instead.
//

#import "_SBBSchedule.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBActivity.h"

@interface _SBBSchedule()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *activities;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (Schedule)

@property (nullable, nonatomic, retain) NSString* cronTrigger;

@property (nullable, nonatomic, retain) NSString* delay;

@property (nullable, nonatomic, retain) NSDate* endsOn;

@property (nullable, nonatomic, retain) NSString* eventId;

@property (nullable, nonatomic, retain) NSString* expires;

@property (nullable, nonatomic, retain) NSString* interval;

@property (nullable, nonatomic, retain) NSString* label;

@property (nullable, nonatomic, retain) NSNumber* persistent;

@property (nullable, nonatomic, retain) NSString* scheduleType;

@property (nullable, nonatomic, retain) NSDate* startsOn;

@property (nullable, nonatomic, retain) NSArray* times;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *activities;

- (void)addActivitiesObject:(NSManagedObject *)value;
- (void)removeActivitiesObject:(NSManagedObject *)value;
- (void)addActivities:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeActivities:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inActivitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromActivitiesAtIndex:(NSUInteger)idx;
- (void)insertActivities:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeActivitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInActivitiesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceActivitiesAtIndexes:(NSIndexSet *)indexes withActivities:(NSArray<NSManagedObject *> *)values;

@end

@implementation _SBBSchedule

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)persistentValue
{
	return [self.persistent boolValue];
}

- (void)setPersistentValue:(BOOL)value_
{
	self.persistent = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.cronTrigger = [dictionary objectForKey:@"cronTrigger"];

    self.delay = [dictionary objectForKey:@"delay"];

    self.endsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"endsOn"]];

    self.eventId = [dictionary objectForKey:@"eventId"];

    self.expires = [dictionary objectForKey:@"expires"];

    self.interval = [dictionary objectForKey:@"interval"];

    self.label = [dictionary objectForKey:@"label"];

    self.persistent = [dictionary objectForKey:@"persistent"];

    self.scheduleType = [dictionary objectForKey:@"scheduleType"];

    self.startsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startsOn"]];

    self.times = [dictionary objectForKey:@"times"];

    // overwrite the old activities relationship entirely rather than adding to it
    [self removeActivitiesObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"activities"])
    {
        SBBActivity *activitiesObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addActivitiesObject:activitiesObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.cronTrigger forKey:@"cronTrigger"];

    [dict setObjectIfNotNil:self.delay forKey:@"delay"];

    [dict setObjectIfNotNil:[self.endsOn ISO8601String] forKey:@"endsOn"];

    [dict setObjectIfNotNil:self.eventId forKey:@"eventId"];

    [dict setObjectIfNotNil:self.expires forKey:@"expires"];

    [dict setObjectIfNotNil:self.interval forKey:@"interval"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.persistent forKey:@"persistent"];

    [dict setObjectIfNotNil:self.scheduleType forKey:@"scheduleType"];

    [dict setObjectIfNotNil:[self.startsOn ISO8601String] forKey:@"startsOn"];

    [dict setObjectIfNotNil:self.times forKey:@"times"];

    if ([self.activities count] > 0)
	{

		NSMutableArray *activitiesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.activities count]];

		for (SBBActivity *obj in self.activities)
        {
            [activitiesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:activitiesRepresentationsForDictionary forKey:@"activities"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBActivity *activitiesObj in self.activities)
	{
		[activitiesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"Schedule";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.cronTrigger = managedObject.cronTrigger;

        self.delay = managedObject.delay;

        self.endsOn = managedObject.endsOn;

        self.eventId = managedObject.eventId;

        self.expires = managedObject.expires;

        self.interval = managedObject.interval;

        self.label = managedObject.label;

        self.persistent = managedObject.persistent;

        self.scheduleType = managedObject.scheduleType;

        self.startsOn = managedObject.startsOn;

        self.times = managedObject.times;

		for (NSManagedObject *activitiesManagedObj in managedObject.activities)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:activitiesManagedObj.entity.name];
            SBBActivity *activitiesObj = [[objectClass alloc] initWithManagedObject:activitiesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (activitiesObj != nil)
            {
                [self addActivitiesObject:activitiesObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Schedule" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [cacheManager cachedObjectForBridgeObject:self inContext:cacheContext];
    if (managedObject) {
        [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    }

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.cronTrigger = ((id)self.cronTrigger == [NSNull null]) ? nil : self.cronTrigger;

    managedObject.delay = ((id)self.delay == [NSNull null]) ? nil : self.delay;

    managedObject.endsOn = ((id)self.endsOn == [NSNull null]) ? nil : self.endsOn;

    managedObject.eventId = ((id)self.eventId == [NSNull null]) ? nil : self.eventId;

    managedObject.expires = ((id)self.expires == [NSNull null]) ? nil : self.expires;

    managedObject.interval = ((id)self.interval == [NSNull null]) ? nil : self.interval;

    managedObject.label = ((id)self.label == [NSNull null]) ? nil : self.label;

    managedObject.persistent = ((id)self.persistent == [NSNull null]) ? nil : self.persistent;

    managedObject.scheduleType = ((id)self.scheduleType == [NSNull null]) ? nil : self.scheduleType;

    managedObject.startsOn = ((id)self.startsOn == [NSNull null]) ? nil : self.startsOn;

    managedObject.times = ((id)self.times == [NSNull null]) ? nil : self.times;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSOrderedSet *activitiesCopy = [managedObject.activities copy];

    // now remove all items from the existing relationship
    // to work pre-iOS 10, we have to work around this issue: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    NSMutableOrderedSet *workingActivitiesSet = [managedObject mutableOrderedSetValueForKey:NSStringFromSelector(@selector(activities))];
    [workingActivitiesSet removeAllObjects];

    // now put the "new" items, if any, into the relationship
    if ([self.activities count] > 0) {
		for (SBBActivity *obj in self.activities) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [workingActivitiesSet addObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in activitiesCopy) {
        if (![relMo valueForKey:@"schedule"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    activitiesCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addActivitiesObject:(SBBActivity*)value_ settingInverse: (BOOL) setInverse
{
    if (self.activities == nil)
	{

		self.activities = [NSMutableArray array];

	}

	[(NSMutableArray *)self.activities addObject:value_];

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

}

- (void)removeActivitiesAtIndexes:(NSIndexSet *)indexes {
    [self removeActivitiesAtIndexes:indexes settingInverse:YES];
}

- (void)removeActivitiesAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.activities removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInActivitiesAtIndex:(NSUInteger)idx withObject:(SBBActivity*)value {
    [self replaceObjectInActivitiesAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInActivitiesAtIndex:(NSUInteger)idx withObject:(SBBActivity*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.activities replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceActivitiesAtIndexes:(NSIndexSet *)indexes withActivities:(NSArray *)value {
    [self replaceActivitiesAtIndexes:indexes withActivities:value settingInverse:YES];
}

- (void)replaceActivitiesAtIndexes:(NSIndexSet *)indexes withActivities:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.activities replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
