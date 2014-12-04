//
//  SBBSurveyQuestion.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestion.h instead.
//

#import "_SBBSurveyQuestion.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyConstraints.h"
#import "SBBSurvey.h"

@interface _SBBSurveyQuestion()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyQuestion)

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, strong) NSString* uiHint;

@property (nonatomic, strong, readwrite) SBBSurveyConstraints *constraints;

@property (nonatomic, strong, readwrite) SBBSurvey *survey;

- (void) setConstraints: (SBBSurveyConstraints*) constraints_ settingInverse: (BOOL) setInverse;

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse;

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

        self.guid = [dictionary objectForKey:@"guid"];

        self.identifier = [dictionary objectForKey:@"identifier"];

        self.prompt = [dictionary objectForKey:@"prompt"];

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

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:self.prompt forKey:@"prompt"];

    [dict setObjectIfNotNil:self.uiHint forKey:@"uiHint"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.constraints] forKey:@"constraints"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.survey awakeFromDictionaryRepresentationInit];
	[self.constraints awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (instancetype)initFromCoreDataCacheWithID:(NSString *)bridgeObjectID
{
    // TODO: get managed object from cache

    // create PONSO object from managed object
    return [self initWithManagedObject:managedObject];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{

    if (self == [super init]) {

        self.guid = managedObject.guid;

        self.identifier = managedObject.identifier;

        self.prompt = managedObject.prompt;

        self.uiHint = managedObject.uiHint;

            SBBSurveyConstraints *constraintsManagedObj = managedObject.constraints;
        SBBSurveyConstraints *constraintsObj = [[SBBSurveyConstraints alloc] initWithManagedObject:constraintsManagedObj];
        if(constraintsObj != nil)
        {
          self.constraints = constraintsObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyQuestion" inManagedObjectContext:cacheContext];

    managedObject.guid = self.guid;

    managedObject.identifier = self.identifier;

    managedObject.prompt = self.prompt;

    managedObject.uiHint = self.uiHint;

    NSManagedObject *relObj = [self.constraints saveToContext:cacheContext withObjectManager:objectManager];
    [managedObject setConstraints:relObj];

    // TODO: Save changes to cacheContext.

    return managedObject;
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

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse
{
    if (survey_ == nil) {
        [_survey removeQuestionsObject: (SBBSurveyQuestion*)self settingInverse: NO];
    }

    _survey = survey_;

    if (setInverse == YES) {
        [_survey addQuestionsObject: (SBBSurveyQuestion*)self settingInverse: NO];
    }
}

- (void) setSurvey: (SBBSurvey*) survey_
{
    [self setSurvey: survey_ settingInverse: YES];
}

- (SBBSurvey*) survey
{
    return _survey;
}

@synthesize constraints = _constraints;@synthesize survey = _survey;

@end
