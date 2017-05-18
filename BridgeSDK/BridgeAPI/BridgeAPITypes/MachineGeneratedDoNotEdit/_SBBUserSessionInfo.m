//
//  _SBBUserSessionInfo.m
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
// Make changes to SBBUserSessionInfo.m instead.
//

#import "_SBBUserSessionInfo.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBConsentStatus.h"
#import "SBBStudyParticipant.h"

@interface _SBBUserSessionInfo()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSDictionary *consentStatuses;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (UserSessionInfo)

@property (nullable, nonatomic, retain) NSNumber* authenticated;

@property (nullable, nonatomic, retain) NSNumber* consented;

@property (nullable, nonatomic, retain) NSNumber* dataSharing;

@property (nullable, nonatomic, retain) NSString* environment;

@property (nullable, nonatomic, retain) NSString* sessionToken;

@property (nullable, nonatomic, retain) NSNumber* signedMostRecentConsent;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *consentStatuses;

@property (nullable, nonatomic, retain) NSManagedObject *studyParticipant;

- (void)addConsentStatusesObject:(NSManagedObject *)value;
- (void)removeConsentStatusesObject:(NSManagedObject *)value;

- (void)addConsentStatuses:(NSSet<NSManagedObject *> *)values;
- (void)removeConsentStatuses:(NSSet<NSManagedObject *> *)values;

@end

@implementation _SBBUserSessionInfo

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)authenticatedValue
{
	return [self.authenticated boolValue];
}

- (void)setAuthenticatedValue:(BOOL)value_
{
	self.authenticated = [NSNumber numberWithBool:value_];
}

- (BOOL)consentedValue
{
	return [self.consented boolValue];
}

- (void)setConsentedValue:(BOOL)value_
{
	self.consented = [NSNumber numberWithBool:value_];
}

- (BOOL)dataSharingValue
{
	return [self.dataSharing boolValue];
}

- (void)setDataSharingValue:(BOOL)value_
{
	self.dataSharing = [NSNumber numberWithBool:value_];
}

- (BOOL)signedMostRecentConsentValue
{
	return [self.signedMostRecentConsent boolValue];
}

