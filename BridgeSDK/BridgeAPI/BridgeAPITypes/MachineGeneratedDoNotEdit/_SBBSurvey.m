//
//  SBBSurvey.m
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
// Make changes to SBBSurvey.h instead.
//

#import "_SBBSurvey.h"
#import "_SBBSurveyInternal.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyElement.h"

@interface _SBBSurvey()
@property (nonatomic, strong, readwrite) NSArray *elements;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (Survey)

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* guidAndCreatedOn;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* modifiedOn;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSNumber* published;

@property (nonatomic, assign) BOOL publishedValue;

@property (nonatomic, strong) NSNumber* schemaRevision;

@property (nonatomic, assign) double schemaRevisionValue;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) double versionValue;

@property (nonatomic, strong, readonly) NSArray *elements;

- (void)addElementsObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addElementsObject:(NSManagedObject *)value_;
- (void)removeElementsObjects;
- (void)removeElementsObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeElementsObject:(NSManagedObject *)value_;

- (void)insertObject:(NSManagedObject *)value inElementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx;
- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeElementsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)values;

@end

@implementation _SBBSurvey

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

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

    self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

    self.guid = [dictionary objectForKey:@"guid"];

    self.identifier = [dictionary objectForKey:@"identifier"];

    self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

    self.name = [dictionary objectForKey:@"name"];

    self.published = [dictionary objectForKey:@"published"];

    self.schemaRevision = [dictionary objectForKey:@"schemaRevision"];

    self.version = [dictionary objectForKey:@"version"];

    NSArray *paths = [@"guid,createdOn" componentsSeparatedByString:@","];
    NSString *key = @"";
    for (NSString *path in paths) {
        NSString *value = [dictionary valueForKeyPath:path];
        key = [key stringByAppendingString:value];
    }

    self.guidAndCreatedOn = key;

    for(id objectRepresentationForDict in [dictionary objectForKey:@"elements"])
    {
        SBBSurveyElement *elementsObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addElementsObject:elementsObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:[self.modifiedOn ISO8601String] forKey:@"modifiedOn"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

    [dict setObjectIfNotNil:self.published forKey:@"published"];

    [dict setObjectIfNotNil:self.schemaRevision forKey:@"schemaRevision"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

    if([self.elements count] > 0)
	{

		NSMutableArray *elementsRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.elements count]];
		for(SBBSurveyElement *obj in self.elements)
		{
			[elementsRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:elementsRepresentationsForDictionary forKey:@"elements"];

	}

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBSurveyElement *elementsObj in self.elements)
	{
		[elementsObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"Survey" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.createdOn = managedObject.createdOn;

        self.guid = managedObject.guid;

        self.guidAndCreatedOn = managedObject.guidAndCreatedOn;

        self.identifier = managedObject.identifier;

        self.modifiedOn = managedObject.modifiedOn;

        self.name = managedObject.name;

        self.published = managedObject.published;

        self.schemaRevision = managedObject.schemaRevision;

        self.version = managedObject.version;

		for(NSManagedObject *elementsManagedObj in managedObject.elements)
		{
            SBBSurveyElement *elementsObj = [[SBBSurveyElement alloc] initWithManagedObject:elementsManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(elementsObj != nil)
            {
                [self addElementsObject:elementsObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Survey" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.createdOn = self.createdOn;

    managedObject.guid = self.guid;

    managedObject.guidAndCreatedOn = self.guidAndCreatedOn;

    managedObject.identifier = self.identifier;

    managedObject.modifiedOn = self.modifiedOn;

    managedObject.name = self.name;

    managedObject.published = self.published;

    managedObject.schemaRevision = self.schemaRevision;

    managedObject.version = self.version;

    if([self.elements count] > 0) {
        for (SBBSurveyElement *obj in self.elements) {
            // see if a managed object for obj is already in the relationship
            BOOL alreadyInRelationship = NO;
            __block NSManagedObject *relMo = nil;
            NSString *keyPath = @"guid";
            NSString *objectId = obj.guid;
            while ([objectId isKindOfClass:[NSArray class]]) {
                objectId = ((NSArray *)objectId).firstObject;
            }

            for (NSManagedObject *mo in managedObject.elements) {
                if ([[mo valueForKeyPath:keyPath] isEqualToString:objectId]) {
                    relMo = mo;
                    alreadyInRelationship = YES;
                    break;
                }
            }

            // if not, check if one exists but just isn't in the relationship yet
            if (!relMo) {
                NSEntityDescription *relEntity = [NSEntityDescription entityForName:@"SurveyElement" inManagedObjectContext:cacheContext];
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
                relMo = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyElement" inManagedObjectContext:cacheContext];
            }

            // update it from obj
            [obj updateManagedObject:relMo withObjectManager:objectManager cacheManager:cacheManager];

            // add to relationship if not already in it
            if (!alreadyInRelationship) {
                [managedObject addElementsObject:relMo];
            }
        }
	}

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse
{
    if(self.elements == nil)
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
