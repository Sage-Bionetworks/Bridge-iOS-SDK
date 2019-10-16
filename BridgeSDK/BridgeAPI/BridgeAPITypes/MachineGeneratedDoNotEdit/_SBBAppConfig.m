//
//  _SBBAppConfig.m
//
//	Copyright (c) 2014-2019 Sage Bionetworks
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
// Make changes to SBBAppConfig.m instead.
//

#import "_SBBAppConfig.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBConfigReference.h"
#import "SBBSchemaReference.h"
#import "SBBSurveyReference.h"

@interface _SBBAppConfig()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *configReferences;

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *schemaReferences;

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *surveyReferences;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (AppConfig)

@property (nullable, nonatomic, retain) id<SBBJSONValue> clientData;

@property (nullable, nonatomic, retain) id<SBBJSONValue> configElements;

@property (nullable, nonatomic, retain) NSDate* createdOn;

@property (nullable, nonatomic, retain) NSString* guid;

@property (nullable, nonatomic, retain) NSString* label;

@property (nullable, nonatomic, retain) NSDate* modifiedOn;

@property (nullable, nonatomic, retain) NSNumber* version;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *configReferences;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *schemaReferences;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *surveyReferences;

- (void)addConfigReferencesObject:(NSManagedObject *)value;
- (void)removeConfigReferencesObject:(NSManagedObject *)value;

- (void)addConfigReferences:(NSSet<NSManagedObject *> *)values;
- (void)removeConfigReferences:(NSSet<NSManagedObject *> *)values;

- (void)addSchemaReferencesObject:(NSManagedObject *)value;
- (void)removeSchemaReferencesObject:(NSManagedObject *)value;

- (void)addSchemaReferences:(NSSet<NSManagedObject *> *)values;
- (void)removeSchemaReferences:(NSSet<NSManagedObject *> *)values;

- (void)addSurveyReferencesObject:(NSManagedObject *)value;
- (void)removeSurveyReferencesObject:(NSManagedObject *)value;

- (void)addSurveyReferences:(NSSet<NSManagedObject *> *)values;
- (void)removeSurveyReferences:(NSSet<NSManagedObject *> *)values;

@end

@implementation _SBBAppConfig

