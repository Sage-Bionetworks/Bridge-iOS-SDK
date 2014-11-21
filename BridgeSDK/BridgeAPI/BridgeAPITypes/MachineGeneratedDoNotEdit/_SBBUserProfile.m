//
//  SBBUserProfile.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUserProfile.h instead.
//

#import "_SBBUserProfile.h"
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

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.email = [dictionary objectForKey:@"email"];

        self.firstName = [dictionary objectForKey:@"firstName"];

        self.lastName = [dictionary objectForKey:@"lastName"];

        self.username = [dictionary objectForKey:@"username"];

	}

	return self;
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

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{

    if (self == [super init]) {

        self.email = managedObject.email;

        self.firstName = managedObject.firstName;

        self.lastName = managedObject.lastName;

        self.username = managedObject.username;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    [cacheContext performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfile" inManagedObjectContext:cacheContext];
    }];

    managedObject.email = self.email;

    managedObject.firstName = self.firstName;

    managedObject.lastName = self.lastName;

    managedObject.username = self.username;

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

@end
