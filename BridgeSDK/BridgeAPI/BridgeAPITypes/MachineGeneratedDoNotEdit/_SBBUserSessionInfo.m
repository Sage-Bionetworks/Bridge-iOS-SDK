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

@interface _SBBUserSessionInfo()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (UserSessionInfo)

@property (nonatomic, strong) NSNumber* authenticated;

@property (nonatomic, assign) BOOL authenticatedValue;

@property (nonatomic, strong) NSDictionary<NSString *, SBBConsentStatus *>* consentStatuses;

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

    self.consentStatuses = [dictionary objectForKey:@"consentStatuses"];

    self.consented = [dictionary objectForKey:@"consented"];

    self.dataGroups = [dictionary objectForKey:@"dataGroups"];

    self.dataSharing = [dictionary objectForKey:@"dataSharing"];

    self.environment = [dictionary objectForKey:@"environment"];

    self.roles = [dictionary objectForKey:@"roles"];

    self.sessionToken = [dictionary objectForKey:@"sessionToken"];

    self.sharingScope = [dictionary objectForKey:@"sharingScope"];

    self.signedMostRecentConsent = [dictionary objectForKey:@"signedMostRecentConsent"];

    self.username = [dictionary objectForKey:@"username"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.authenticated forKey:@"authenticated"];

    [dict setObjectIfNotNil:self.consentStatuses forKey:@"consentStatuses"];

    [dict setObjectIfNotNil:self.consented forKey:@"consented"];

    [dict setObjectIfNotNil:self.dataGroups forKey:@"dataGroups"];

    [dict setObjectIfNotNil:self.dataSharing forKey:@"dataSharing"];

    [dict setObjectIfNotNil:self.environment forKey:@"environment"];

    [dict setObjectIfNotNil:self.roles forKey:@"roles"];

    [dict setObjectIfNotNil:self.sessionToken forKey:@"sessionToken"];

    [dict setObjectIfNotNil:self.sharingScope forKey:@"sharingScope"];

    [dict setObjectIfNotNil:self.signedMostRecentConsent forKey:@"signedMostRecentConsent"];

    [dict setObjectIfNotNil:self.username forKey:@"username"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

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

        self.consentStatuses = managedObject.consentStatuses;

        self.consented = managedObject.consented;

        self.dataGroups = managedObject.dataGroups;

        self.dataSharing = managedObject.dataSharing;

        self.environment = managedObject.environment;

        self.roles = managedObject.roles;

        self.sessionToken = managedObject.sessionToken;

        self.sharingScope = managedObject.sharingScope;

        self.signedMostRecentConsent = managedObject.signedMostRecentConsent;

        self.username = managedObject.username;

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

    managedObject.authenticated = self.authenticated;

    managedObject.consentStatuses = self.consentStatuses;

    managedObject.consented = self.consented;

    managedObject.dataGroups = self.dataGroups;

    managedObject.dataSharing = self.dataSharing;

    managedObject.environment = self.environment;

    managedObject.roles = self.roles;

    managedObject.sessionToken = self.sessionToken;

    managedObject.sharingScope = self.sharingScope;

    managedObject.signedMostRecentConsent = self.signedMostRecentConsent;

    managedObject.username = self.username;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
