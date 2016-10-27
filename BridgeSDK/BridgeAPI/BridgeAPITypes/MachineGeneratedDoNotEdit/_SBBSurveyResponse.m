//
//  _SBBSurveyResponse.m
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
// Make changes to SBBSurveyResponse.m instead.
//

#import "_SBBSurveyResponse.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyAnswer.h"
#import "SBBSurvey.h"

@interface _SBBSurveyResponse()
@property (nonatomic, strong, readwrite) NSArray *answers;

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (SurveyResponse)

@property (nullable, nonatomic, retain) NSDate* completedOn;

@property (nullable, nonatomic, retain) NSString* identifier;

@property (nullable, nonatomic, retain) NSDate* startedOn;

@property (nullable, nonatomic, retain) NSString* status;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *answers;

@property (nullable, nonatomic, retain) NSManagedObject *survey;

- (void)addAnswersObject:(NSManagedObject *)value;
- (void)removeAnswersObject:(NSManagedObject *)value;
- (void)addAnswers:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeAnswers:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inAnswersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx;
- (void)insertAnswers:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray<NSManagedObject *> *)values;

@end

@implementation _SBBSurveyResponse

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.completedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"completedOn"]];

    self.identifier = [dictionary objectForKey:@"identifier"];

    self.startedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startedOn"]];

    self.status = [dictionary objectForKey:@"status"];

    // overwrite the old answers relationship entirely rather than adding to it
    self.answers = [NSMutableArray array];

    for(id objectRepresentationForDict in [dictionary objectForKey:@"answers"])
    {
        SBBSurveyAnswer *answersObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addAnswersObject:answersObj];
    }
        NSDictionary *surveyDict = [dictionary objectForKey:@"survey"];
    if(surveyDict != nil)
    {
        SBBSurvey *surveyObj = [objectManager objectFromBridgeJSON:surveyDict];
        self.survey = surveyObj;

    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:[self.completedOn ISO8601String] forKey:@"completedOn"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:[self.startedOn ISO8601String] forKey:@"startedOn"];

    [dict setObjectIfNotNil:self.status forKey:@"status"];

    if([self.answers count] > 0)
	{

		NSMutableArray *answersRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.answers count]];
		for(SBBSurveyAnswer *obj in self.answers)
		{
			[answersRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:answersRepresentationsForDictionary forKey:@"answers"];

	}

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.survey] forKey:@"survey"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.survey awakeFromDictionaryRepresentationInit];

	for(SBBSurveyAnswer *answersObj in self.answers)
	{
		[answersObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"SurveyResponse";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.completedOn = managedObject.completedOn;

        self.identifier = managedObject.identifier;

        self.startedOn = managedObject.startedOn;

        self.status = managedObject.status;

		for(NSManagedObject *answersManagedObj in managedObject.answers)
		{
            Class objectClass = [SBBObjectManager bridgeClassFromType:answersManagedObj.entity.name];
            SBBSurveyAnswer *answersObj = [[objectClass alloc] initWithManagedObject:answersManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(answersObj != nil)
            {
                [self addAnswersObject:answersObj];
            }
		}
            NSManagedObject *surveyManagedObj = managedObject.survey;
        Class surveyClass = [SBBObjectManager bridgeClassFromType:surveyManagedObj.entity.name];
        SBBSurvey *surveyObj = [[surveyClass alloc] initWithManagedObject:surveyManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(surveyObj != nil)
        {
          self.survey = surveyObj;
        }
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyResponse" inManagedObjectContext:cacheContext];
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

    managedObject.completedOn = ((id)self.completedOn == [NSNull null]) ? nil : self.completedOn;

    managedObject.identifier = ((id)self.identifier == [NSNull null]) ? nil : self.identifier;

    managedObject.startedOn = ((id)self.startedOn == [NSNull null]) ? nil : self.startedOn;

    managedObject.status = ((id)self.status == [NSNull null]) ? nil : self.status;

    // first make a copy of the existing relationship collection, to iterate through while mutating original
    id answersCopy = managedObject.answers;

    // now remove all items from the existing relationship
    NSMutableOrderedSet *answersSet = [managedObject.answers mutableCopy];
    [answersSet removeAllObjects];
    managedObject.answers = answersSet;

    // now put the "new" items, if any, into the relationship
    if([self.answers count] > 0) {
		for(SBBSurveyAnswer *obj in self.answers) {
            NSManagedObject *relMo = nil;
            if ([obj isDirectlyCacheableWithContext:cacheContext]) {
                // get it from the cache manager
                relMo = [cacheManager cachedObjectForBridgeObject:obj inContext:cacheContext];
            }
            if (!relMo) {
                // sub object is not directly cacheable, or not currently cached, so create it before adding
                relMo = [obj createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            }
            NSMutableOrderedSet *answersSet = [managedObject mutableOrderedSetValueForKey:@"answers"];
            [answersSet addObject:relMo];
            managedObject.answers = answersSet;

        }
	}

    // now delete any objects that aren't still in the relationship
    for (NSManagedObject *relMo in answersCopy) {
        if (![relMo valueForKey:@"surveyResponse"]) {
           [cacheContext deleteObject:relMo];
        }
    }

    // ...and let go of the collection copy
    answersCopy = nil;

    // destination entity Survey is directly cacheable, so get it from cache manager
    NSManagedObject *relMoSurvey = [cacheManager cachedObjectForBridgeObject:self.survey inContext:cacheContext];

    [managedObject setSurvey:relMoSurvey];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: (BOOL) setInverse
{
    if(self.answers == nil)
	{

		self.answers = [NSMutableArray array];

	}

	[(NSMutableArray *)self.answers addObject:value_];

}
- (void)addAnswersObject:(SBBSurveyAnswer*)value_
{
    [self addAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: YES];
}

- (void)removeAnswersObjects
{

	self.answers = [NSMutableArray array];

}

- (void)removeAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.answers removeObject:value_];
}

- (void)removeAnswersObject:(SBBSurveyAnswer*)value_
{
    [self removeAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyAnswer*)value inAnswersAtIndex:(NSUInteger)idx {
    [self insertObject:value inAnswersAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyAnswer*)value inAnswersAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.answers insertObject:value atIndex:idx];

}

- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx {
    [self removeObjectFromAnswersAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyAnswer *object = [self.answers objectAtIndex:idx];
    [self removeAnswersObject:object settingInverse:YES];
}

- (void)insertAnswers:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertAnswers:value atIndexes:indexes settingInverse:YES];
}

- (void)insertAnswers:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.answers insertObjects:value atIndexes:indexes];

}

- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes {
    [self removeAnswersAtIndexes:indexes settingInverse:YES];
}

- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.answers removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(SBBSurveyAnswer*)value {
    [self replaceObjectInAnswersAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(SBBSurveyAnswer*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.answers replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)value {
    [self replaceAnswersAtIndexes:indexes withAnswers:value settingInverse:YES];
}

- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.answers replaceObjectsAtIndexes:indexes withObjects:value];
}

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse
{

    _survey = survey_;

}

- (void) setSurvey: (SBBSurvey*) survey_
{
    [self setSurvey: survey_ settingInverse: YES];
}

- (SBBSurvey*) survey
{
    return _survey;
}

@synthesize survey = _survey;

@end