- (instancetype)init
{
	if ((self = [super init]))
	{
		self.version = [NSNumber numberWithLongLong:0];

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)versionValue
{
	return [self.version longLongValue];
}

- (void)setVersionValue:(int64_t)value_
{
	self.version = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.clientData = [dictionary objectForKey:@"clientData"];

    self.configElements = [dictionary objectForKey:@"configElements"];

    self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

    self.guid = [dictionary objectForKey:@"guid"];

    self.label = [dictionary objectForKey:@"label"];

    self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

    self.version = [dictionary objectForKey:@"version"];

    // overwrite the old configReferences relationship entirely rather than adding to it
    [self removeConfigReferencesObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"configReferences"])
    {
        SBBConfigReference *configReferencesObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addConfigReferencesObject:configReferencesObj];
    }

    // overwrite the old schemaReferences relationship entirely rather than adding to it
    [self removeSchemaReferencesObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"schemaReferences"])
    {
        SBBSchemaReference *schemaReferencesObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addSchemaReferencesObject:schemaReferencesObj];
    }

    // overwrite the old surveyReferences relationship entirely rather than adding to it
    [self removeSurveyReferencesObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"surveyReferences"])
    {
        SBBSurveyReference *surveyReferencesObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addSurveyReferencesObject:surveyReferencesObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.clientData forKey:@"clientData"];

    [dict setObjectIfNotNil:self.configElements forKey:@"configElements"];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:[self.modifiedOn ISO8601String] forKey:@"modifiedOn"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

    if ([self.configReferences count] > 0)
	{

		NSMutableArray *configReferencesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.configReferences count]];

		for (SBBConfigReference *obj in self.configReferences)
        {
            [configReferencesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:configReferencesRepresentationsForDictionary forKey:@"configReferences"];

	}

    if ([self.schemaReferences count] > 0)
	{

		NSMutableArray *schemaReferencesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.schemaReferences count]];

		for (SBBSchemaReference *obj in self.schemaReferences)
        {
            [schemaReferencesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:schemaReferencesRepresentationsForDictionary forKey:@"schemaReferences"];

	}

    if ([self.surveyReferences count] > 0)
	{

		NSMutableArray *surveyReferencesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.surveyReferences count]];

		for (SBBSurveyReference *obj in self.surveyReferences)
        {
            [surveyReferencesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:surveyReferencesRepresentationsForDictionary forKey:@"surveyReferences"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBSchemaReference *schemaReferencesObj in self.schemaReferences)
	{
		[schemaReferencesObj awakeFromDictionaryRepresentationInit];
	}

	for (SBBSurveyReference *surveyReferencesObj in self.surveyReferences)
	{
		[surveyReferencesObj awakeFromDictionaryRepresentationInit];
	}

	for (SBBConfigReference *configReferencesObj in self.configReferences)
	{
		[configReferencesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"AppConfig";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.clientData = managedObject.clientData;

        self.configElements = managedObject.configElements;

        self.createdOn = managedObject.createdOn;

        self.guid = managedObject.guid;

        self.label = managedObject.label;

        self.modifiedOn = managedObject.modifiedOn;

        self.version = managedObject.version;

		for (NSManagedObject *configReferencesManagedObj in managedObject.configReferences)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:configReferencesManagedObj.entity.name];
            SBBConfigReference *configReferencesObj = [[objectClass alloc] initWithManagedObject:configReferencesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (configReferencesObj != nil)
            {
                [self addConfigReferencesObject:configReferencesObj];
            }
		}

		for (NSManagedObject *schemaReferencesManagedObj in managedObject.schemaReferences)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:schemaReferencesManagedObj.entity.name];
            SBBSchemaReference *schemaReferencesObj = [[objectClass alloc] initWithManagedObject:schemaReferencesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (schemaReferencesObj != nil)
            {
                [self addSchemaReferencesObject:schemaReferencesObj];
            }
		}

		for (NSManagedObject *surveyReferencesManagedObj in managedObject.surveyReferences)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:surveyReferencesManagedObj.entity.name];
            SBBSurveyReference *surveyReferencesObj = [[objectClass alloc] initWithManagedObject:surveyReferencesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (surveyReferencesObj != nil)
            {
                [self addSurveyReferencesObject:surveyReferencesObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"AppConfig" inManagedObjectContext:cacheContext];
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

    managedObject.clientData = ((id)self.clientData == [NSNull null]) ? nil : self.clientData;

    managedObject.configElements = ((id)self.configElements == [NSNull null]) ? nil : self.configElements;

    if (self.createdOn) managedObject.createdOn = self.createdOn;

    if (self.guid) managedObject.guid = self.guid;

    managedObject.label = ((id)self.label == [NSNull null]) ? nil : self.label;

    if (self.modifiedOn) managedObject.modifiedOn = self.modifiedOn;

    if (self.version) managedObject.version = self.version;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSSet *configReferencesCopy = [managedObject.configReferences copy];

    // now remove all items from the existing relationship
    [managedObject removeConfigReferences:managedObject.configReferences];

    // now put the "new" items, if any, into the relationship
    if ([self.configReferences count] > 0) {
		for (SBBConfigReference *obj in self.configReferences) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [managedObject addConfigReferencesObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in configReferencesCopy) {
        if (![relMo valueForKey:@"appConfig"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    configReferencesCopy = nil;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSSet *schemaReferencesCopy = [managedObject.schemaReferences copy];

    // now remove all items from the existing relationship
    [managedObject removeSchemaReferences:managedObject.schemaReferences];

    // now put the "new" items, if any, into the relationship
    if ([self.schemaReferences count] > 0) {
		for (SBBSchemaReference *obj in self.schemaReferences) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [managedObject addSchemaReferencesObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in schemaReferencesCopy) {
        if (![relMo valueForKey:@"appConfig"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    schemaReferencesCopy = nil;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSSet *surveyReferencesCopy = [managedObject.surveyReferences copy];

    // now remove all items from the existing relationship
    [managedObject removeSurveyReferences:managedObject.surveyReferences];

    // now put the "new" items, if any, into the relationship
    if ([self.surveyReferences count] > 0) {
		for (SBBSurveyReference *obj in self.surveyReferences) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [managedObject addSurveyReferencesObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in surveyReferencesCopy) {
        if (![relMo valueForKey:@"appConfig"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    surveyReferencesCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addConfigReferencesObject:(SBBConfigReference*)value_ settingInverse: (BOOL) setInverse
{
    if (self.configReferences == nil)
	{

		self.configReferences = [NSMutableArray array];

	}

	[(NSMutableArray *)self.configReferences addObject:value_];

}

- (void)addConfigReferencesObject:(SBBConfigReference*)value_
{
    [self addConfigReferencesObject:(SBBConfigReference*)value_ settingInverse: YES];
}

- (void)removeConfigReferencesObjects
{

    self.configReferences = [NSMutableArray array];

}

- (void)removeConfigReferencesObject:(SBBConfigReference*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.configReferences removeObject:value_];

}

- (void)removeConfigReferencesObject:(SBBConfigReference*)value_
{
    [self removeConfigReferencesObject:(SBBConfigReference*)value_ settingInverse: YES];
}

- (void)addSchemaReferencesObject:(SBBSchemaReference*)value_ settingInverse: (BOOL) setInverse
{
    if (self.schemaReferences == nil)
	{

		self.schemaReferences = [NSMutableArray array];

	}

	[(NSMutableArray *)self.schemaReferences addObject:value_];

}

- (void)addSchemaReferencesObject:(SBBSchemaReference*)value_
{
    [self addSchemaReferencesObject:(SBBSchemaReference*)value_ settingInverse: YES];
}

- (void)removeSchemaReferencesObjects
{

    self.schemaReferences = [NSMutableArray array];

}

- (void)removeSchemaReferencesObject:(SBBSchemaReference*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.schemaReferences removeObject:value_];

}

- (void)removeSchemaReferencesObject:(SBBSchemaReference*)value_
{
    [self removeSchemaReferencesObject:(SBBSchemaReference*)value_ settingInverse: YES];
}

- (void)addSurveyReferencesObject:(SBBSurveyReference*)value_ settingInverse: (BOOL) setInverse
{
    if (self.surveyReferences == nil)
	{

		self.surveyReferences = [NSMutableArray array];

	}

	[(NSMutableArray *)self.surveyReferences addObject:value_];

}

- (void)addSurveyReferencesObject:(SBBSurveyReference*)value_
{
    [self addSurveyReferencesObject:(SBBSurveyReference*)value_ settingInverse: YES];
}

- (void)removeSurveyReferencesObjects
{

    self.surveyReferences = [NSMutableArray array];

}

- (void)removeSurveyReferencesObject:(SBBSurveyReference*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.surveyReferences removeObject:value_];

}

- (void)removeSurveyReferencesObject:(SBBSurveyReference*)value_
{
    [self removeSurveyReferencesObject:(SBBSurveyReference*)value_ settingInverse: YES];
}

@end
