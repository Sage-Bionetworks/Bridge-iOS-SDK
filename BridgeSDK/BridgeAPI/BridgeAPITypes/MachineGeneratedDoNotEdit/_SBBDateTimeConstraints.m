//
//  SBBDateTimeConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBDateTimeConstraints.h instead.
//

#import "_SBBDateTimeConstraints.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBDateTimeConstraints()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (DateTimeConstraints)

@property (nonatomic, strong) NSNumber* allowFuture;

@property (nonatomic, assign) BOOL allowFutureValue;

@property (nonatomic, strong) NSDate* earliestValue;

@property (nonatomic, strong) NSDate* latestValue;

@end

/** \ingroup DataModel */

@implementation _SBBDateTimeConstraints

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)allowFutureValue
{
	return [self.allowFuture boolValue];
}

- (void)setAllowFutureValue:(BOOL)value_
{
	self.allowFuture = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.allowFuture = [dictionary objectForKey:@"allowFuture"];

        self.earliestValue = [NSDate dateWithISO8601String:[dictionary objectForKey:@"earliestValue"]];

        self.latestValue = [NSDate dateWithISO8601String:[dictionary objectForKey:@"latestValue"]];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.allowFuture forKey:@"allowFuture"];

    [dict setObjectIfNotNil:[self.earliestValue ISO8601String] forKey:@"earliestValue"];

    [dict setObjectIfNotNil:[self.latestValue ISO8601String] forKey:@"latestValue"];

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

        self.allowFuture = managedObject.allowFuture;

        self.earliestValue = managedObject.earliestValue;

        self.latestValue = managedObject.latestValue;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    [cacheContext performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"DateTimeConstraints" inManagedObjectContext:cacheContext];
    }];

    managedObject.allowFuture = self.allowFuture;

    managedObject.earliestValue = self.earliestValue;

    managedObject.latestValue = self.latestValue;

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

@end
