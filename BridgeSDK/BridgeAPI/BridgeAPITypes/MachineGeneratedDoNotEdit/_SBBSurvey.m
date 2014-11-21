//
//  SBBSurvey.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurvey.h instead.
//

#import "_SBBSurvey.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyQuestion.h"
#import "SBBSurveyResponse.h"

@interface _SBBSurvey()
@property (nonatomic, strong, readwrite) NSArray *questions;
@property (nonatomic, strong, readwrite) NSArray *surveyResponses;

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (Survey)

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* modifiedOn;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSNumber* published;

@property (nonatomic, assign) BOOL publishedValue;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) double versionValue;

@property (nonatomic, strong, readonly) NSArray *questions;

@property (nonatomic, strong, readonly) NSArray *surveyResponses;

- (void)addQuestionsObject:(SBBSurveyQuestion*)value_ settingInverse: (BOOL) setInverse;
- (void)addQuestionsObject:(SBBSurveyQuestion*)value_;
- (void)removeQuestionsObjects;
- (void)removeQuestionsObject:(SBBSurveyQuestion*)value_ settingInverse: (BOOL) setInverse;
- (void)removeQuestionsObject:(SBBSurveyQuestion*)value_;

- (void)insertObject:(SBBSurveyQuestion*)value inQuestionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromQuestionsAtIndex:(NSUInteger)idx;
- (void)insertQuestions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestion*)value;
- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray *)values;

- (void)addSurveyResponsesObject:(SBBSurveyResponse*)value_ settingInverse: (BOOL) setInverse;
- (void)addSurveyResponsesObject:(SBBSurveyResponse*)value_;
- (void)removeSurveyResponsesObjects;
- (void)removeSurveyResponsesObject:(SBBSurveyResponse*)value_ settingInverse: (BOOL) setInverse;
- (void)removeSurveyResponsesObject:(SBBSurveyResponse*)value_;

- (void)insertObject:(SBBSurveyResponse*)value inSurveyResponsesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSurveyResponsesAtIndex:(NSUInteger)idx;
- (void)insertSurveyResponses:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSurveyResponsesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSurveyResponsesAtIndex:(NSUInteger)idx withObject:(SBBSurveyResponse*)value;
- (void)replaceSurveyResponsesAtIndexes:(NSIndexSet *)indexes withSurveyResponses:(NSArray *)values;

@end

/** \ingroup DataModel */

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

- (double)versionValue
{
	return [self.version doubleValue];
}

