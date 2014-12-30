//
//  SBBSurvey.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurvey.h instead.
//

#import "_SBBSurvey.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyQuestion.h"

@interface _SBBSurvey()
@property (nonatomic, strong, readwrite) NSArray *questions;

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

- (void)addQuestionsObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addQuestionsObject:(NSManagedObject *)value_;
- (void)removeQuestionsObjects;
- (void)removeQuestionsObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeQuestionsObject:(NSManagedObject *)value_;

- (void)insertObject:(NSManagedObject *)value inQuestionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromQuestionsAtIndex:(NSUInteger)idx;
- (void)insertQuestions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray *)values;

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

	for(SBBSurveyQuestion *questionsObj in self.questions)
	{
		[questionsObj awakeFromDictionaryRepresentationInit];
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

        self.identifier = managedObject.identifier;

        self.modifiedOn = managedObject.modifiedOn;

        self.name = managedObject.name;

        self.published = managedObject.published;

        self.version = managedObject.version;

		for(NSManagedObject *questionsManagedObj in managedObject.questions)
		{
            SBBSurveyQuestion *questionsObj = [[SBBSurveyQuestion alloc] initWithManagedObject:questionsManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(questionsObj != nil)
        {
            [self addQuestionsObject:questionsObj];
        }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    __block NSManagedObject *managedObject = nil;

    managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Survey" inManagedObjectContext:cacheContext];

    managedObject.createdOn = self.createdOn;

    managedObject.guid = self.guid;

    managedObject.identifier = self.identifier;

    managedObject.modifiedOn = self.modifiedOn;

    managedObject.name = self.name;

    managedObject.published = self.published;

    managedObject.version = self.version;

    if([self.questions count] > 0) {
		for(SBBSurveyQuestion *obj in self.questions)
		{
            NSManagedObject *relObj = [obj saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            [managedObject addQuestionsObject:relObj];
		}
	}

    // Calling code will handle saving these changes to cacheContext.

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

}

- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes {
    [self removeQuestionsAtIndexes:indexes settingInverse:YES];
}

- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.questions removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestion*)value {
    [self replaceObjectInQuestionsAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestion*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.questions replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray *)value {
    [self replaceQuestionsAtIndexes:indexes withQuestions:value settingInverse:YES];
}

- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.questions replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
