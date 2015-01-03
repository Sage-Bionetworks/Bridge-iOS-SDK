//
//  SBBStringConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBStringConstraints.h instead.
//

#import "_SBBStringConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBStringConstraints()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (StringConstraints)

@property (nonatomic, strong) NSNumber* maxLength;

@property (nonatomic, assign) int64_t maxLengthValue;

@property (nonatomic, strong) NSNumber* minLength;

@property (nonatomic, assign) int64_t minLengthValue;

@property (nonatomic, strong) NSString* pattern;

@end

/** \ingroup DataModel */

@implementation _SBBStringConstraints

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)maxLengthValue
{
	return [self.maxLength longLongValue];
}

- (void)setMaxLengthValue:(int64_t)value_
{
	self.maxLength = [NSNumber numberWithLongLong:value_];
}

- (int64_t)minLengthValue
{
	return [self.minLength longLongValue];
}

- (void)setMinLengthValue:(int64_t)value_
{
	self.minLength = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.maxLength = [dictionary objectForKey:@"maxLength"];

    self.minLength = [dictionary objectForKey:@"minLength"];

    self.pattern = [dictionary objectForKey:@"pattern"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.maxLength forKey:@"maxLength"];

    [dict setObjectIfNotNil:self.minLength forKey:@"minLength"];

    [dict setObjectIfNotNil:self.pattern forKey:@"pattern"];

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
    return [NSEntityDescription entityForName:@"StringConstraints" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.maxLength = managedObject.maxLength;

        self.minLength = managedObject.minLength;

        self.pattern = managedObject.pattern;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringConstraints" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    managedObject.maxLength = self.maxLength;

    managedObject.minLength = self.minLength;

    managedObject.pattern = self.pattern;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
