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

        self.guid = [dictionary objectForKey:@"guid"];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

        self.name = [dictionary objectForKey:@"name"];

        self.published = [dictionary objectForKey:@"published"];

        self.version = [dictionary objectForKey:@"version"];

        self.versionedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"versionedOn"]];

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

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:[self.modifiedOn ISO8601String] forKey:@"modifiedOn"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

    [dict setObjectIfNotNil:self.published forKey:@"published"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

    [dict setObjectIfNotNil:[self.versionedOn ISO8601String] forKey:@"versionedOn"];

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
