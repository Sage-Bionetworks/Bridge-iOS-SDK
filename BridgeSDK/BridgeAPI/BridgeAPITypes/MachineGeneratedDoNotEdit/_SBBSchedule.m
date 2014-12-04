//
//  SBBSchedule.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSchedule.h instead.
//

#import "_SBBSchedule.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSchedule()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (Schedule)

@property (nonatomic, strong) NSString* activityRef;

@property (nonatomic, strong) NSString* activityType;

@property (nonatomic, strong) NSString* cronTrigger;

@property (nonatomic, strong) NSDate* endsOn;

@property (nonatomic, strong) NSString* expires;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* scheduleType;

@property (nonatomic, strong) NSDate* startsOn;

@end

/** \ingroup DataModel */

@implementation _SBBSchedule

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

        self.activityRef = [dictionary objectForKey:@"activityRef"];

        self.activityType = [dictionary objectForKey:@"activityType"];

        self.cronTrigger = [dictionary objectForKey:@"cronTrigger"];

        self.endsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"endsOn"]];

        self.expires = [dictionary objectForKey:@"expires"];

        self.label = [dictionary objectForKey:@"label"];

        self.scheduleType = [dictionary objectForKey:@"scheduleType"];

        self.startsOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"startsOn"]];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.activityRef forKey:@"activityRef"];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.cronTrigger forKey:@"cronTrigger"];

    [dict setObjectIfNotNil:[self.endsOn ISO8601String] forKey:@"endsOn"];

    [dict setObjectIfNotNil:self.expires forKey:@"expires"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.scheduleType forKey:@"scheduleType"];

    [dict setObjectIfNotNil:[self.startsOn ISO8601String] forKey:@"startsOn"];

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

        self.activityRef = managedObject.activityRef;

        self.activityType = managedObject.activityType;

        self.cronTrigger = managedObject.cronTrigger;

        self.endsOn = managedObject.endsOn;

        self.expires = managedObject.expires;

        self.label = managedObject.label;

        self.scheduleType = managedObject.scheduleType;

        self.startsOn = managedObject.startsOn;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Schedule" inManagedObjectContext:cacheContext];

    managedObject.activityRef = self.activityRef;

    managedObject.activityType = self.activityType;

    managedObject.cronTrigger = self.cronTrigger;

    managedObject.endsOn = self.endsOn;

    managedObject.expires = self.expires;

    managedObject.label = self.label;

    managedObject.scheduleType = self.scheduleType;

    managedObject.startsOn = self.startsOn;

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

@end
