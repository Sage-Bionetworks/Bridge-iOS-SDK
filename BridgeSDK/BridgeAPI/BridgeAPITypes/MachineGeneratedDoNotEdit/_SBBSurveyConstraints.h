//
//  SBBSurveyConstraints.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBSurveyRule;
@class SBBSurveyQuestion;

@protocol _SBBSurveyConstraints

@end

@interface _SBBSurveyConstraints : SBBBridgeObject

@property (nonatomic, strong) NSString* dataType;

@property (nonatomic, strong, readonly) NSArray *rules;

@property (nonatomic, strong, readwrite) SBBSurveyQuestion *surveyQuestion;

- (void)addRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse;
- (void)addRulesObject:(SBBSurveyRule*)value_;
- (void)removeRulesObjects;
- (void)removeRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse;
- (void)removeRulesObject:(SBBSurveyRule*)value_;

- (void)insertObject:(SBBSurveyRule*)value inRulesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRulesAtIndex:(NSUInteger)idx;
- (void)insertRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRulesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value;
- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)values;

- (void) setSurveyQuestion: (SBBSurveyQuestion*) surveyQuestion_ settingInverse: (BOOL) setInverse;

@end
