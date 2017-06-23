//
//  _SBBSurveyElement.m
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
// Make changes to SBBSurveyElement.m instead.
//

#import "_SBBSurveyElement.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyRule.h"

@interface _SBBSurveyElement()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *afterRules;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (SurveyElement)

@property (nullable, nonatomic, retain) NSString* guid;

@property (nullable, nonatomic, retain) NSString* identifier;

@property (nullable, nonatomic, retain) NSString* prompt;

@property (nullable, nonatomic, retain) NSString* promptDetail;

@property (nullable, nonatomic, retain) NSString* title;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *afterRules;

@property (nullable, nonatomic, retain) NSManagedObject *survey;

- (void)addAfterRulesObject:(NSManagedObject *)value;
- (void)removeAfterRulesObject:(NSManagedObject *)value;
- (void)addAfterRules:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeAfterRules:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inAfterRulesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAfterRulesAtIndex:(NSUInteger)idx;
- (void)insertAfterRules:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAfterRulesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAfterRulesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceAfterRulesAtIndexes:(NSIndexSet *)indexes withAfterRules:(NSArray<NSManagedObject *> *)values;

@end

@implementation _SBBSurveyElement

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

    self.identifier = [dictionary objectForKey:@"identifier"];

    self.prompt = [dictionary objectForKey:@"prompt"];

    self.promptDetail = [dictionary objectForKey:@"promptDetail"];

    self.title = [dictionary objectForKey:@"title"];

    // overwrite the old afterRules relationship entirely rather than adding to it
    [self removeAfterRulesObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"afterRules"])
    {
        SBBSurveyRule *afterRulesObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addAfterRulesObject:afterRulesObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:self.prompt forKey:@"prompt"];

    [dict setObjectIfNotNil:self.promptDetail forKey:@"promptDetail"];

    [dict setObjectIfNotNil:self.title forKey:@"title"];

    if ([self.afterRules count] > 0)
	{

		NSMutableArray *afterRulesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.afterRules count]];

		for (SBBSurveyRule *obj in self.afterRules)
        {
            [afterRulesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:afterRulesRepresentationsForDictionary forKey:@"afterRules"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBSurveyRule *afterRulesObj in self.afterRules)
	{
		[afterRulesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"SurveyElement";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.guid = managedObject.guid;

        self.identifier = managedObject.identifier;

        self.prompt = managedObject.prompt;

        self.promptDetail = managedObject.promptDetail;

        self.title = managedObject.title;

		for (NSManagedObject *afterRulesManagedObj in managedObject.afterRules)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:afterRulesManagedObj.entity.name];
            SBBSurveyRule *afterRulesObj = [[objectClass alloc] initWithManagedObject:afterRulesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (afterRulesObj != nil)
            {
                [self addAfterRulesObject:afterRulesObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyElement" inManagedObjectContext:cacheContext];
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

    managedObject.guid = ((id)self.guid == [NSNull null]) ? nil : self.guid;

    managedObject.identifier = ((id)self.identifier == [NSNull null]) ? nil : self.identifier;

    managedObject.prompt = ((id)self.prompt == [NSNull null]) ? nil : self.prompt;

    managedObject.promptDetail = ((id)self.promptDetail == [NSNull null]) ? nil : self.promptDetail;

    managedObject.title = ((id)self.title == [NSNull null]) ? nil : self.title;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSOrderedSet *afterRulesCopy = [managedObject.afterRules copy];

    // now remove all items from the existing relationship
    // to work pre-iOS 10, we have to work around this issue: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    NSMutableOrderedSet *workingAfterRulesSet = [managedObject mutableOrderedSetValueForKey:NSStringFromSelector(@selector(afterRules))];
    [workingAfterRulesSet removeAllObjects];

    // now put the "new" items, if any, into the relationship
    if ([self.afterRules count] > 0) {
		for (SBBSurveyRule *obj in self.afterRules) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [workingAfterRulesSet addObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in afterRulesCopy) {
        if (![relMo valueForKey:@"surveyElement"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    afterRulesCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addAfterRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse
{
    if (self.afterRules == nil)
	{

		self.afterRules = [NSMutableArray array];

	}

	[(NSMutableArray *)self.afterRules addObject:value_];

}

- (void)addAfterRulesObject:(SBBSurveyRule*)value_
{
    [self addAfterRulesObject:(SBBSurveyRule*)value_ settingInverse: YES];
}

- (void)removeAfterRulesObjects
{

    self.afterRules = [NSMutableArray array];

}

- (void)removeAfterRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.afterRules removeObject:value_];

}

- (void)removeAfterRulesObject:(SBBSurveyRule*)value_
{
    [self removeAfterRulesObject:(SBBSurveyRule*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyRule*)value inAfterRulesAtIndex:(NSUInteger)idx {
    [self insertObject:value inAfterRulesAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyRule*)value inAfterRulesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.afterRules insertObject:value atIndex:idx];

}

- (void)removeObjectFromAfterRulesAtIndex:(NSUInteger)idx {
    [self removeObjectFromAfterRulesAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromAfterRulesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyRule *object = [self.afterRules objectAtIndex:idx];
    [self removeAfterRulesObject:object settingInverse:YES];
}

- (void)insertAfterRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertAfterRules:value atIndexes:indexes settingInverse:YES];
}

- (void)insertAfterRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.afterRules insertObjects:value atIndexes:indexes];

}

- (void)removeAfterRulesAtIndexes:(NSIndexSet *)indexes {
    [self removeAfterRulesAtIndexes:indexes settingInverse:YES];
}

- (void)removeAfterRulesAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.afterRules removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInAfterRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value {
    [self replaceObjectInAfterRulesAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInAfterRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.afterRules replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceAfterRulesAtIndexes:(NSIndexSet *)indexes withAfterRules:(NSArray *)value {
    [self replaceAfterRulesAtIndexes:indexes withAfterRules:value settingInverse:YES];
}

- (void)replaceAfterRulesAtIndexes:(NSIndexSet *)indexes withAfterRules:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.afterRules replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
