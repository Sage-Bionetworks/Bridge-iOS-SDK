//
//  SBBUserProfile.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUserProfile.h instead.
//

#import "_SBBUserProfile.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBUserProfile()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (UserProfile)

@property (nonatomic, strong) NSString* email;

@property (nonatomic, strong) NSString* firstName;

@property (nonatomic, strong) NSString* lastName;

@property (nonatomic, strong) NSString* username;

@end

/** \ingroup DataModel */

@implementation _SBBUserProfile

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

    self.email = [dictionary objectForKey:@"email"];

    self.firstName = [dictionary objectForKey:@"firstName"];

    self.lastName = [dictionary objectForKey:@"lastName"];

    self.username = [dictionary objectForKey:@"username"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.email forKey:@"email"];

    [dict setObjectIfNotNil:self.firstName forKey:@"firstName"];

    [dict setObjectIfNotNil:self.lastName forKey:@"lastName"];

    [dict setObjectIfNotNil:self.username forKey:@"username"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"UserProfile" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.email = managedObject.email;

        self.firstName = managedObject.firstName;

        self.lastName = managedObject.lastName;

        self.username = managedObject.username;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfile" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    managedObject.email = self.email;

    managedObject.firstName = self.firstName;

    managedObject.lastName = self.lastName;

    managedObject.username = self.username;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