- (void)setSignedMostRecentConsentValue:(BOOL)value_
{
	self.signedMostRecentConsent = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (NSArray *)originalProperties
{
    static NSArray *props;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *localProps = [@[@"authenticated", @"consented", @"dataSharing", @"environment", @"sessionToken", @"signedMostRecentConsent", @"type", @"consentStatuses", @"studyParticipant", @"__end_of_properties__"] mutableCopy];
        [localProps removeLastObject];
        props = [localProps copy];
    });

    return props;
}

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.authenticated = [dictionary objectForKey:@"authenticated"];

    self.consented = [dictionary objectForKey:@"consented"];

    self.dataSharing = [dictionary objectForKey:@"dataSharing"];

    self.environment = [dictionary objectForKey:@"environment"];

    self.sessionToken = [dictionary objectForKey:@"sessionToken"];

    self.signedMostRecentConsent = [dictionary objectForKey:@"signedMostRecentConsent"];

    // If we're just creating a stub object to be populated later with actual JSON, don't try to create
    // any included subobjects at this point. We can tell because the dictionary will consist of only the
    // "type" key and nothing else.
    BOOL creatingObjectBeforePopulating = (dictionary.count == 1) && dictionary[@"type"] != nil;

    // overwrite the old consentStatuses relationship entirely rather than adding to it
    [self removeConsentStatusesObjects];

    NSDictionary *dictionaryJSON = [dictionary objectForKey:@"consentStatuses"];
    for (id dictRepresentationForObject in dictionaryJSON.allValues)
    {
        SBBConsentStatus *consentStatusesObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addConsentStatusesObject:consentStatusesObj];
    }

    NSMutableDictionary *studyParticipantDict = nil;
    if (!creatingObjectBeforePopulating) {
        // studyParticipant is included as a subobject, meaning its fields are mingled with ours in the Bridge JSON,
        // rather than being in their own JSON dictionary under the appropriate key. So we'll create the necessary
        // JSON dictionary by copying ours, removing our own fields, and setting the type appropriately.
        studyParticipantDict = [dictionary mutableCopy];
        NSArray *myProps = [self originalProperties];
        [studyParticipantDict removeObjectsForKeys:myProps];
        studyParticipantDict[@"type"] = @"StudyParticipant";
    }

    if (studyParticipantDict != nil)
    {
        SBBStudyParticipant *studyParticipantObj = [objectManager objectFromBridgeJSON:studyParticipantDict];
        self.studyParticipant = studyParticipantObj;
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.authenticated forKey:@"authenticated"];

    [dict setObjectIfNotNil:self.consented forKey:@"consented"];

    [dict setObjectIfNotNil:self.dataSharing forKey:@"dataSharing"];

    [dict setObjectIfNotNil:self.environment forKey:@"environment"];

    [dict setObjectIfNotNil:self.sessionToken forKey:@"sessionToken"];

    [dict setObjectIfNotNil:self.signedMostRecentConsent forKey:@"signedMostRecentConsent"];

    if ([self.consentStatuses count] > 0)
	{

        NSMutableDictionary *consentStatusesRepresentationsForDictionary = [NSMutableDictionary dictionaryWithCapacity:[self.consentStatuses count]];

		for (SBBConsentStatus *obj in self.consentStatuses.allValues)
        {
            [consentStatusesRepresentationsForDictionary setObject:[objectManager bridgeJSONFromObject:obj] forKey:[obj valueForKeyPath:@"subpopulationGuid"]];
		}
		[dict setObjectIfNotNil:consentStatusesRepresentationsForDictionary forKey:@"consentStatuses"];

	}

    // studyParticipant is included as a subobject, meaning its fields are mingled with ours in the Bridge JSON,
    // rather than being in their own JSON dictionary under the appropriate key. So we'll fetch the Bridge JSON for
    // the subobject, and then overwrite it with ours (that way the "type" key will be correct).
    NSMutableDictionary *studyParticipantJSON = [[objectManager bridgeJSONFromObject:self.studyParticipant] mutableCopy];
    [studyParticipantJSON addEntriesFromDictionary:dict];
    dict = studyParticipantJSON;

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBConsentStatus *consentStatusesObj in self.consentStatuses)
	{
		[consentStatusesObj awakeFromDictionaryRepresentationInit];
	}
	[self.studyParticipant awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"UserSessionInfo";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.authenticated = managedObject.authenticated;

        self.consented = managedObject.consented;

        self.dataSharing = managedObject.dataSharing;

        self.environment = managedObject.environment;

        self.sessionToken = managedObject.sessionToken;

        self.signedMostRecentConsent = managedObject.signedMostRecentConsent;

		for (NSManagedObject *consentStatusesManagedObj in managedObject.consentStatuses)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:consentStatusesManagedObj.entity.name];
            SBBConsentStatus *consentStatusesObj = [[objectClass alloc] initWithManagedObject:consentStatusesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (consentStatusesObj != nil)
            {
                [self addConsentStatusesObject:consentStatusesObj];
            }
		}
            NSManagedObject *studyParticipantManagedObj = managedObject.studyParticipant;
        Class studyParticipantClass = [SBBObjectManager bridgeClassFromType:studyParticipantManagedObj.entity.name];
        SBBStudyParticipant *studyParticipantObj = [[studyParticipantClass alloc] initWithManagedObject:studyParticipantManagedObj objectManager:objectManager cacheManager:cacheManager];
        if (studyParticipantObj != nil)
        {
          self.studyParticipant = studyParticipantObj;
        }
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UserSessionInfo" inManagedObjectContext:cacheContext];
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

    managedObject.authenticated = ((id)self.authenticated == [NSNull null]) ? nil : self.authenticated;

    managedObject.consented = ((id)self.consented == [NSNull null]) ? nil : self.consented;

    managedObject.dataSharing = ((id)self.dataSharing == [NSNull null]) ? nil : self.dataSharing;

    managedObject.environment = ((id)self.environment == [NSNull null]) ? nil : self.environment;

    managedObject.sessionToken = ((id)self.sessionToken == [NSNull null]) ? nil : self.sessionToken;

    managedObject.signedMostRecentConsent = ((id)self.signedMostRecentConsent == [NSNull null]) ? nil : self.signedMostRecentConsent;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSSet *consentStatusesCopy = [managedObject.consentStatuses copy];

    // now remove all items from the existing relationship
    [managedObject removeConsentStatuses:managedObject.consentStatuses];

    // now put the "new" items, if any, into the relationship
    if ([self.consentStatuses count] > 0) {
		for (SBBConsentStatus *obj in self.consentStatuses.allValues) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [managedObject addConsentStatusesObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in consentStatusesCopy) {
        if (![relMo valueForKey:@"userSessionInfo"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    consentStatusesCopy = nil;

    // destination entity StudyParticipant is directly cacheable, so get it from cache manager
    NSManagedObject *relMoStudyParticipant = [cacheManager cachedObjectForBridgeObject:self.studyParticipant inContext:cacheContext];

    [managedObject setStudyParticipant:relMoStudyParticipant];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: (BOOL) setInverse
{
    if (self.consentStatuses == nil)
	{

        self.consentStatuses = [NSMutableDictionary dictionary];

	}

    [(NSMutableDictionary *)self.consentStatuses setObject:value_ forKey:[value_ valueForKeyPath:@"subpopulationGuid"]];

}

- (void)addConsentStatusesObject:(SBBConsentStatus*)value_
{
    [self addConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: YES];
}

- (void)removeConsentStatusesObjects
{

    self.consentStatuses = [NSMutableDictionary dictionary];

}

- (void)removeConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableDictionary *)self.consentStatuses removeObjectForKey:[value_ valueForKeyPath:@"subpopulationGuid"]];

}

- (void)removeConsentStatusesObject:(SBBConsentStatus*)value_
{
    [self removeConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: YES];
}

- (void) setStudyParticipant: (SBBStudyParticipant*) studyParticipant_ settingInverse: (BOOL) setInverse
{

    _studyParticipant = studyParticipant_;

}

- (void) setStudyParticipant: (SBBStudyParticipant*) studyParticipant_
{
    [self setStudyParticipant: studyParticipant_ settingInverse: YES];
}

- (SBBStudyParticipant*) studyParticipant
{
    return _studyParticipant;
}

@synthesize studyParticipant = _studyParticipant;

@end
