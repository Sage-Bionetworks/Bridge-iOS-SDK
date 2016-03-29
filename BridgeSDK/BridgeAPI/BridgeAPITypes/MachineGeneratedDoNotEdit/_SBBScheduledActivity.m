//
//  SBBScheduledActivity.m
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
// Make changes to SBBScheduledActivity.h instead.
//

#import "_SBBScheduledActivity.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBActivity.h"

@interface _SBBScheduledActivity()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (ScheduledActivity)

@property (nonatomic, strong) NSDate* expiresOn;

@property (nonatomic, strong) NSDate* finishedOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSNumber* persistent;

@property (nonatomic, assign) BOOL persistentValue;

@property (nonatomic, strong) NSDate* scheduledOn;

@property (nonatomic, strong) NSDate* startedOn;

@property (nonatomic, strong) NSString* status;

@property (nonatomic, strong, readwrite) NSManagedObject *activity;

- (void) setActivity: (NSManagedObject *) activity_ settingInverse: (BOOL) setInverse;

@end

@implementation _SBBScheduledActivity

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

    self.expiresOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"expiresOn"]];

    self.finishedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"finishedOn"]];

    self.guid = [dictionary objectForKey:@"guid"];

    self.persistent = [dictionary objectForKey:@"persistent"];

    self.scheduledOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"scheduledOn"]];

    self.startedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startedOn"]];

    self.status = [dictionary objectForKey:@"status"];

        NSDictionary *activityDict = [dictionary objectForKey:@"activity"];
    if(activityDict != nil)
    {
        SBBActivity *activityObj = [objectManager objectFromBridgeJSON:activityDict];
        self.activity = activityObj;

    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:[self.expiresOn ISO8601String] forKey:@"expiresOn"];

    [dict setObjectIfNotNil:[self.finishedOn ISO8601String] forKey:@"finishedOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.persistent forKey:@"persistent"];

    [dict setObjectIfNotNil:[self.scheduledOn ISO8601String] forKey:@"scheduledOn"];

    [dict setObjectIfNotNil:[self.startedOn ISO8601String] forKey:@"startedOn"];

    [dict setObjectIfNotNil:self.status forKey:@"status"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.activity] forKey:@"activity"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.activity awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"ScheduledActivity" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.expiresOn = managedObject.expiresOn;

        self.finishedOn = managedObject.finishedOn;

        self.guid = managedObject.guid;

        self.persistent = managedObject.persistent;

        self.scheduledOn = managedObject.scheduledOn;

        self.startedOn = managedObject.startedOn;

        self.status = managedObject.status;

            NSManagedObject *activityManagedObj = managedObject.activity;
        SBBActivity *activityObj = [[SBBActivity alloc] initWithManagedObject:activityManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(activityObj != nil)
        {
          self.activity = activityObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ScheduledActivity" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.expiresOn = self.expiresOn;

    managedObject.finishedOn = self.finishedOn;

    managedObject.guid = self.guid;

    managedObject.persistent = self.persistent;

    managedObject.scheduledOn = self.scheduledOn;

    managedObject.startedOn = self.startedOn;

    managedObject.status = self.status;

    [cacheContext deleteObject:managedObject.activity];
    NSManagedObject *relMoActivity = [self.activity saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
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
