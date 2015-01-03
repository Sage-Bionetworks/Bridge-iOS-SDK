//
//  SBBDateConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBDateConstraints.h instead.
//

#import "_SBBDateConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBDateConstraints()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (DateConstraints)

@property (nonatomic, strong) NSNumber* allowFuture;

@property (nonatomic, assign) BOOL allowFutureValue;

@property (nonatomic, strong) NSDate* earliestValue;

@property (nonatomic, strong) NSDate* latestValue;

@end

/** \ingroup DataModel */

@implementation _SBBDateConstraints

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

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.allowFuture = [dictionary objectForKey:@"allowFuture"];

    self.earliestValue = [NSDate dateWithISO8601String:[dictionary objectForKey:@"earliestValue"]];

    self.latestValue = [NSDate dateWithISO8601String:[dictionary objectForKey:@"latestValue"]];

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

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"DateConstraints" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.allowFuture = managedObject.allowFuture;

        self.earliestValue = managedObject.earliestValue;

        self.latestValue = managedObject.latestValue;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"DateConstraints" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    managedObject.allowFuture = self.allowFuture;

    managedObject.earliestValue = self.earliestValue;

    managedObject.latestValue = self.latestValue;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
