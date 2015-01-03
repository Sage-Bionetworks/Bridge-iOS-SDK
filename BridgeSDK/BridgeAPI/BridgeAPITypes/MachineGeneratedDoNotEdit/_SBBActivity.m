//
//  SBBActivity.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBActivity.h instead.
//

#import "_SBBActivity.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBGuidCreatedOnVersionHolder.h"

@interface _SBBActivity()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (Activity)

@property (nonatomic, strong) NSString* activityType;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* ref;

@property (nonatomic, strong, readwrite) NSManagedObject *survey;

- (void) setSurvey: (NSManagedObject *) survey_ settingInverse: (BOOL) setInverse;

@end

/** \ingroup DataModel */

@implementation _SBBActivity

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

    self.activityType = [dictionary objectForKey:@"activityType"];

    self.label = [dictionary objectForKey:@"label"];

    self.ref = [dictionary objectForKey:@"ref"];

        NSDictionary *surveyDict = [dictionary objectForKey:@"survey"];
    if(surveyDict != nil)
    {
        SBBGuidCreatedOnVersionHolder *surveyObj = [objectManager objectFromBridgeJSON:surveyDict];
        self.survey = surveyObj;

    }
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.ref forKey:@"ref"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.survey] forKey:@"survey"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.survey awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.activityType = managedObject.activityType;

        self.label = managedObject.label;

        self.ref = managedObject.ref;

            NSManagedObject *surveyManagedObj = managedObject.survey;
        SBBGuidCreatedOnVersionHolder *surveyObj = [[SBBGuidCreatedOnVersionHolder alloc] initWithManagedObject:surveyManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(surveyObj != nil)
        {
          self.survey = surveyObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.activityType = self.activityType;

    managedObject.label = self.label;

    managedObject.ref = self.ref;

    [cacheContext deleteObject:managedObject.survey];
    NSManagedObject *relMo = [self.survey saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
    [managedObject setSurvey:relMo];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void) setSurvey: (SBBGuidCreatedOnVersionHolder*) survey_ settingInverse: (BOOL) setInverse
{

    _survey = survey_;

}

- (void) setSurvey: (SBBGuidCreatedOnVersionHolder*) survey_
{
    [self setSurvey: survey_ settingInverse: YES];
}

- (SBBGuidCreatedOnVersionHolder*) survey
{
    return _survey;
}

@synthesize survey = _survey;

@end
