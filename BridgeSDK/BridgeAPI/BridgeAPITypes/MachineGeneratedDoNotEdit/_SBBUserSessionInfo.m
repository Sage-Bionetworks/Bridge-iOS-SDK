//
//  SBBUserSessionInfo.m
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
// Make changes to SBBUserSessionInfo.h instead.
//

#import "_SBBUserSessionInfo.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBConsentStatus.h"

@interface _SBBUserSessionInfo()
@property (nonatomic, strong, readwrite) NSArray *consentStatuses;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (UserSessionInfo)

@property (nullable, nonatomic, retain) NSNumber* authenticated;

@property (nullable, nonatomic, retain) NSNumber* consented;

@property (nullable, nonatomic, retain) NSArray<NSString *>* dataGroups;

@property (nullable, nonatomic, retain) NSNumber* dataSharing;

@property (nullable, nonatomic, retain) NSString* environment;

@property (nullable, nonatomic, retain) NSArray<NSString *>* roles;

@property (nullable, nonatomic, retain) NSString* sessionToken;

@property (nullable, nonatomic, retain) NSString* sharingScope;

@property (nullable, nonatomic, retain) NSNumber* signedMostRecentConsent;

@property (nullable, nonatomic, retain) NSString* username;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *consentStatuses;

- (void)addConsentStatusesObject:(NSManagedObject *)value;
- (void)removeConsentStatusesObject:(NSManagedObject *)value;

- (void)addConsentStatuses:(NSSet<NSManagedObject *> *)values;
- (void)removeConsentStatuses:(NSSet<NSManagedObject *> *)values;

@end

@implementation _SBBUserSessionInfo

- (instancetype)init
{
	if((self = [super init]))
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

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.authenticated = [dictionary objectForKey:@"authenticated"];

    self.consented = [dictionary objectForKey:@"consented"];

    self.dataGroups = [dictionary objectForKey:@"dataGroups"];

    self.dataSharing = [dictionary objectForKey:@"dataSharing"];

    self.environment = [dictionary objectForKey:@"environment"];

    self.roles = [dictionary objectForKey:@"roles"];

    self.sessionToken = [dictionary objectForKey:@"sessionToken"];

    self.sharingScope = [dictionary objectForKey:@"sharingScope"];

    self.signedMostRecentConsent = [dictionary objectForKey:@"signedMostRecentConsent"];

    self.username = [dictionary objectForKey:@"username"];

    // overwrite the old consentStatuses relationship entirely rather than adding to it
    self.consentStatuses = [NSMutableArray array];

    for(id objectRepresentationForDict in [dictionary objectForKey:@"consentStatuses"])
    {
        SBBConsentStatus *consentStatusesObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addConsentStatusesObject:consentStatusesObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.authenticated forKey:@"authenticated"];

    [dict setObjectIfNotNil:self.consented forKey:@"consented"];

    [dict setObjectIfNotNil:self.dataGroups forKey:@"dataGroups"];

    [dict setObjectIfNotNil:self.dataSharing forKey:@"dataSharing"];

    [dict setObjectIfNotNil:self.environment forKey:@"environment"];

    [dict setObjectIfNotNil:self.roles forKey:@"roles"];

    [dict setObjectIfNotNil:self.sessionToken forKey:@"sessionToken"];

    [dict setObjectIfNotNil:self.sharingScope forKey:@"sharingScope"];

    [dict setObjectIfNotNil:self.signedMostRecentConsent forKey:@"signedMostRecentConsent"];

    [dict setObjectIfNotNil:self.username forKey:@"username"];

    if([self.consentStatuses count] > 0)
	{

		NSMutableArray *consentStatusesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.consentStatuses count]];
		for(SBBConsentStatus *obj in self.consentStatuses)
		{
			[consentStatusesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:consentStatusesRepresentationsForDictionary forKey:@"consentStatuses"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBConsentStatus *consentStatusesObj in self.consentStatuses)
	{
		[consentStatusesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"UserSessionInfo" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.authenticated = managedObject.authenticated;

        self.consented = managedObject.consented;

        self.dataGroups = managedObject.dataGroups;

        self.dataSharing = managedObject.dataSharing;

        self.environment = managedObject.environment;

        self.roles = managedObject.roles;

        self.sessionToken = managedObject.sessionToken;

        self.sharingScope = managedObject.sharingScope;

        self.signedMostRecentConsent = managedObject.signedMostRecentConsent;

        self.username = managedObject.username;

		for(NSManagedObject *consentStatusesManagedObj in managedObject.consentStatuses)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:consentStatusesManagedObj.entity.name];
            SBBConsentStatus *consentStatusesObj = [[objectClass alloc] initWithManagedObject:consentStatusesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(consentStatusesObj != nil)
            {
                [self addConsentStatusesObject:consentStatusesObj];
            }
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

    managedObject.dataGroups = ((id)self.dataGroups == [NSNull null]) ? nil : self.dataGroups;

    managedObject.dataSharing = ((id)self.dataSharing == [NSNull null]) ? nil : self.dataSharing;

    managedObject.environment = ((id)self.environment == [NSNull null]) ? nil : self.environment;

    managedObject.roles = ((id)self.roles == [NSNull null]) ? nil : self.roles;

    managedObject.sessionToken = ((id)self.sessionToken == [NSNull null]) ? nil : self.sessionToken;

    managedObject.sharingScope = ((id)self.sharingScope == [NSNull null]) ? nil : self.sharingScope;

    managedObject.signedMostRecentConsent = ((id)self.signedMostRecentConsent == [NSNull null]) ? nil : self.signedMostRecentConsent;

    managedObject.username = ((id)self.username == [NSNull null]) ? nil : self.username;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    id consentStatusesCopy = managedObject.consentStatuses;

    // now remove all items from the existing relationship
    NSMutableSet *consentStatusesSet = [managedObject.consentStatuses mutableCopy];
    [consentStatusesSet removeAllObjects];
    managedObject.consentStatuses = consentStatusesSet;

    // now put the "new" items, if any, into the relationship
    if([self.consentStatuses count] > 0) {
		for(SBBConsentStatus *obj in self.consentStatuses) {
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

    // now delete any objects that aren't still in the relationship
    for (NSManagedObject *relMo in consentStatusesCopy) {
        if (![relMo valueForKey:@"userSessionInfo"]) {
           [cacheContext deleteObject:relMo];
        }
    }

    // ...and let go of the collection copy
    consentStatusesCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: (BOOL) setInverse
{
    if(self.consentStatuses == nil)
	{

		self.consentStatuses = [NSMutableArray array];

	}

    // Consent status can be nil if user withdrew from study and tries to login again with that account
    if (value_ != nil) {
        [(NSMutableArray *)self.consentStatuses addObject:value_];
    }
}
- (void)addConsentStatusesObject:(SBBConsentStatus*)value_
{
    [self addConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: YES];
}

- (void)removeConsentStatusesObjects
{

	self.consentStatuses = [NSMutableArray array];

}

- (void)removeConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.consentStatuses removeObject:value_];
}

- (void)removeConsentStatusesObject:(SBBConsentStatus*)value_
{
    [self removeConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: YES];
}

@end
