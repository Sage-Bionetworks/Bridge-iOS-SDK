//
//  SBBUploadSession.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUploadSession.h instead.
//

#import "_SBBUploadSession.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBUploadSession()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (UploadSession)

@property (nonatomic, strong) NSDate* expires;

@property (nonatomic, strong) NSString* id;

@property (nonatomic, strong) NSString* url;

@end

/** \ingroup DataModel */

@implementation _SBBUploadSession

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

        self.expires = [NSDate dateWithISO8601String:[dictionary objectForKey:@"expires"]];

        self.id = [dictionary objectForKey:@"id"];

        self.url = [dictionary objectForKey:@"url"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:[self.expires ISO8601String] forKey:@"expires"];

    [dict setObjectIfNotNil:self.id forKey:@"id"];

    [dict setObjectIfNotNil:self.url forKey:@"url"];

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

        self.expires = managedObject.expires;

        self.id = managedObject.id;

        self.url = managedObject.url;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    [cacheContext performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UploadSession" inManagedObjectContext:cacheContext];
    }];

    managedObject.expires = self.expires;

    managedObject.id = self.id;

    managedObject.url = self.url;

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

@end
