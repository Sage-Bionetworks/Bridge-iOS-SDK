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

@property (nonatomic, strong) NSNumber* authenticated;

@property (nonatomic, assign) BOOL authenticatedValue;

@property (nonatomic, strong) NSNumber* consented;

@property (nonatomic, assign) BOOL consentedValue;

@property (nonatomic, strong) NSArray<NSString *>* dataGroups;

@property (nonatomic, strong) NSNumber* dataSharing;

@property (nonatomic, assign) BOOL dataSharingValue;

@property (nonatomic, strong) NSString* environment;

@property (nonatomic, strong) NSArray<NSString *>* roles;

@property (nonatomic, strong) NSString* sessionToken;

@property (nonatomic, strong) NSString* sharingScope;

@property (nonatomic, strong) NSNumber* signedMostRecentConsent;

@property (nonatomic, assign) BOOL signedMostRecentConsentValue;

@property (nonatomic, strong) NSString* username;

@property (nonatomic, strong, readonly) NSArray *consentStatuses;

- (void)addConsentStatusesObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addConsentStatusesObject:(NSManagedObject *)value_;
- (void)removeConsentStatusesObjects;
- (void)removeConsentStatusesObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeConsentStatusesObject:(NSManagedObject *)value_;

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

    for(id objectRepresentationForDict in [dictionary objectForKey:@"consentStatuses"])
    {
        SBBConsentStatus *consentStatusesObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addConsentStatusesObject:consentStatusesObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

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

	return dict;
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

    if (self == [super init]) {

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
            SBBConsentStatus *consentStatusesObj = [[SBBConsentStatus alloc] initWithManagedObject:consentStatusesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(consentStatusesObj != nil)
            {
                [self addConsentStatusesObject:consentStatusesObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UserSessionInfo" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.authenticated = self.authenticated;

    managedObject.consented = self.consented;

    managedObject.dataGroups = self.dataGroups;

    managedObject.dataSharing = self.dataSharing;

    managedObject.environment = self.environment;

    managedObject.roles = self.roles;

    managedObject.sessionToken = self.sessionToken;

    managedObject.sharingScope = self.sharingScope;

    managedObject.signedMostRecentConsent = self.signedMostRecentConsent;

    managedObject.username = self.username;

    if([self.consentStatuses count] > 0) {
        for (SBBConsentStatus *obj in self.consentStatuses) {
            // see if a managed object for obj is already in the relationship
            BOOL alreadyInRelationship = NO;
            __block NSManagedObject *relMo = nil;
            NSString *keyPath = @"subpopulationGuid";
            NSString *objectId = obj.subpopulationGuid;
            while ([objectId isKindOfClass:[NSArray class]]) {
                objectId = ((NSArray *)objectId).firstObject;
            }

            for (NSManagedObject *mo in managedObject.consentStatuses) {
                if ([[mo valueForKeyPath:keyPath] isEqualToString:objectId]) {
                    relMo = mo;
                    alreadyInRelationship = YES;
                    break;
                }
            }

            // if not, check if one exists but just isn't in the relationship yet
            if (!relMo) {
                NSEntityDescription *relEntity = [NSEntityDescription entityForName:@"ConsentStatus" inManagedObjectContext:cacheContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                [request setEntity:relEntity];

                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ LIKE %@", keyPath, objectId];
                [request setPredicate:predicate];

                NSError *error;
                NSArray *objects = [cacheContext executeFetchRequest:request error:&error];
                if (objects.count) {
                    relMo = [objects firstObject];
                }
            }

            // if still not, create one
            if (!relMo) {
                relMo = [NSEntityDescription insertNewObjectForEntityForName:@"ConsentStatus" inManagedObjectContext:cacheContext];
            }

            // update it from obj
            [obj updateManagedObject:relMo withObjectManager:objectManager cacheManager:cacheManager];

            // add to relationship if not already in it
            if (!alreadyInRelationship) {
                [managedObject addConsentStatusesObject:relMo];
            }
        }
	}

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: (BOOL) setInverse
{
    if(self.consentStatuses == nil)
	{

		self.consentStatuses = [NSMutableArray array];

	}

	[(NSMutableArray *)self.consentStatuses addObject:value_];

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
