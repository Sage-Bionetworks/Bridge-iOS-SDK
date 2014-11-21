//
//  SBBSurveyResponse.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyResponse.h instead.
//

#import "_SBBSurveyResponse.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyAnswer.h"
#import "SBBSurvey.h"

@interface _SBBSurveyResponse()
@property (nonatomic, strong, readwrite) NSArray *answers;

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyResponse)

@property (nonatomic, strong) NSDate* completedOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSDate* startedOn;

@property (nonatomic, strong) NSString* status;

@property (nonatomic, strong, readonly) NSArray *answers;

@property (nonatomic, strong, readwrite) SBBSurvey *survey;

- (void)addAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: (BOOL) setInverse;
- (void)addAnswersObject:(SBBSurveyAnswer*)value_;
- (void)removeAnswersObjects;
- (void)removeAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: (BOOL) setInverse;
- (void)removeAnswersObject:(SBBSurveyAnswer*)value_;

- (void)insertObject:(SBBSurveyAnswer*)value inAnswersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx;
- (void)insertAnswers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(SBBSurveyAnswer*)value;
- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)values;

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse;

@end

/** \ingroup DataModel */

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

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.completedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"completedOn"]];

        self.guid = [dictionary objectForKey:@"guid"];

        self.startedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startedOn"]];

        self.status = [dictionary objectForKey:@"status"];

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

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:[self.completedOn ISO8601String] forKey:@"completedOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

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

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBSurveyAnswer *answersObj in self.answers)
	{
		[answersObj awakeFromDictionaryRepresentationInit];
	}
	[self.survey awakeFromDictionaryRepresentationInit];

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

        self.completedOn = managedObject.completedOn;

        self.guid = managedObject.guid;

        self.startedOn = managedObject.startedOn;

        self.status = managedObject.status;

		for(NSManagedObject *answersManagedObj in managedObject.answers)
		{
        SBBSurveyAnswer *answersObj = [[SBBSurveyAnswer alloc] initWithManagedObject:answersManagedObj];
        if(answersObj != nil)
        {
            [self addAnswersObject:answersObj];
        }
		}
            SBBSurvey *surveyManagedObj = managedObject.survey;
        SBBSurvey *surveyObj = [[SBBSurvey alloc] initWithManagedObject:surveyManagedObj];
        if(surveyObj != nil)
        {
          self.survey = surveyObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    [cacheContext performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyResponse" inManagedObjectContext:cacheContext];
    }];

    managedObject.completedOn = self.completedOn;

    managedObject.guid = self.guid;

    managedObject.startedOn = self.startedOn;

    managedObject.status = self.status;

    if([self.answers count] > 0)
	{

		for(SBBSurveyAnswer *obj in self.answers)
		{
        NSManagedObject *relObj = [obj saveToContext:cacheContext withObjectManager:objectManager];
        [managedObject addAnswersObject:relObj];
		}

	}

    NSManagedObject *relObj = [self.survey saveToContext:cacheContext withObjectManager:objectManager];
    [managedObject setSurvey:relObj];

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

- (void)addAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: (BOOL) setInverse
{
    if(self.answers == nil)
	{

		self.answers = [NSMutableArray array];

	}

	[(NSMutableArray *)self.answers addObject:value_];
	if (setInverse == YES) {
	    [value_ setSurveyResponse: (SBBSurveyResponse*)self settingInverse: NO];
	}
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
    if (setInverse == YES) {
        [value_ setSurveyResponse: nil settingInverse: NO];
    }
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
    if (setInverse == YES) {
    [value setSurveyResponse:(SBBSurveyResponse*)self settingInverse: NO];
    }
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
    if (setInverse == YES) {
        for (SBBSurveyAnswer* object in value) {
            [object setSurveyResponse:(SBBSurveyResponse*)self settingInverse: NO];
        }
    }
}

- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes {
    [self removeAnswersAtIndexes:indexes settingInverse:YES];
}

- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsRemoved = [(NSMutableArray *)self.answers objectsAtIndexes:indexes];
        for (SBBSurveyAnswer* object in objectsRemoved) {
            [object setSurveyResponse:nil settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.answers removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(SBBSurveyAnswer*)value {
    [self replaceObjectInAnswersAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(SBBSurveyAnswer*)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    SBBSurveyAnswer* objectReplaced = [(NSMutableArray *)self.answers objectAtIndex:idx];
    [objectReplaced setSurveyResponse:nil settingInverse: NO];
    [value setSurveyResponse:(SBBSurveyResponse*)self settingInverse: NO];
    }
    [(NSMutableArray *)self.answers replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)value {
    [self replaceAnswersAtIndexes:indexes withAnswers:value settingInverse:YES];
}

- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsReplaced = [(NSMutableArray *)self.answers objectsAtIndexes:indexes];
        for (SBBSurveyAnswer* object in objectsReplaced) {
            [object setSurveyResponse:nil settingInverse: NO];
        }
        for (SBBSurveyAnswer* object in value) {
            [object setSurveyResponse:(SBBSurveyResponse*)self settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.answers replaceObjectsAtIndexes:indexes withObjects:value];
}

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse
{
    if (survey_ == nil) {
        [_survey removeSurveyResponsesObject: (SBBSurveyResponse*)self settingInverse: NO];
    }

    _survey = survey_;

    if (setInverse == YES) {
        [_survey addSurveyResponsesObject: (SBBSurveyResponse*)self settingInverse: NO];
    }
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
