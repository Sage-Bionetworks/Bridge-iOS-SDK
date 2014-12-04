//
//  SBBSurveyRule.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyRule.h instead.
//

#import "_SBBSurveyRule.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyConstraints.h"

@interface _SBBSurveyRule()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyRule)

@property (nonatomic, strong) NSString* operator;

@property (nonatomic, strong) NSString* skipTo;

@property (nonatomic, strong) id value;

@property (nonatomic, strong, readwrite) SBBSurveyConstraints *surveyConstraints;

- (void) setSurveyConstraints: (SBBSurveyConstraints*) surveyConstraints_ settingInverse: (BOOL) setInverse;

@end

/** \ingroup DataModel */

@implementation _SBBSurveyRule

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

        self.operator = [dictionary objectForKey:@"operator"];

        self.skipTo = [dictionary objectForKey:@"skipTo"];

        self.value = [dictionary objectForKey:@"value"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.operator forKey:@"operator"];

    [dict setObjectIfNotNil:self.skipTo forKey:@"skipTo"];

    [dict setObjectIfNotNil:self.value forKey:@"value"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.surveyConstraints awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{

    if (self == [super init]) {

        self.operator = managedObject.operator;

        self.skipTo = managedObject.skipTo;

        self.value = managedObject.value;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyRule" inManagedObjectContext:cacheContext];

    managedObject.operator = self.operator;

    managedObject.skipTo = self.skipTo;

    managedObject.value = self.value;

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

- (void) setSurveyConstraints: (SBBSurveyConstraints*) surveyConstraints_ settingInverse: (BOOL) setInverse
{
    if (surveyConstraints_ == nil) {
        [_surveyConstraints removeRulesObject: (SBBSurveyRule*)self settingInverse: NO];
    }

    _surveyConstraints = surveyConstraints_;

    if (setInverse == YES) {
        [_surveyConstraints addRulesObject: (SBBSurveyRule*)self settingInverse: NO];
    }
}

- (void) setSurveyConstraints: (SBBSurveyConstraints*) surveyConstraints_
{
    [self setSurveyConstraints: surveyConstraints_ settingInverse: YES];
}

- (SBBSurveyConstraints*) surveyConstraints
{
    return _surveyConstraints;
}

@synthesize surveyConstraints = _surveyConstraints;

@end
