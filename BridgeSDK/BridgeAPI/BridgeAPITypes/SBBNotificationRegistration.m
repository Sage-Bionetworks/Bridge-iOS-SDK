//
//  SBBNotificationRegistration.m
//
//	Copyright (c) 2017 Sage Bionetworks
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

#import "SBBNotificationRegistration.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBCompoundActivity.h"
#import "SBBSurveyReference.h"
#import "SBBTaskReference.h"

@interface SBBNotificationRegistration()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (SBBNotificationRegistration)

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* deviceId;

@property (nonatomic, strong) NSString* osName;

@property (nonatomic, strong) NSString* createdOn;

@property (nonatomic, strong) NSString* modifiedOn;

@property (nonatomic, strong) NSString* type;

@end

@implementation SBBNotificationRegistration

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

    self.guid = [dictionary objectForKey:@"guid"];
    self.deviceId = [dictionary objectForKey:@"deviceId"];
    self.osName = [dictionary objectForKey:@"osName"];
    self.createdOn = [dictionary objectForKey:@"createdOn"];
    self.modifiedOn = [dictionary objectForKey:@"modifiedOn"];
    self.type = [dictionary objectForKey:@"type"];
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];
    [dict setObjectIfNotNil:self.deviceId forKey:@"deviceId"];
    [dict setObjectIfNotNil:self.osName forKey:@"osName"];
    [dict setObjectIfNotNil:self.createdOn forKey:@"createdOn"];
    [dict setObjectIfNotNil:self.modifiedOn forKey:@"modifiedOn"];
    [dict setObjectIfNotNil:self.type forKey:@"type"];

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
    return @"NotificationRegistration";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.guid = managedObject.guid;
        self.deviceId = managedObject.deviceId;
        self.osName = managedObject.osName;
        self.createdOn = managedObject.createdOn;
        self.modifiedOn = managedObject.modifiedOn;
        self.type = managedObject.type;
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"NotificationRegistration" inManagedObjectContext:cacheContext];
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

    managedObject.guid = ((id)self.guid == [NSNull null]) ? nil : self.guid;
    managedObject.osName = ((id)self.osName == [NSNull null]) ? nil : self.osName;
    managedObject.deviceId = ((id)self.deviceId == [NSNull null]) ? nil : self.deviceId;
    managedObject.createdOn = ((id)self.createdOn == [NSNull null]) ? nil : self.createdOn;
    managedObject.modifiedOn = ((id)self.modifiedOn == [NSNull null]) ? nil : self.modifiedOn;
    managedObject.type = ((id)self.type == [NSNull null]) ? nil : self.type;

    // Calling code will handle saving these changes to cacheContext.
}

@end
