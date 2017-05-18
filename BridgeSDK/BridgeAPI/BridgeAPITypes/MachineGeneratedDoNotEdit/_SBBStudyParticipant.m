//
//  _SBBStudyParticipant.m
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
// Make changes to SBBStudyParticipant.m instead.
//

#import "_SBBStudyParticipant.h"
#import "_SBBStudyParticipantInternal.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "RNEncryptor.h"
#import "RNDecryptor.h"

@interface _SBBStudyParticipant()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (StudyParticipant)

@property (nullable, nonatomic, retain) SBBStudyParticipantCustomAttributes* attributes;

@property (nullable, nonatomic, retain) NSData* ciphertext;

@property (nullable, nonatomic, retain) NSDate* createdOn;

@property (nullable, nonatomic, retain) NSSet<NSString *>* dataGroups;

@property (nullable, nonatomic, retain) NSString* email;

@property (nullable, nonatomic, retain) NSString* externalId;

@property (nullable, nonatomic, retain) NSString* firstName;

@property (nullable, nonatomic, retain) NSString* id;

@property (nullable, nonatomic, retain) NSArray<NSString *>* languages;

@property (nullable, nonatomic, retain) NSString* lastName;

@property (nullable, nonatomic, retain) NSNumber* notifyByEmail;

@property (nullable, nonatomic, retain) NSArray<NSString *>* roles;

@property (nullable, nonatomic, retain) NSString* sharingScope;

@property (nullable, nonatomic, retain) NSString* status;

@property (nullable, nonatomic, retain) NSManagedObject *userSessionInfo;

@end

@implementation _SBBStudyParticipant

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)notifyByEmailValue
{
	return [self.notifyByEmail boolValue];
}

- (void)setNotifyByEmailValue:(BOOL)value_
{
	self.notifyByEmail = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    if ([SBBStudyParticipantCustomAttributes instancesRespondToSelector:@selector(initWithDictionaryRepresentation:)]) {
        self.attributes = [[SBBStudyParticipantCustomAttributes alloc] initWithDictionaryRepresentation:[dictionary objectForKey:@"attributes"]];
    }

    self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

    self.dataGroups = [NSSet setWithArray:[dictionary objectForKey:@"dataGroups"]];

    self.email = [dictionary objectForKey:@"email"];

    self.externalId = [dictionary objectForKey:@"externalId"];

    self.firstName = [dictionary objectForKey:@"firstName"];

    self.id = [dictionary objectForKey:@"id"];

    self.languages = [dictionary objectForKey:@"languages"];

    self.lastName = [dictionary objectForKey:@"lastName"];

    self.notifyByEmail = [dictionary objectForKey:@"notifyByEmail"];

    self.roles = [dictionary objectForKey:@"roles"];

    self.sharingScope = [dictionary objectForKey:@"sharingScope"];

    self.status = [dictionary objectForKey:@"status"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    if ([SBBStudyParticipantCustomAttributes instancesRespondToSelector:@selector(dictionaryRepresentation)]) {
        [dict setObjectIfNotNil:[self.attributes dictionaryRepresentation] forKey:@"attributes"];
    }

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES];
    [dict setObjectIfNotNil:[self.dataGroups sortedArrayUsingDescriptors:@[desc]] forKey:@"dataGroups"];

    [dict setObjectIfNotNil:self.email forKey:@"email"];

    [dict setObjectIfNotNil:self.externalId forKey:@"externalId"];

    [dict setObjectIfNotNil:self.firstName forKey:@"firstName"];

    [dict setObjectIfNotNil:self.id forKey:@"id"];

    [dict setObjectIfNotNil:self.languages forKey:@"languages"];

    [dict setObjectIfNotNil:self.lastName forKey:@"lastName"];

    [dict setObjectIfNotNil:self.notifyByEmail forKey:@"notifyByEmail"];

    [dict setObjectIfNotNil:self.roles forKey:@"roles"];

    [dict setObjectIfNotNil:self.sharingScope forKey:@"sharingScope"];

    [dict setObjectIfNotNil:self.status forKey:@"status"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"StudyParticipant";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    NSString *password = cacheManager.encryptionKey;
    if (password) {
        NSData *plaintext = [RNDecryptor decryptData:managedObject.ciphertext withPassword:password error:nil];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:plaintext options:0 error:NULL];
        self = [self initWithDictionaryRepresentation:jsonDict objectManager:objectManager];
    } else {
        self = nil;
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"StudyParticipant" inManagedObjectContext:cacheContext];
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
    NSDictionary *jsonDict = [objectManager bridgeJSONFromObject:self];
    NSError *error;
    NSData *plaintext = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *password = cacheManager.encryptionKey;
    if (password && !error) {
        NSData *ciphertext = [RNEncryptor encryptData:plaintext withSettings:kRNCryptorAES256Settings password:password error:&error];
        if (!error) {
            managedObject.ciphertext = ciphertext;
        }
    }

    // fill in the key used for caching this object type so we can still use the usual
    // fetch requests with predicates to find it in CoreData in spite of being encrypted.
    id keyValue = ((id)self.type == [NSNull null]) ? nil : self.type;
    [managedObject setValue:keyValue forKey:@"type"];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
