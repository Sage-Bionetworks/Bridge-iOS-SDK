//
//  _SBBSurvey.m
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
// Make changes to SBBSurvey.m instead.
//

#import "_SBBSurvey.h"
#import "_SBBSurveyInternal.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyElement.h"

@interface _SBBSurvey()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *elements;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (Survey)

@property (nullable, nonatomic, retain) NSString* copyrightNotice;

@property (nullable, nonatomic, retain) NSDate* createdOn;

@property (nullable, nonatomic, retain) NSString* guid;

@property (nullable, nonatomic, retain) NSString* guidAndCreatedOn;

@property (nullable, nonatomic, retain) NSString* identifier;

@property (nullable, nonatomic, retain) NSDate* modifiedOn;

@property (nullable, nonatomic, retain) NSString* moduleId;

@property (nullable, nonatomic, retain) NSNumber* moduleVersion;

@property (nullable, nonatomic, retain) NSString* name;

@property (nullable, nonatomic, retain) NSNumber* published;

@property (nullable, nonatomic, retain) NSNumber* schemaRevision;

@property (nullable, nonatomic, retain) NSNumber* version;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *elements;

- (void)addElementsObject:(NSManagedObject *)value;
- (void)removeElementsObject:(NSManagedObject *)value;
- (void)addElements:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeElements:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inElementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx;
- (void)insertElements:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeElementsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray<NSManagedObject *> *)values;

@end

@implementation _SBBSurvey

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)moduleVersionValue
{
	return [self.moduleVersion longLongValue];
}

- (void)setModuleVersionValue:(int64_t)value_
{
	self.moduleVersion = [NSNumber numberWithLongLong:value_];
}

- (BOOL)publishedValue
{
	return [self.published boolValue];
}

- (void)setPublishedValue:(BOOL)value_
{
	self.published = [NSNumber numberWithBool:value_];
}

- (double)schemaRevisionValue
{
	return [self.schemaRevision doubleValue];
}

- (void)setSchemaRevisionValue:(double)value_
{
	self.schemaRevision = [NSNumber numberWithDouble:value_];
}

- (double)versionValue
{
	return [self.version doubleValue];
}