- (void)setVersionValue:(double)value_
{
	self.version = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

        self.guid = [dictionary objectForKey:@"guid"];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

        self.name = [dictionary objectForKey:@"name"];

        self.published = [dictionary objectForKey:@"published"];

        self.version = [dictionary objectForKey:@"version"];

		for(id objectRepresentationForDict in [dictionary objectForKey:@"questions"])
		{

SBBSurveyQuestion *questionsObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

			[self addQuestionsObject:questionsObj];
		}
	}

	return self;
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

    [dict setObjectIfNotNil:self.version forKey:@"version"];

    if([self.questions count] > 0)
	{

		NSMutableArray *questionsRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.questions count]];
		for(SBBSurveyQuestion *obj in self.questions)
		{
			[questionsRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:questionsRepresentationsForDictionary forKey:@"questions"];

	}

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBSurveyResponse *surveyResponsesObj in self.surveyResponses)
	{
		[surveyResponsesObj awakeFromDictionaryRepresentationInit];
	}

	for(SBBSurveyQuestion *questionsObj in self.questions)
	{
		[questionsObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (instancetype)initFromCoreDataCacheWithID:(NSString *)bridgeObjectID
{
    // TODO: get managed object from cache

    // create PONSO object from managed object
    return [self initWithManagedObject:managedObject];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{

    if (self == [super init]) {

        self.createdOn = managedObject.createdOn;

        self.guid = managedObject.guid;

        self.identifier = managedObject.identifier;

        self.modifiedOn = managedObject.modifiedOn;

        self.name = managedObject.name;

        self.published = managedObject.published;

        self.version = managedObject.version;

		for(NSManagedObject *questionsManagedObj in managedObject.questions)
		{
        SBBSurveyQuestion *questionsObj = [[SBBSurveyQuestion alloc] initWithManagedObject:questionsManagedObj];
        if(questionsObj != nil)
        {
            [self addQuestionsObject:questionsObj];
        }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    [cacheContext performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Survey" inManagedObjectContext:cacheContext];
    }];

    managedObject.createdOn = self.createdOn;

    managedObject.guid = self.guid;

    managedObject.identifier = self.identifier;

    managedObject.modifiedOn = self.modifiedOn;

    managedObject.name = self.name;

    managedObject.published = self.published;

    managedObject.version = self.version;

    if([self.questions count] > 0)
	{

		for(SBBSurveyQuestion *obj in self.questions)
		{
        NSManagedObject *relObj = [obj saveToContext:cacheContext withObjectManager:objectManager];
        [managedObject addQuestionsObject:relObj];
		}

	}

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

- (void)addQuestionsObject:(SBBSurveyQuestion*)value_ settingInverse: (BOOL) setInverse
{
    if(self.questions == nil)
	{

		self.questions = [NSMutableArray array];

	}

	[(NSMutableArray *)self.questions addObject:value_];
	if (setInverse == YES) {
	    [value_ setSurvey: (SBBSurvey*)self settingInverse: NO];
	}
}
- (void)addQuestionsObject:(SBBSurveyQuestion*)value_
{
    [self addQuestionsObject:(SBBSurveyQuestion*)value_ settingInverse: YES];
}

- (void)removeQuestionsObjects
{

	self.questions = [NSMutableArray array];

}

- (void)removeQuestionsObject:(SBBSurveyQuestion*)value_ settingInverse: (BOOL) setInverse
{
    if (setInverse == YES) {
        [value_ setSurvey: nil settingInverse: NO];
    }
    [(NSMutableArray *)self.questions removeObject:value_];
}

- (void)removeQuestionsObject:(SBBSurveyQuestion*)value_
{
    [self removeQuestionsObject:(SBBSurveyQuestion*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyQuestion*)value inQuestionsAtIndex:(NSUInteger)idx {
    [self insertObject:value inQuestionsAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyQuestion*)value inQuestionsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.questions insertObject:value atIndex:idx];
    if (setInverse == YES) {
    [value setSurvey:(SBBSurvey*)self settingInverse: NO];
    }
}

- (void)removeObjectFromQuestionsAtIndex:(NSUInteger)idx {
    [self removeObjectFromQuestionsAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromQuestionsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyQuestion *object = [self.questions objectAtIndex:idx];
    [self removeQuestionsObject:object settingInverse:YES];
}

- (void)insertQuestions:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertQuestions:value atIndexes:indexes settingInverse:YES];
}

- (void)insertQuestions:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.questions insertObjects:value atIndexes:indexes];
    if (setInverse == YES) {
        for (SBBSurveyQuestion* object in value) {
            [object setSurvey:(SBBSurvey*)self settingInverse: NO];
        }
    }
}

- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes {
    [self removeQuestionsAtIndexes:indexes settingInverse:YES];
}

- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsRemoved = [(NSMutableArray *)self.questions objectsAtIndexes:indexes];
        for (SBBSurveyQuestion* object in objectsRemoved) {
            [object setSurvey:nil settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.questions removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestion*)value {
    [self replaceObjectInQuestionsAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestion*)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    SBBSurveyQuestion* objectReplaced = [(NSMutableArray *)self.questions objectAtIndex:idx];
    [objectReplaced setSurvey:nil settingInverse: NO];
    [value setSurvey:(SBBSurvey*)self settingInverse: NO];
    }
    [(NSMutableArray *)self.questions replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray *)value {
    [self replaceQuestionsAtIndexes:indexes withQuestions:value settingInverse:YES];
}

- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray *)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsReplaced = [(NSMutableArray *)self.questions objectsAtIndexes:indexes];
        for (SBBSurveyQuestion* object in objectsReplaced) {
            [object setSurvey:nil settingInverse: NO];
        }
        for (SBBSurveyQuestion* object in value) {
            [object setSurvey:(SBBSurvey*)self settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.questions replaceObjectsAtIndexes:indexes withObjects:value];
}

- (void)addSurveyResponsesObject:(SBBSurveyResponse*)value_ settingInverse: (BOOL) setInverse
{
    if(self.surveyResponses == nil)
	{

		self.surveyResponses = [NSMutableArray array];

	}

	[(NSMutableArray *)self.surveyResponses addObject:value_];
	if (setInverse == YES) {
	    [value_ setSurvey: (SBBSurvey*)self settingInverse: NO];
	}
}
- (void)addSurveyResponsesObject:(SBBSurveyResponse*)value_
{
    [self addSurveyResponsesObject:(SBBSurveyResponse*)value_ settingInverse: YES];
}

- (void)removeSurveyResponsesObjects
{

	self.surveyResponses = [NSMutableArray array];

}

- (void)removeSurveyResponsesObject:(SBBSurveyResponse*)value_ settingInverse: (BOOL) setInverse
{
    if (setInverse == YES) {
        [value_ setSurvey: nil settingInverse: NO];
    }
    [(NSMutableArray *)self.surveyResponses removeObject:value_];
}

- (void)removeSurveyResponsesObject:(SBBSurveyResponse*)value_
{
    [self removeSurveyResponsesObject:(SBBSurveyResponse*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyResponse*)value inSurveyResponsesAtIndex:(NSUInteger)idx {
    [self insertObject:value inSurveyResponsesAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyResponse*)value inSurveyResponsesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.surveyResponses insertObject:value atIndex:idx];
    if (setInverse == YES) {
    [value setSurvey:(SBBSurvey*)self settingInverse: NO];
    }
}

- (void)removeObjectFromSurveyResponsesAtIndex:(NSUInteger)idx {
    [self removeObjectFromSurveyResponsesAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromSurveyResponsesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyResponse *object = [self.surveyResponses objectAtIndex:idx];
    [self removeSurveyResponsesObject:object settingInverse:YES];
}

- (void)insertSurveyResponses:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertSurveyResponses:value atIndexes:indexes settingInverse:YES];
}

- (void)insertSurveyResponses:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.surveyResponses insertObjects:value atIndexes:indexes];
    if (setInverse == YES) {
        for (SBBSurveyResponse* object in value) {
            [object setSurvey:(SBBSurvey*)self settingInverse: NO];
        }
    }
}

- (void)removeSurveyResponsesAtIndexes:(NSIndexSet *)indexes {
    [self removeSurveyResponsesAtIndexes:indexes settingInverse:YES];
}

- (void)removeSurveyResponsesAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsRemoved = [(NSMutableArray *)self.surveyResponses objectsAtIndexes:indexes];
        for (SBBSurveyResponse* object in objectsRemoved) {
            [object setSurvey:nil settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.surveyResponses removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInSurveyResponsesAtIndex:(NSUInteger)idx withObject:(SBBSurveyResponse*)value {
    [self replaceObjectInSurveyResponsesAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInSurveyResponsesAtIndex:(NSUInteger)idx withObject:(SBBSurveyResponse*)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    SBBSurveyResponse* objectReplaced = [(NSMutableArray *)self.surveyResponses objectAtIndex:idx];
    [objectReplaced setSurvey:nil settingInverse: NO];
    [value setSurvey:(SBBSurvey*)self settingInverse: NO];
    }
    [(NSMutableArray *)self.surveyResponses replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceSurveyResponsesAtIndexes:(NSIndexSet *)indexes withSurveyResponses:(NSArray *)value {
    [self replaceSurveyResponsesAtIndexes:indexes withSurveyResponses:value settingInverse:YES];
}

- (void)replaceSurveyResponsesAtIndexes:(NSIndexSet *)indexes withSurveyResponses:(NSArray *)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsReplaced = [(NSMutableArray *)self.surveyResponses objectsAtIndexes:indexes];
        for (SBBSurveyResponse* object in objectsReplaced) {
            [object setSurvey:nil settingInverse: NO];
        }
        for (SBBSurveyResponse* object in value) {
            [object setSurvey:(SBBSurvey*)self settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.surveyResponses replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
