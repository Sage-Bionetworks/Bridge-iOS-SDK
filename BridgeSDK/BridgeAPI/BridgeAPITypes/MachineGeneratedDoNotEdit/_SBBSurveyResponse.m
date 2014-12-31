//
//  SBBSurveyResponse.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyResponse.h instead.
//

#import "_SBBSurveyResponse.h"
#import "ModelObjectInternal.h"
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

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* startedOn;

@property (nonatomic, strong) NSString* status;

@property (nonatomic, strong, readonly) NSArray *answers;

@property (nonatomic, strong, readwrite) NSManagedObject *survey;

- (void)addAnswersObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addAnswersObject:(NSManagedObject *)value_;
- (void)removeAnswersObjects;
- (void)removeAnswersObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeAnswersObject:(NSManagedObject *)value_;

- (void)insertObject:(NSManagedObject *)value inAnswersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx;
- (void)insertAnswers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)values;

- (void) setSurvey: (NSManagedObject *) survey_ settingInverse: (BOOL) setInverse;

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

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.completedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"completedOn"]];

    self.identifier = [dictionary objectForKey:@"identifier"];

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

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

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

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"SurveyResponse" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.completedOn = managedObject.completedOn;

        self.identifier = managedObject.identifier;

        self.startedOn = managedObject.startedOn;

        self.status = managedObject.status;

		for(NSManagedObject *answersManagedObj in managedObject.answers)
		{
            SBBSurveyAnswer *answersObj = [[SBBSurveyAnswer alloc] initWithManagedObject:answersManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(answersObj != nil)
        {
            [self addAnswersObject:answersObj];
        }
		}
            NSManagedObject *surveyManagedObj = managedObject.survey;
        SBBSurvey *surveyObj = [[SBBSurvey alloc] initWithManagedObject:surveyManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(surveyObj != nil)
        {
          self.survey = surveyObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    __block NSManagedObject *managedObject = nil;

    managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyResponse" inManagedObjectContext:cacheContext];

    managedObject.completedOn = self.completedOn;

    managedObject.identifier = self.identifier;

    managedObject.startedOn = self.startedOn;

    managedObject.status = self.status;

    if([self.answers count] > 0) {
		for(SBBSurveyAnswer *obj in self.answers)
		{
            NSManagedObject *relObj = [obj saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            [managedObject addAnswersObject:relObj];
		}
	}

    NSManagedObject *relObj = [self.survey saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
    [managedObject setSurvey:relObj];

    // Calling code will handle saving these changes to cacheContext.

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
