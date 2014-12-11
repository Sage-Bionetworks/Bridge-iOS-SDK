//
//  _SBBSurveyResponse.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyResponse.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

#import "SBBSurvey.h"

@class SBBSurveyAnswer;
@class SBBSurvey;

@protocol _SBBSurveyResponse

@end

@interface _SBBSurveyResponse : SBBBridgeObject

@property (nonatomic, strong) NSDate* completedOn;

@property (nonatomic, strong) NSString* identifier;

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