- (void)setVersionValue:(double)value_
{
	self.version = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.copyrightNotice = [dictionary objectForKey:@"copyrightNotice"];

    self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

    self.guid = [dictionary objectForKey:@"guid"];

    self.identifier = [dictionary objectForKey:@"identifier"];

    self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

    self.moduleId = [dictionary objectForKey:@"moduleId"];

    self.moduleVersion = [dictionary objectForKey:@"moduleVersion"];

    self.name = [dictionary objectForKey:@"name"];

    self.published = [dictionary objectForKey:@"published"];

    self.schemaRevision = [dictionary objectForKey:@"schemaRevision"];

    self.version = [dictionary objectForKey:@"version"];

    NSArray *paths = [@"guid,createdOn" componentsSeparatedByString:@","];
    NSString *key = @"";
    for (NSString *path in paths) {
        NSString *value = [dictionary valueForKeyPath:path];
        if (!value) {
            // probably creating in CacheManager, so just use provided synthetic key, if any
            key = [dictionary valueForKeyPath:@"guidAndCreatedOn"] ?: @"";
            break;
        }
        key = [key stringByAppendingString:value];
    }

    self.guidAndCreatedOn = key;

    // overwrite the old elements relationship entirely rather than adding to it
    [self removeElementsObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"elements"])
    {
        SBBSurveyElement *elementsObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addElementsObject:elementsObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.copyrightNotice forKey:@"copyrightNotice"];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:[self.modifiedOn ISO8601String] forKey:@"modifiedOn"];

    [dict setObjectIfNotNil:self.moduleId forKey:@"moduleId"];

    [dict setObjectIfNotNil:self.moduleVersion forKey:@"moduleVersion"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

    [dict setObjectIfNotNil:self.published forKey:@"published"];

    [dict setObjectIfNotNil:self.schemaRevision forKey:@"schemaRevision"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

    if ([self.elements count] > 0)
	{

		NSMutableArray *elementsRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.elements count]];

		for (SBBSurveyElement *obj in self.elements)
        {
            [elementsRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:elementsRepresentationsForDictionary forKey:@"elements"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBSurveyElement *elementsObj in self.elements)
	{
		[elementsObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"Survey";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.copyrightNotice = managedObject.copyrightNotice;

        self.createdOn = managedObject.createdOn;

        self.guid = managedObject.guid;

        self.guidAndCreatedOn = managedObject.guidAndCreatedOn;

        self.identifier = managedObject.identifier;

        self.modifiedOn = managedObject.modifiedOn;

        self.moduleId = managedObject.moduleId;

        self.moduleVersion = managedObject.moduleVersion;

        self.name = managedObject.name;

        self.published = managedObject.published;

        self.schemaRevision = managedObject.schemaRevision;

        self.version = managedObject.version;

		for (NSManagedObject *elementsManagedObj in managedObject.elements)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:elementsManagedObj.entity.name];
            SBBSurveyElement *elementsObj = [[objectClass alloc] initWithManagedObject:elementsManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (elementsObj != nil)
            {
                [self addElementsObject:elementsObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Survey" inManagedObjectContext:cacheContext];
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

    managedObject.copyrightNotice = ((id)self.copyrightNotice == [NSNull null]) ? nil : self.copyrightNotice;

    managedObject.createdOn = ((id)self.createdOn == [NSNull null]) ? nil : self.createdOn;

    managedObject.guid = ((id)self.guid == [NSNull null]) ? nil : self.guid;

    managedObject.guidAndCreatedOn = ((id)self.guidAndCreatedOn == [NSNull null]) ? nil : self.guidAndCreatedOn;

    managedObject.identifier = ((id)self.identifier == [NSNull null]) ? nil : self.identifier;

    managedObject.modifiedOn = ((id)self.modifiedOn == [NSNull null]) ? nil : self.modifiedOn;

    managedObject.moduleId = ((id)self.moduleId == [NSNull null]) ? nil : self.moduleId;

    managedObject.moduleVersion = ((id)self.moduleVersion == [NSNull null]) ? nil : self.moduleVersion;

    managedObject.name = ((id)self.name == [NSNull null]) ? nil : self.name;

    managedObject.published = ((id)self.published == [NSNull null]) ? nil : self.published;

    managedObject.schemaRevision = ((id)self.schemaRevision == [NSNull null]) ? nil : self.schemaRevision;

    managedObject.version = ((id)self.version == [NSNull null]) ? nil : self.version;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSOrderedSet *elementsCopy = [managedObject.elements copy];

    // now remove all items from the existing relationship
    // to work pre-iOS 10, we have to work around this issue: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    NSMutableOrderedSet *workingElementsSet = [managedObject mutableOrderedSetValueForKey:NSStringFromSelector(@selector(elements))];
    [workingElementsSet removeAllObjects];

    // now put the "new" items, if any, into the relationship
    if ([self.elements count] > 0) {
		for (SBBSurveyElement *obj in self.elements) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [workingElementsSet addObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in elementsCopy) {
        if (![relMo valueForKey:@"survey"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    elementsCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse
{
    if (self.elements == nil)
	{

		self.elements = [NSMutableArray array];

	}

	[(NSMutableArray *)self.elements addObject:value_];

}

- (void)addElementsObject:(SBBSurveyElement*)value_
{
    [self addElementsObject:(SBBSurveyElement*)value_ settingInverse: YES];
}

- (void)removeElementsObjects
{

    self.elements = [NSMutableArray array];

}

- (void)removeElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.elements removeObject:value_];

}

- (void)removeElementsObject:(SBBSurveyElement*)value_
{
    [self removeElementsObject:(SBBSurveyElement*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyElement*)value inElementsAtIndex:(NSUInteger)idx {
    [self insertObject:value inElementsAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyElement*)value inElementsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements insertObject:value atIndex:idx];

}

- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx {
    [self removeObjectFromElementsAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyElement *object = [self.elements objectAtIndex:idx];
    [self removeElementsObject:object settingInverse:YES];
}

- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertElements:value atIndexes:indexes settingInverse:YES];
}

- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.elements insertObjects:value atIndexes:indexes];

}

- (void)removeElementsAtIndexes:(NSIndexSet *)indexes {
    [self removeElementsAtIndexes:indexes settingInverse:YES];
}

- (void)removeElementsAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value {
    [self replaceObjectInElementsAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)value {
    [self replaceElementsAtIndexes:indexes withElements:value settingInverse:YES];
}

- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
