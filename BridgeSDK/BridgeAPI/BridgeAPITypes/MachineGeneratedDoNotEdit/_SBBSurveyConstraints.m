//
//  _SBBSurveyConstraints.m
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
// Make changes to SBBSurveyConstraints.m instead.
//

#import "_SBBSurveyConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyRule.h"

@interface _SBBSurveyConstraints()

// redefine relationships internally as readwrite

@property (nonatomic, strong, readwrite) NSArray *rules;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (SurveyConstraints)

@property (nullable, nonatomic, retain) NSString* dataType;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *rules;

@property (nullable, nonatomic, retain) NSManagedObject *surveyQuestion;

- (void)addRulesObject:(NSManagedObject *)value;
- (void)removeRulesObject:(NSManagedObject *)value;
- (void)addRules:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeRules:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inRulesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRulesAtIndex:(NSUInteger)idx;
- (void)insertRules:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRulesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray<NSManagedObject *> *)values;

@end

@implementation _SBBSurveyConstraints

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

    self.dataType = [dictionary objectForKey:@"dataType"];

    // overwrite the old rules relationship entirely rather than adding to it
    [self removeRulesObjects];

    for (id dictRepresentationForObject in [dictionary objectForKey:@"rules"])
    {
        SBBSurveyRule *rulesObj = [objectManager objectFromBridgeJSON:dictRepresentationForObject];

        [self addRulesObject:rulesObj];
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.dataType forKey:@"dataType"];

    if ([self.rules count] > 0)
	{

		NSMutableArray *rulesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.rules count]];

		for (SBBSurveyRule *obj in self.rules)
        {
            [rulesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:rulesRepresentationsForDictionary forKey:@"rules"];

	}

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for (SBBSurveyRule *rulesObj in self.rules)
	{
		[rulesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"SurveyConstraints";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.dataType = managedObject.dataType;

		for (NSManagedObject *rulesManagedObj in managedObject.rules)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:rulesManagedObj.entity.name];
            SBBSurveyRule *rulesObj = [[objectClass alloc] initWithManagedObject:rulesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if (rulesObj != nil)
            {
                [self addRulesObject:rulesObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyConstraints" inManagedObjectContext:cacheContext];
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

    managedObject.dataType = ((id)self.dataType == [NSNull null]) ? nil : self.dataType;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    NSOrderedSet *rulesCopy = [managedObject.rules copy];

    // now remove all items from the existing relationship
    // to work pre-iOS 10, we have to work around this issue: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    NSMutableOrderedSet *workingRulesSet = [managedObject mutableOrderedSetValueForKey:NSStringFromSelector(@selector(rules))];
    [workingRulesSet removeAllObjects];

    // now put the "new" items, if any, into the relationship
    if ([self.rules count] > 0) {
		for (SBBSurveyRule *obj in self.rules) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }

            [workingRulesSet addObject:relMo];

        }
	}

    // now release any objects that aren't still in the relationship (they will be deleted when they no longer belong to any to-many relationships)
    for (NSManagedObject *relMo in rulesCopy) {
        if (![relMo valueForKey:@"surveyConstraints"]) {
           [self releaseManagedObject:relMo inContext:cacheContext];
        }
    }

    // ...and let go of the collection copy
    rulesCopy = nil;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse
{
    if (self.rules == nil)
	{

		self.rules = [NSMutableArray array];

	}

	[(NSMutableArray *)self.rules addObject:value_];

}

- (void)addRulesObject:(SBBSurveyRule*)value_
{
    [self addRulesObject:(SBBSurveyRule*)value_ settingInverse: YES];
}

- (void)removeRulesObjects
{

    self.rules = [NSMutableArray array];

}

- (void)removeRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.rules removeObject:value_];

}

- (void)removeRulesObject:(SBBSurveyRule*)value_
{
    [self removeRulesObject:(SBBSurveyRule*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyRule*)value inRulesAtIndex:(NSUInteger)idx {
    [self insertObject:value inRulesAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyRule*)value inRulesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules insertObject:value atIndex:idx];

}

- (void)removeObjectFromRulesAtIndex:(NSUInteger)idx {
    [self removeObjectFromRulesAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromRulesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyRule *object = [self.rules objectAtIndex:idx];
    [self removeRulesObject:object settingInverse:YES];
}

- (void)insertRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertRules:value atIndexes:indexes settingInverse:YES];
}

- (void)insertRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.rules insertObjects:value atIndexes:indexes];

}

- (void)removeRulesAtIndexes:(NSIndexSet *)indexes {
    [self removeRulesAtIndexes:indexes settingInverse:YES];
}

- (void)removeRulesAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value {
    [self replaceObjectInRulesAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)value {
    [self replaceRulesAtIndexes:indexes withRules:value settingInverse:YES];
}

- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
