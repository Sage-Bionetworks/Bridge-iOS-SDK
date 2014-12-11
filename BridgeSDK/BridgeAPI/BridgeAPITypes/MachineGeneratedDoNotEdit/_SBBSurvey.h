//
//  _SBBSurvey.h
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

@end
