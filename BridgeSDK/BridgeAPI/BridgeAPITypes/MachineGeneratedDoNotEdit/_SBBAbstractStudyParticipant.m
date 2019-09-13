//
//  _SBBAbstractStudyParticipant.m
//
//	Copyright (c) 2014-2018 Sage Bionetworks
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
// Make changes to SBBAbstractStudyParticipant.m instead.
//

#import "_SBBAbstractStudyParticipant.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBPhone.h"

@interface _SBBAbstractStudyParticipant()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (AbstractStudyParticipant)

@property (nullable, nonatomic, retain) SBBStudyParticipantCustomAttributes* attributes;

@property (nullable, nonatomic, retain) id<SBBJSONValue> clientData;

@property (nullable, nonatomic, retain) NSDate* createdOn;

@property (nullable, nonatomic, retain) NSSet<NSString *>* dataGroups;

@property (nullable, nonatomic, retain) NSString* email;

@property (nullable, nonatomic, retain) NSNumber* emailVerified;

@property (nullable, nonatomic, retain) NSString* externalId;

@property (nullable, nonatomic, retain) NSDictionary<NSString *, NSString *>* externalIds;

@property (nullable, nonatomic, retain) NSString* firstName;

@property (nullable, nonatomic, retain) NSString* id;

@property (nullable, nonatomic, retain) NSArray<NSString *>* languages;

@property (nullable, nonatomic, retain) NSString* lastName;

@property (nullable, nonatomic, retain) NSNumber* notifyByEmail;

@property (nullable, nonatomic, retain) NSNumber* phoneVerified;

@property (nullable, nonatomic, retain) NSArray<NSString *>* roles;

@property (nullable, nonatomic, retain) NSString* sharingScope;

@property (nullable, nonatomic, retain) NSString* status;

@property (nullable, nonatomic, retain) NSArray<NSString *>* substudyIds;

@property (nullable, nonatomic, retain) NSManagedObject *phone;

@end

@implementation _SBBAbstractStudyParticipant

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)emailVerifiedValue
{
	return [self.emailVerified boolValue];
}

- (void)setEmailVerifiedValue:(BOOL)value_
{
	self.emailVerified = [NSNumber numberWithBool:value_];
}

- (BOOL)notifyByEmailValue
{
	return [self.notifyByEmail boolValue];
}

- (void)setNotifyByEmailValue:(BOOL)value_
{
	self.notifyByEmail = [NSNumber numberWithBool:value_];
}

- (BOOL)phoneVerifiedValue
{
	return [self.phoneVerified boolValue];
}

