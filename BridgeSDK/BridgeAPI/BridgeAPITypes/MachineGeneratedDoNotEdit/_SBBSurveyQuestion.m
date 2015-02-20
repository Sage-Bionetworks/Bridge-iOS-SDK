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

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.uiHint = [dictionary objectForKey:@"uiHint"];

        NSDictionary *constraintsDict = [dictionary objectForKey:@"constraints"];
    if(constraintsDict != nil)
    {
        SBBSurveyConstraints *constraintsObj = [objectManager objectFromBridgeJSON:constraintsDict];
        self.constraints = constraintsObj;

    }
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

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"SurveyQuestion" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

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
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyQuestion" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.uiHint = self.uiHint;

    [cacheContext deleteObject:managedObject.constraints];
    NSManagedObject *relMo = [self.constraints saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
    [managedObject setConstraints:relMo];

    // Calling code will handle saving these changes to cacheContext.
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
