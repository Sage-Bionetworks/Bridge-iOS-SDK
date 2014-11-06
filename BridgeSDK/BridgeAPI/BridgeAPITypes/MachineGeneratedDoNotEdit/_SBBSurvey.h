//
//  SBBSurvey.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurvey.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBSurveyQuestion;
@class SBBSurveyResponse;

@protocol _SBBSurvey

@end

@interface _SBBSurvey : SBBBridgeObject

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* modifiedOn;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSNumber* published;

@property (nonatomic, assign) BOOL publishedValue;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) double versionValue;

@property (nonatomic, strong) NSDate* versionedOn;

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