- (void)setPhoneVerifiedValue:(BOOL)value_
{
	self.phoneVerified = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    if ([SBBStudyParticipantCustomAttributes instancesRespondToSelector:@selector(initWithDictionaryRepresentation:)]) {
        self.attributes = [[SBBStudyParticipantCustomAttributes alloc] initWithDictionaryRepresentation:[dictionary objectForKey:@"attributes"]];
    }

    self.clientData = [dictionary objectForKey:@"clientData"];

    _createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

    self.dataGroups = [NSSet setWithArray:[dictionary objectForKey:@"dataGroups"]];

    self.email = [dictionary objectForKey:@"email"];

    self.emailVerified = [dictionary objectForKey:@"emailVerified"];

    self.externalId = [dictionary objectForKey:@"externalId"];

    _externalIds = [dictionary objectForKey:@"externalIds"];

    self.firstName = [dictionary objectForKey:@"firstName"];

    _id = [dictionary objectForKey:@"id"];

    self.languages = [dictionary objectForKey:@"languages"];

    self.lastName = [dictionary objectForKey:@"lastName"];

    self.notifyByEmail = [dictionary objectForKey:@"notifyByEmail"];

    self.phoneVerified = [dictionary objectForKey:@"phoneVerified"];

    self.roles = [dictionary objectForKey:@"roles"];

    self.sharingScope = [dictionary objectForKey:@"sharingScope"];

    self.status = [dictionary objectForKey:@"status"];

    self.substudyIds = [dictionary objectForKey:@"substudyIds"];

    NSDictionary *phoneDict = [dictionary objectForKey:@"phone"];

    if (phoneDict != nil)
    {
        SBBPhone *phoneObj = [objectManager objectFromBridgeJSON:phoneDict];
        self.phone = phoneObj;
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    if ([SBBStudyParticipantCustomAttributes instancesRespondToSelector:@selector(dictionaryRepresentation)]) {
        [dict setObjectIfNotNil:[self.attributes dictionaryRepresentation] forKey:@"attributes"];
    }

    [dict setObjectIfNotNil:self.clientData forKey:@"clientData"];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES];
    [dict setObjectIfNotNil:[self.dataGroups sortedArrayUsingDescriptors:@[desc]] forKey:@"dataGroups"];

    [dict setObjectIfNotNil:self.email forKey:@"email"];

    [dict setObjectIfNotNil:self.emailVerified forKey:@"emailVerified"];

    [dict setObjectIfNotNil:self.externalId forKey:@"externalId"];

    [dict setObjectIfNotNil:self.externalIds forKey:@"externalIds"];

    [dict setObjectIfNotNil:self.firstName forKey:@"firstName"];

    [dict setObjectIfNotNil:self.id forKey:@"id"];

    [dict setObjectIfNotNil:self.languages forKey:@"languages"];

    [dict setObjectIfNotNil:self.lastName forKey:@"lastName"];

    [dict setObjectIfNotNil:self.notifyByEmail forKey:@"notifyByEmail"];

    [dict setObjectIfNotNil:self.phoneVerified forKey:@"phoneVerified"];

    [dict setObjectIfNotNil:self.roles forKey:@"roles"];

    [dict setObjectIfNotNil:self.sharingScope forKey:@"sharingScope"];

    [dict setObjectIfNotNil:self.status forKey:@"status"];

    [dict setObjectIfNotNil:self.substudyIds forKey:@"substudyIds"];

    [dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.phone] forKey:@"phone"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.phone awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"AbstractStudyParticipant";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.attributes = managedObject.attributes;

        self.clientData = managedObject.clientData;

        _createdOn = managedObject.createdOn;

        self.dataGroups = managedObject.dataGroups;

        self.email = managedObject.email;

        self.emailVerified = managedObject.emailVerified;

        self.externalId = managedObject.externalId;

        _externalIds = managedObject.externalIds;

        self.firstName = managedObject.firstName;

        _id = managedObject.id;

        self.languages = managedObject.languages;

        self.lastName = managedObject.lastName;

        self.notifyByEmail = managedObject.notifyByEmail;

        self.phoneVerified = managedObject.phoneVerified;

        self.roles = managedObject.roles;

        self.sharingScope = managedObject.sharingScope;

        self.status = managedObject.status;

        self.substudyIds = managedObject.substudyIds;

            NSManagedObject *phoneManagedObj = managedObject.phone;
        Class phoneClass = [SBBObjectManager bridgeClassFromType:phoneManagedObj.entity.name];
        SBBPhone *phoneObj = [[phoneClass alloc] initWithManagedObject:phoneManagedObj objectManager:objectManager cacheManager:cacheManager];
        if (phoneObj != nil)
        {
          self.phone = phoneObj;
        }
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"AbstractStudyParticipant" inManagedObjectContext:cacheContext];
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

    managedObject.attributes = ((id)self.attributes == [NSNull null]) ? nil : self.attributes;

    managedObject.clientData = ((id)self.clientData == [NSNull null]) ? nil : self.clientData;

    managedObject.createdOn = ((id)self.createdOn == [NSNull null]) ? nil : self.createdOn;

    managedObject.dataGroups = ((id)self.dataGroups == [NSNull null]) ? nil : self.dataGroups;

    managedObject.email = ((id)self.email == [NSNull null]) ? nil : self.email;

    managedObject.emailVerified = ((id)self.emailVerified == [NSNull null]) ? nil : self.emailVerified;

    managedObject.externalId = ((id)self.externalId == [NSNull null]) ? nil : self.externalId;

    managedObject.externalIds = ((id)self.externalIds == [NSNull null]) ? nil : self.externalIds;

    managedObject.firstName = ((id)self.firstName == [NSNull null]) ? nil : self.firstName;

    managedObject.id = ((id)self.id == [NSNull null]) ? nil : self.id;

    managedObject.languages = ((id)self.languages == [NSNull null]) ? nil : self.languages;

    managedObject.lastName = ((id)self.lastName == [NSNull null]) ? nil : self.lastName;

    managedObject.notifyByEmail = ((id)self.notifyByEmail == [NSNull null]) ? nil : self.notifyByEmail;

    managedObject.phoneVerified = ((id)self.phoneVerified == [NSNull null]) ? nil : self.phoneVerified;

    managedObject.roles = ((id)self.roles == [NSNull null]) ? nil : self.roles;

    managedObject.sharingScope = ((id)self.sharingScope == [NSNull null]) ? nil : self.sharingScope;

    managedObject.status = ((id)self.status == [NSNull null]) ? nil : self.status;

    managedObject.substudyIds = ((id)self.substudyIds == [NSNull null]) ? nil : self.substudyIds;

    // destination entity Phone is not directly cacheable, so delete it and create the replacement
    if (managedObject.phone) {
        [cacheContext deleteObject:managedObject.phone];
    }
    NSManagedObject *relMoPhone = [self.phone createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];

    [managedObject setPhone:relMoPhone];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void) setPhone: (SBBPhone*) phone_ settingInverse: (BOOL) setInverse
{

    _phone = phone_;

}

- (void) setPhone: (SBBPhone*) phone_
{
    [self setPhone: phone_ settingInverse: YES];
}

- (SBBPhone*) phone
{
    return _phone;
}

@synthesize phone = _phone;

@end
