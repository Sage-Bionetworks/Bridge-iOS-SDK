//
//  _SBBConsentStatus.m
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
// Make changes to SBBConsentStatus.m instead.
//

#import "_SBBConsentStatus.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBConsentStatus()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (ConsentStatus)

@property (nullable, nonatomic, retain) NSNumber* consented;

@property (nullable, nonatomic, retain) NSString* name;

@property (nullable, nonatomic, retain) NSNumber* required;

@property (nullable, nonatomic, retain) NSNumber* signedMostRecentConsent;

@property (nullable, nonatomic, retain) NSString* subpopulationGuid;

@property (nullable, nonatomic, retain) NSManagedObject *userSessionInfo;

@end

@implementation _SBBConsentStatus

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)consentedValue
{
	return [self.consented boolValue];
}

- (void)setConsentedValue:(BOOL)value_
{
	self.consented = [NSNumber numberWithBool:value_];
}

- (BOOL)requiredValue
{
	return [self.required boolValue];
}

- (void)setRequiredValue:(BOOL)value_
{
	self.required = [NSNumber numberWithBool:value_];
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

    self.consented = [dictionary objectForKey:@"consented"];

    self.name = [dictionary objectForKey:@"name"];

    self.required = [dictionary objectForKey:@"required"];

    self.signedMostRecentConsent = [dictionary objectForKey:@"signedMostRecentConsent"];

    self.subpopulationGuid = [dictionary objectForKey:@"subpopulationGuid"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.consented forKey:@"consented"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

    [dict setObjectIfNotNil:self.required forKey:@"required"];

    [dict setObjectIfNotNil:self.signedMostRecentConsent forKey:@"signedMostRecentConsent"];

    [dict setObjectIfNotNil:self.subpopulationGuid forKey:@"subpopulationGuid"];

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
    return @"ConsentStatus";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.consented = managedObject.consented;

        self.name = managedObject.name;

        self.required = managedObject.required;

        self.signedMostRecentConsent = managedObject.signedMostRecentConsent;

        self.subpopulationGuid = managedObject.subpopulationGuid;

    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ConsentStatus" inManagedObjectContext:cacheContext];
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

    managedObject.consented = ((id)self.consented == [NSNull null]) ? nil : self.consented;

    managedObject.name = ((id)self.name == [NSNull null]) ? nil : self.name;

    managedObject.required = ((id)self.required == [NSNull null]) ? nil : self.required;

    managedObject.signedMostRecentConsent = ((id)self.signedMostRecentConsent == [NSNull null]) ? nil : self.signedMostRecentConsent;

    managedObject.subpopulationGuid = ((id)self.subpopulationGuid == [NSNull null]) ? nil : self.subpopulationGuid;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
