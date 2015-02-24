//
//  SBBSurveyQuestionOption.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestionOption.h instead.
//

#import "_SBBSurveyQuestionOption.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBImage.h"

@interface _SBBSurveyQuestionOption()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyQuestionOption)

@property (nonatomic, strong) NSString* detail;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* value;

@property (nonatomic, strong, readwrite) NSManagedObject *image;

- (void) setImage: (NSManagedObject *) image_ settingInverse: (BOOL) setInverse;

@end

/** \ingroup DataModel */

@implementation _SBBSurveyQuestionOption

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

    self.detail = [dictionary objectForKey:@"detail"];

    self.label = [dictionary objectForKey:@"label"];

    self.value = [dictionary objectForKey:@"value"];

        NSDictionary *imageDict = [dictionary objectForKey:@"image"];
    if(imageDict != nil)
    {
        SBBImage *imageObj = [objectManager objectFromBridgeJSON:imageDict];
        self.image = imageObj;

    }
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.detail forKey:@"detail"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.value forKey:@"value"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.image] forKey:@"image"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.image awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"SurveyQuestionOption" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.detail = managedObject.detail;

        self.label = managedObject.label;

        self.value = managedObject.value;

            NSManagedObject *imageManagedObj = managedObject.image;
        SBBImage *imageObj = [[SBBImage alloc] initWithManagedObject:imageManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(imageObj != nil)
        {
          self.image = imageObj;
        }
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyQuestionOption" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.detail = self.detail;

    managedObject.label = self.label;

    managedObject.value = self.value;

    [cacheContext deleteObject:managedObject.image];
    NSManagedObject *relMo = [self.image saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
    [managedObject setImage:relMo];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void) setImage: (SBBImage*) image_ settingInverse: (BOOL) setInverse
{

    _image = image_;

}

- (void) setImage: (SBBImage*) image_
{
    [self setImage: image_ settingInverse: YES];
}

- (SBBImage*) image
{
    return _image;
}

@synthesize image = _image;

@end
