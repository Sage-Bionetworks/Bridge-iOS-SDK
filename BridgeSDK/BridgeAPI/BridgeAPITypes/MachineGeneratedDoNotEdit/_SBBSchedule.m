//
//  SBBSchedule.m
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
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSchedule.h instead.
//

#import "_SBBSchedule.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBActivity.h"

@interface _SBBSchedule()
@property (nonatomic, strong, readwrite) NSArray *activities;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (Schedule)

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

- (void)addActivitiesObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addActivitiesObject:(NSManagedObject *)value_;
- (void)removeActivitiesObjects;
- (void)removeActivitiesObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeActivitiesObject:(NSManagedObject *)value_;

- (void)insertObject:(NSManagedObject *)value inActivitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromActivitiesAtIndex:(NSUInteger)idx;
- (void)insertActivities:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeActivitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInActivitiesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceActivitiesAtIndexes:(NSIndexSet *)indexes withActivities:(NSArray *)values;

@end

@implementation _SBBSchedule

- (instancetype)init
{
	if((self = [super init]))
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

    for(id objectRepresentationForDict in [dictionary objectForKey:@"activities"])
    {
        SBBActivity *activitiesObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addActivitiesObject:activitiesObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

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

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

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

		for(NSManagedObject *activitiesManagedObj in managedObject.activities)
		{
            SBBActivity *activitiesObj = [[SBBActivity alloc] initWithManagedObject:activitiesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(activitiesObj != nil)
            {
                [self addActivitiesObject:activitiesObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Schedule" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.cronTrigger = self.cronTrigger;

    managedObject.delay = self.delay;

    managedObject.endsOn = self.endsOn;

    managedObject.eventId = self.eventId;

    managedObject.expires = self.expires;

    managedObject.interval = self.interval;

    managedObject.label = self.label;

    managedObject.persistent = self.persistent;

    managedObject.scheduleType = self.scheduleType;

    managedObject.startsOn = self.startsOn;

    managedObject.times = self.times;

    if([self.activities count] > 0) {
        [managedObject removeActivitiesObjects];
		for(SBBActivity *obj in self.activities) {
            NSManagedObject *relMo = [obj saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            [managedObject addActivitiesObject:relMo];
		}
	}

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addActivitiesObject:(SBBActivity*)value_ settingInverse: (BOOL) setInverse
{
    if(self.activities == nil)
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
