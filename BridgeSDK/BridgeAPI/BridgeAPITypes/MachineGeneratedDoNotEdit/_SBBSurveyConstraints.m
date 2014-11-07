//
//  SBBSurveyConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyConstraints.h instead.
//

#import "_SBBSurveyConstraints.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyRule.h"
#import "SBBSurveyQuestion.h"

@interface _SBBSurveyConstraints()
@property (nonatomic, strong, readwrite) NSArray *rules;

@end

/** \ingroup DataModel */

@implementation _SBBSurveyConstraints

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

        self.dataType = [dictionary objectForKey:@"dataType"];

		for(id objectRepresentationForDict in [dictionary objectForKey:@"rules"])
		{

SBBSurveyRule *rulesObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

			[self addRulesObject:rulesObj];
		}
	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.dataType forKey:@"dataType"];

    if([self.rules count] > 0)
	{

		NSMutableArray *rulesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.rules count]];
		for(SBBSurveyRule *obj in self.rules)
		{
			[rulesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:rulesRepresentationsForDictionary forKey:@"rules"];

	}

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBSurveyRule *rulesObj in self.rules)
	{
		[rulesObj awakeFromDictionaryRepresentationInit];
	}
	[self.surveyQuestion awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void)addRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse
{
    if(self.rules == nil)
	{

		self.rules = [NSMutableArray array];

	}

	[(NSMutableArray *)self.rules addObject:value_];
	if (setInverse == YES) {
	    [value_ setSurveyConstraints: (SBBSurveyConstraints*)self settingInverse: NO];
	}
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
    if (setInverse == YES) {
        [value_ setSurveyConstraints: nil settingInverse: NO];
    }
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
    if (setInverse == YES) {
    [value setSurveyConstraints:(SBBSurveyConstraints*)self settingInverse: NO];
    }
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
    if (setInverse == YES) {
        for (SBBSurveyRule* object in value) {
            [object setSurveyConstraints:(SBBSurveyConstraints*)self settingInverse: NO];
        }
    }
}

- (void)removeRulesAtIndexes:(NSIndexSet *)indexes {
    [self removeRulesAtIndexes:indexes settingInverse:YES];
}

- (void)removeRulesAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsRemoved = [(NSMutableArray *)self.rules objectsAtIndexes:indexes];
        for (SBBSurveyRule* object in objectsRemoved) {
            [object setSurveyConstraints:nil settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.rules removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value {
    [self replaceObjectInRulesAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    SBBSurveyRule* objectReplaced = [(NSMutableArray *)self.rules objectAtIndex:idx];
    [objectReplaced setSurveyConstraints:nil settingInverse: NO];
    [value setSurveyConstraints:(SBBSurveyConstraints*)self settingInverse: NO];
    }
    [(NSMutableArray *)self.rules replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)value {
    [self replaceRulesAtIndexes:indexes withRules:value settingInverse:YES];
}

- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)value settingInverse:(BOOL)setInverse {
    if (setInverse == YES) {
    NSArray *objectsReplaced = [(NSMutableArray *)self.rules objectsAtIndexes:indexes];
        for (SBBSurveyRule* object in objectsReplaced) {
            [object setSurveyConstraints:nil settingInverse: NO];
        }
        for (SBBSurveyRule* object in value) {
            [object setSurveyConstraints:(SBBSurveyConstraints*)self settingInverse: NO];
        }
    }
    [(NSMutableArray *)self.rules replaceObjectsAtIndexes:indexes withObjects:value];
}

- (void) setSurveyQuestion: (SBBSurveyQuestion*) surveyQuestion_ settingInverse: (BOOL) setInverse
{
    if (surveyQuestion_ == nil) {
        [_surveyQuestion setConstraints: nil settingInverse: NO];
    }

    _surveyQuestion = surveyQuestion_;

    if (setInverse == YES) {
        [_surveyQuestion setConstraints: (SBBSurveyConstraints*)self settingInverse: NO];
    }
}

- (void) setSurveyQuestion: (SBBSurveyQuestion*) surveyQuestion_
{
    [self setSurveyQuestion: surveyQuestion_ settingInverse: YES];
}

- (SBBSurveyQuestion*) surveyQuestion
{
    return _surveyQuestion;
}

@synthesize surveyQuestion = _surveyQuestion;

@end
