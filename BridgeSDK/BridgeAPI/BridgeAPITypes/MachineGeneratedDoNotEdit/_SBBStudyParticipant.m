//
//  _SBBStudyParticipant.m
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

@property (nullable, nonatomic, retain) NSData* ciphertext;

@property (nullable, nonatomic, retain) NSString* healthCode;

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

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    _healthCode = [dictionary objectForKey:@"healthCode"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.healthCode forKey:@"healthCode"];

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
        NSError *error = nil;
        NSData *plaintext = [RNDecryptor decryptData:managedObject.ciphertext withPassword:password error:&error];
        if (error || !plaintext) {
#if DEBUG
            NSLog(@"Error decrypting %@ with password '%@': %@", self.class.entityName, password, error);
#endif
            self = nil;
        } else {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:plaintext options:0 error:NULL];
            self = [self initWithDictionaryRepresentation:jsonDict objectManager:objectManager];
        }
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
    managedObject.ciphertext = nil; // clear it in case there's an error serializing or encrypting jsonDict
    NSError *error;
    NSData *plaintext = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *password = cacheManager.encryptionKey;
    if (error) {
        NSLog(@"Error serializing jsonDict to NSData for %@ in cache: %@\njsonDict: %@", [self.class entityName], error, jsonDict);
    }
    if (password && !error) {
        NSData *ciphertext = [RNEncryptor encryptData:plaintext withSettings:kRNCryptorAES256Settings password:password error:&error];
        if (error) {
            NSLog(@"Error encrypting %@ for cache: %@", [self.class entityName], error);
        } else {
            // jsonDict was successfully serialized and encrypted, so now we can set it
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
