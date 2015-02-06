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

#import "SBBSurveyElement.h"
#import "SBBSurveyResponse.h"

@interface _SBBSurvey()
@property (nonatomic, strong, readwrite) NSArray *elements;
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

        self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

        self.guid = [dictionary objectForKey:@"guid"];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

        self.name = [dictionary objectForKey:@"name"];

        self.published = [dictionary objectForKey:@"published"];

        self.version = [dictionary objectForKey:@"version"];

		for(id objectRepresentationForDict in [dictionary objectForKey:@"elements"])
		{

SBBSurveyElement *elementsObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

			[self addElementsObject:elementsObj];
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

	for(SBBSurveyResponse *surveyResponsesObj in self.surveyResponses)
	{
		[surveyResponsesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void)addElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse
{
    if(self.elements == nil)
	{

		self.elements = [NSMutableArray array];

	}

	[(NSMutableArray *)self.elements addObject:value_];
	if (setInverse == YES) {
	    [value_ setSurvey: (SBBSurvey*)self settingInverse: NO];
	}
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
    if (setInverse == YES) {
        [value_ setSurvey: nil settingInverse: NO];
    }
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
    if (setInverse == YES) {
    [value setSurvey:(SBBSurvey*)self settingInverse: NO];
    }
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
    if (setInverse == YES) {
        for (SBBSurveyElement* object in value) {
            [object setSurvey:(SBBSurvey*)self settingInverse: NO];
        }
    }
}

- (void)removeElementsAtIndexes:(NSIndexSet *)indexes {
    [self removeElementsAtIndexes:indexes settingInverse:YES];
}

- (void)removeElementsAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsRemoved = [(NSMutableArray *)self.elements objectsAtIndexes:indexes];
        for (SBBSurveyElement* object in objectsRemoved) {
            [object setSurvey:nil settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.elements removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value {
    [self replaceObjectInElementsAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    SBBSurveyElement* objectReplaced = [(NSMutableArray *)self.elements objectAtIndex:idx];
    [objectReplaced setSurvey:nil settingInverse: NO];
    [value setSurvey:(SBBSurvey*)self settingInverse: NO];
    }
    [(NSMutableArray *)self.elements replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)value {
    [self replaceElementsAtIndexes:indexes withElements:value settingInverse:YES];
}

- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsReplaced = [(NSMutableArray *)self.elements objectsAtIndexes:indexes];
        for (SBBSurveyElement* object in objectsReplaced) {
            [object setSurvey:nil settingInverse: NO];
        }
        for (SBBSurveyElement* object in value) {
            [object setSurvey:(SBBSurvey*)self settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.elements replaceObjectsAtIndexes:indexes withObjects:value];
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
