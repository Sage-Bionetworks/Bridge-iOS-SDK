//
//  SBBSurveyQuestion.h
//	
//  $Id$
//

#import "_SBBSurveyQuestion.h"

@interface SBBSurveyQuestion : _SBBSurveyQuestion <_SBBSurveyQuestion>
// Custom logic goes here.

//Adding this property for backward compatibility with shipped surveys
//Will be removed in future
@property (nonatomic, strong) NSString* detail;

@end
