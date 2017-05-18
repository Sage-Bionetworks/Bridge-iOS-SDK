//
//  _SBBScheduledActivity.m
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
// Make changes to SBBScheduledActivity.m instead.
//

#import "_SBBScheduledActivity.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBActivity.h"

@interface _SBBScheduledActivity()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (ScheduledActivity)

@property (nullable, nonatomic, retain) id<SBBJSONValue> clientData;

@property (nullable, nonatomic, retain) NSDate* expiresOn;

@property (nullable, nonatomic, retain) NSDate* finishedOn;

@property (nullable, nonatomic, retain) NSString* guid;

@property (nullable, nonatomic, retain) NSNumber* persistent;

@property (nullable, nonatomic, retain) NSDate* scheduledOn;

@property (nullable, nonatomic, retain) NSDate* startedOn;

@property (nullable, nonatomic, retain) NSManagedObject *activity;

@end

@implementation _SBBScheduledActivity

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

    self.clientData = [dictionary objectForKey:@"clientData"];

    self.expiresOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"expiresOn"]];

    self.finishedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"finishedOn"]];

    self.guid = [dictionary objectForKey:@"guid"];

    self.persistent = [dictionary objectForKey:@"persistent"];

    self.scheduledOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"scheduledOn"]];

    self.startedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startedOn"]];

    NSDictionary *activityDict = [dictionary objectForKey:@"activity"];

    if (activityDict != nil)
    {
        SBBActivity *activityObj = [objectManager objectFromBridgeJSON:activityDict];
        self.activity = activityObj;
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.clientData forKey:@"clientData"];

    [dict setObjectIfNotNil:[self.expiresOn ISO8601String] forKey:@"expiresOn"];

    [dict setObjectIfNotNil:[self.finishedOn ISO8601String] forKey:@"finishedOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.persistent forKey:@"persistent"];

    [dict setObjectIfNotNil:[self.scheduledOn ISO8601String] forKey:@"scheduledOn"];

    [dict setObjectIfNotNil:[self.startedOn ISO8601String] forKey:@"startedOn"];

    [dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.activity] forKey:@"activity"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.activity awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"ScheduledActivity";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.clientData = managedObject.clientData;

        self.expiresOn = managedObject.expiresOn;

        self.finishedOn = managedObject.finishedOn;

        self.guid = managedObject.guid;

        self.persistent = managedObject.persistent;

        self.scheduledOn = managedObject.scheduledOn;

        self.startedOn = managedObject.startedOn;

            NSManagedObject *activityManagedObj = managedObject.activity;
        Class activityClass = [SBBObjectManager bridgeClassFromType:activityManagedObj.entity.name];
        SBBActivity *activityObj = [[activityClass alloc] initWithManagedObject:activityManagedObj objectManager:objectManager cacheManager:cacheManager];
        if (activityObj != nil)
        {
          self.activity = activityObj;
        }
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ScheduledActivity" inManagedObjectContext:cacheContext];
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

    managedObject.clientData = ((id)self.clientData == [NSNull null]) ? nil : self.clientData;

    managedObject.expiresOn = ((id)self.expiresOn == [NSNull null]) ? nil : self.expiresOn;

    managedObject.finishedOn = ((id)self.finishedOn == [NSNull null]) ? nil : self.finishedOn;

    managedObject.guid = ((id)self.guid == [NSNull null]) ? nil : self.guid;

    managedObject.persistent = ((id)self.persistent == [NSNull null]) ? nil : self.persistent;

    managedObject.scheduledOn = ((id)self.scheduledOn == [NSNull null]) ? nil : self.scheduledOn;

    managedObject.startedOn = ((id)self.startedOn == [NSNull null]) ? nil : self.startedOn;

    // destination entity Activity is not directly cacheable, so delete it and create the replacement
    if (managedObject.activity) {
        [cacheContext deleteObject:managedObject.activity];
    }
    NSManagedObject *relMoActivity = [self.activity createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];

    [managedObject setActivity:relMoActivity];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void) setActivity: (SBBActivity*) activity_ settingInverse: (BOOL) setInverse
{

    _activity = activity_;

}

- (void) setActivity: (SBBActivity*) activity_
{
    [self setActivity: activity_ settingInverse: YES];
}

- (SBBActivity*) activity
{
    return _activity;
}

@synthesize activity = _activity;

@end
