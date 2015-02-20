//
//  SBBSurveyQuestion.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestion.h instead.
//

#import "_SBBSurveyQuestion.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyConstraints.h"

@interface _SBBSurveyQuestion()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyQuestion

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

        self.uiHint = [dictionary objectForKey:@"uiHint"];

            NSDictionary *constraintsDict = [dictionary objectForKey:@"constraints"];
		if(constraintsDict != nil)
		{
			SBBSurveyConstraints *constraintsObj = [objectManager objectFromBridgeJSON:constraintsDict];
			self.constraints = constraintsObj;

		}
	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.uiHint forKey:@"uiHint"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.constraints] forKey:@"constraints"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.constraints awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setConstraints: (SBBSurveyConstraints*) constraints_ settingInverse: (BOOL) setInverse
{
    if (constraints_ == nil) {
        [_constraints setSurveyQuestion: nil settingInverse: NO];
    }

    _constraints = constraints_;

    if (setInverse == YES) {
        [_constraints setSurveyQuestion: (SBBSurveyQuestion*)self settingInverse: NO];
    }
}

- (void) setConstraints: (SBBSurveyConstraints*) constraints_
{
    [self setConstraints: constraints_ settingInverse: YES];
}

- (SBBSurveyConstraints*) constraints
{
    return _constraints;
}

@synthesize constraints = _constraints;

@end
