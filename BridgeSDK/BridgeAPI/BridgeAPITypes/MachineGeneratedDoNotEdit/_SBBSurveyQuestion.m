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

@interface _SBBSurveyQuestion()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyQuestion)

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, strong) NSString* uiHint;

@property (nonatomic, strong, readwrite) NSManagedObject *constraints;

- (void) setConstraints: (NSManagedObject *) constraints_ settingInverse: (BOOL) setInverse;

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

	[self.constraints awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"SurveyQuestion" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.guid = managedObject.guid;

        self.identifier = managedObject.identifier;

        self.prompt = managedObject.prompt;

        self.uiHint = managedObject.uiHint;

            NSManagedObject *constraintsManagedObj = managedObject.constraints;
        SBBSurveyConstraints *constraintsObj = [[SBBSurveyConstraints alloc] initWithManagedObject:constraintsManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(constraintsObj != nil)
        {
          self.constraints = constraintsObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    __block NSManagedObject *managedObject = nil;

    managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyQuestion" inManagedObjectContext:cacheContext];

    managedObject.guid = self.guid;

    managedObject.identifier = self.identifier;

    managedObject.prompt = self.prompt;

    managedObject.uiHint = self.uiHint;

    NSManagedObject *relObj = [self.constraints saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
    [managedObject setConstraints:relObj];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

- (void) setConstraints: (SBBSurveyConstraints*) constraints_ settingInverse: (BOOL) setInverse
{

    _constraints = constraints_;

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
