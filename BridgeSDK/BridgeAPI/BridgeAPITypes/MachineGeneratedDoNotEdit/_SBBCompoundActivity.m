//
//  _SBBCompoundActivity.m
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
// Make changes to SBBCompoundActivity.m instead.
//

#import "_SBBCompoundActivity.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSchemaReference.h"
#import "SBBSurveyReference.h"

@interface _SBBCompoundActivity()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *schemaList;

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *surveyList;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (CompoundActivity)

@property (nullable, nonatomic, retain) NSString* taskIdentifier;

@property (nullable, nonatomic, retain) NSManagedObject *activity;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *schemaList;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *surveyList;

- (void)addSchemaListObject:(NSManagedObject *)value;
- (void)removeSchemaListObject:(NSManagedObject *)value;

- (void)addSchemaList:(NSSet<NSManagedObject *> *)values;
- (void)removeSchemaList:(NSSet<NSManagedObject *> *)values;

- (void)addSurveyListObject:(NSManagedObject *)value;
- (void)removeSurveyListObject:(NSManagedObject *)value;

- (void)addSurveyList:(NSSet<NSManagedObject *> *)values;
- (void)removeSurveyList:(NSSet<NSManagedObject *> *)values;

@end

@implementation _SBBCompoundActivity

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

    self.taskIdentifier = [dictionary objectForKey:@"taskIdentifier"];

    // overwrite the old schemaList relationship entirely rather than adding to it
    [self removeSchemaListObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"schemaList"])
    {
        SBBSchemaReference *schemaListObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addSchemaListObject:schemaListObj];
    }

    // overwrite the old surveyList relationship entirely rather than adding to it
    [self removeSurveyListObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"surveyList"])
    {
        SBBSurveyReference *surveyListObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addSurveyListObject:surveyListObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.taskIdentifier forKey:@"taskIdentifier"];

    if ([self.schemaList count] > 0)
	{

		NSMutableArray *schemaListRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.schemaList count]];

		for (SBBSchemaReference *obj in self.schemaList)
        {
            [schemaListRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:schemaListRepresentationsForDictionary forKey:@"schemaList"];

	}

    if ([self.surveyList count] > 0)
	{

		NSMutableArray *surveyListRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.surveyList count]];

		for (SBBSurveyReference *obj in self.surveyList)
        {
            [surveyListRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:surveyListRepresentationsForDictionary forKey:@"surveyList"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBSchemaReference *schemaListObj in self.schemaList)
	{
		[schemaListObj awakeFromDictionaryRepresentationInit];
	}

	for (SBBSurveyReference *surveyListObj in self.surveyList)
	{
		[surveyListObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"CompoundActivity";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.taskIdentifier = managedObject.taskIdentifier;

		for (NSManagedObject *schemaListManagedObj in managedObject.schemaList)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:schemaListManagedObj.entity.name];
            SBBSchemaReference *schemaListObj = [[objectClass alloc] initWithManagedObject:schemaListManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (schemaListObj != nil)
            {
                [self addSchemaListObject:schemaListObj];
            }
		}

		for (NSManagedObject *surveyListManagedObj in managedObject.surveyList)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:surveyListManagedObj.entity.name];
            SBBSurveyReference *surveyListObj = [[objectClass alloc] initWithManagedObject:surveyListManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (surveyListObj != nil)
            {
                [self addSurveyListObject:surveyListObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"CompoundActivity" inManagedObjectContext:cacheContext];
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

    managedObject.taskIdentifier = ((id)self.taskIdentifier == [NSNull null]) ? nil : self.taskIdentifier;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSSet *schemaListCopy = [managedObject.schemaList copy];

    // now remove all items from the existing relationship
    [managedObject removeSchemaList:managedObject.schemaList];

    // now put the "new" items, if any, into the relationship
    if ([self.schemaList count] > 0) {
		for (SBBSchemaReference *obj in self.schemaList) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [managedObject addSchemaListObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in schemaListCopy) {
        if (![relMo valueForKey:@"compoundActivity"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    schemaListCopy = nil;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSSet *surveyListCopy = [managedObject.surveyList copy];

    // now remove all items from the existing relationship
    [managedObject removeSurveyList:managedObject.surveyList];

    // now put the "new" items, if any, into the relationship
    if ([self.surveyList count] > 0) {
		for (SBBSurveyReference *obj in self.surveyList) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [managedObject addSurveyListObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in surveyListCopy) {
        if (![relMo valueForKey:@"compoundActivity"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    surveyListCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addSchemaListObject:(SBBSchemaReference*)value_ settingInverse: (BOOL) setInverse
{
    if (self.schemaList == nil)
	{

		self.schemaList = [NSMutableArray array];

	}

	[(NSMutableArray *)self.schemaList addObject:value_];

}

- (void)addSchemaListObject:(SBBSchemaReference*)value_
{
    [self addSchemaListObject:(SBBSchemaReference*)value_ settingInverse: YES];
}

- (void)removeSchemaListObjects
{

    self.schemaList = [NSMutableArray array];

}

- (void)removeSchemaListObject:(SBBSchemaReference*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.schemaList removeObject:value_];

}

- (void)removeSchemaListObject:(SBBSchemaReference*)value_
{
    [self removeSchemaListObject:(SBBSchemaReference*)value_ settingInverse: YES];
}

- (void)addSurveyListObject:(SBBSurveyReference*)value_ settingInverse: (BOOL) setInverse
{
    if (self.surveyList == nil)
	{

		self.surveyList = [NSMutableArray array];

	}

	[(NSMutableArray *)self.surveyList addObject:value_];

}

- (void)addSurveyListObject:(SBBSurveyReference*)value_
{
    [self addSurveyListObject:(SBBSurveyReference*)value_ settingInverse: YES];
}

- (void)removeSurveyListObjects
{

    self.surveyList = [NSMutableArray array];

}

- (void)removeSurveyListObject:(SBBSurveyReference*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.surveyList removeObject:value_];

}

- (void)removeSurveyListObject:(SBBSurveyReference*)value_
{
    [self removeSurveyListObject:(SBBSurveyReference*)value_ settingInverse: YES];
}

@end
