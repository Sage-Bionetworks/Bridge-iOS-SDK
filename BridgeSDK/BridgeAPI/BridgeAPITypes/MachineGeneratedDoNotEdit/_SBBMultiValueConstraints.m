//
//  _SBBMultiValueConstraints.m
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
// Make changes to SBBMultiValueConstraints.m instead.
//

#import "_SBBMultiValueConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyQuestionOption.h"

@interface _SBBMultiValueConstraints()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *enumeration;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (MultiValueConstraints)

@property (nullable, nonatomic, retain) NSNumber* allowMultiple;

@property (nullable, nonatomic, retain) NSNumber* allowOther;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *enumeration;

- (void)addEnumerationObject:(NSManagedObject *)value;
- (void)removeEnumerationObject:(NSManagedObject *)value;
- (void)addEnumeration:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeEnumeration:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inEnumerationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEnumerationAtIndex:(NSUInteger)idx;
- (void)insertEnumeration:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEnumerationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEnumerationAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceEnumerationAtIndexes:(NSIndexSet *)indexes withEnumeration:(NSArray<NSManagedObject *> *)values;

@end

@implementation _SBBMultiValueConstraints

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)allowMultipleValue
{
	return [self.allowMultiple boolValue];
}

- (void)setAllowMultipleValue:(BOOL)value_
{
	self.allowMultiple = [NSNumber numberWithBool:value_];
}

- (BOOL)allowOtherValue
{
	return [self.allowOther boolValue];
}

- (void)setAllowOtherValue:(BOOL)value_
{
	self.allowOther = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.allowMultiple = [dictionary objectForKey:@"allowMultiple"];

    self.allowOther = [dictionary objectForKey:@"allowOther"];

    // overwrite the old enumeration relationship entirely rather than adding to it
    [self removeEnumerationObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"enumeration"])
    {
        SBBSurveyQuestionOption *enumerationObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addEnumerationObject:enumerationObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.allowMultiple forKey:@"allowMultiple"];

    [dict setObjectIfNotNil:self.allowOther forKey:@"allowOther"];

    if ([self.enumeration count] > 0)
	{

		NSMutableArray *enumerationRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.enumeration count]];

		for (SBBSurveyQuestionOption *obj in self.enumeration)
        {
            [enumerationRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:enumerationRepresentationsForDictionary forKey:@"enumeration"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBSurveyQuestionOption *enumerationObj in self.enumeration)
	{
		[enumerationObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"MultiValueConstraints";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.allowMultiple = managedObject.allowMultiple;

        self.allowOther = managedObject.allowOther;

		for (NSManagedObject *enumerationManagedObj in managedObject.enumeration)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:enumerationManagedObj.entity.name];
            SBBSurveyQuestionOption *enumerationObj = [[objectClass alloc] initWithManagedObject:enumerationManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (enumerationObj != nil)
            {
                [self addEnumerationObject:enumerationObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MultiValueConstraints" inManagedObjectContext:cacheContext];
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

    managedObject.allowMultiple = ((id)self.allowMultiple == [NSNull null]) ? nil : self.allowMultiple;

    managedObject.allowOther = ((id)self.allowOther == [NSNull null]) ? nil : self.allowOther;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSOrderedSet *enumerationCopy = [managedObject.enumeration copy];

    // now remove all items from the existing relationship
    // to work pre-iOS 10, we have to work around this issue: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    NSMutableOrderedSet *workingEnumerationSet = [managedObject mutableOrderedSetValueForKey:NSStringFromSelector(@selector(enumeration))];
    [workingEnumerationSet removeAllObjects];

    // now put the "new" items, if any, into the relationship
    if ([self.enumeration count] > 0) {
		for (SBBSurveyQuestionOption *obj in self.enumeration) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [workingEnumerationSet addObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in enumerationCopy) {
        if (![relMo valueForKey:@"multiValueConstraints"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    enumerationCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addEnumerationObject:(SBBSurveyQuestionOption*)value_ settingInverse: (BOOL) setInverse
{
    if (self.enumeration == nil)
	{

		self.enumeration = [NSMutableArray array];

	}

	[(NSMutableArray *)self.enumeration addObject:value_];

}

- (void)addEnumerationObject:(SBBSurveyQuestionOption*)value_
{
    [self addEnumerationObject:(SBBSurveyQuestionOption*)value_ settingInverse: YES];
}

- (void)removeEnumerationObjects
{

    self.enumeration = [NSMutableArray array];

}

- (void)removeEnumerationObject:(SBBSurveyQuestionOption*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.enumeration removeObject:value_];

}

- (void)removeEnumerationObject:(SBBSurveyQuestionOption*)value_
{
    [self removeEnumerationObject:(SBBSurveyQuestionOption*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyQuestionOption*)value inEnumerationAtIndex:(NSUInteger)idx {
    [self insertObject:value inEnumerationAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyQuestionOption*)value inEnumerationAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.enumeration insertObject:value atIndex:idx];

}

- (void)removeObjectFromEnumerationAtIndex:(NSUInteger)idx {
    [self removeObjectFromEnumerationAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromEnumerationAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyQuestionOption *object = [self.enumeration objectAtIndex:idx];
    [self removeEnumerationObject:object settingInverse:YES];
}

- (void)insertEnumeration:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertEnumeration:value atIndexes:indexes settingInverse:YES];
}

- (void)insertEnumeration:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.enumeration insertObjects:value atIndexes:indexes];

}

- (void)removeEnumerationAtIndexes:(NSIndexSet *)indexes {
    [self removeEnumerationAtIndexes:indexes settingInverse:YES];
}

- (void)removeEnumerationAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.enumeration removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInEnumerationAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestionOption*)value {
    [self replaceObjectInEnumerationAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInEnumerationAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestionOption*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.enumeration replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceEnumerationAtIndexes:(NSIndexSet *)indexes withEnumeration:(NSArray *)value {
    [self replaceEnumerationAtIndexes:indexes withEnumeration:value settingInverse:YES];
}

- (void)replaceEnumerationAtIndexes:(NSIndexSet *)indexes withEnumeration:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.enumeration replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
