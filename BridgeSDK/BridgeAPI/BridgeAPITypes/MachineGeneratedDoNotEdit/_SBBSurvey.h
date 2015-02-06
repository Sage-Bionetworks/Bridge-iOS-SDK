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

@class SBBSurveyElement;
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

@property (nonatomic, strong, readonly) NSArray *elements;

@property (nonatomic, strong, readonly) NSArray *surveyResponses;

- (void)addElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse;
- (void)addElementsObject:(SBBSurveyElement*)value_;
- (void)removeElementsObjects;
- (void)removeElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse;
- (void)removeElementsObject:(SBBSurveyElement*)value_;

- (void)insertObject:(SBBSurveyElement*)value inElementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx;
- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeElementsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value;
- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)values;

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
