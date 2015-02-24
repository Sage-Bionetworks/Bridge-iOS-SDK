//
//  SBBDecimalConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBDecimalConstraints.h instead.
//

#import "_SBBDecimalConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBDecimalConstraints()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (DecimalConstraints)

@property (nonatomic, strong) NSNumber* maxValue;

@property (nonatomic, assign) double maxValueValue;

@property (nonatomic, strong) NSNumber* minValue;

@property (nonatomic, assign) double minValueValue;

@property (nonatomic, strong) NSNumber* step;

@property (nonatomic, assign) double stepValue;

@property (nonatomic, strong) NSString* unit;

@end

/** \ingroup DataModel */

@implementation _SBBDecimalConstraints

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (double)maxValueValue
{
	return [self.maxValue doubleValue];
}

- (void)setMaxValueValue:(double)value_
{
	self.maxValue = [NSNumber numberWithDouble:value_];
}

- (double)minValueValue
{
	return [self.minValue doubleValue];
}

- (void)setMinValueValue:(double)value_
{
	self.minValue = [NSNumber numberWithDouble:value_];
}

- (double)stepValue
{
	return [self.step doubleValue];
}

- (void)setStepValue:(double)value_
{
	self.step = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.maxValue = [dictionary objectForKey:@"maxValue"];

    self.minValue = [dictionary objectForKey:@"minValue"];

    self.step = [dictionary objectForKey:@"step"];

    self.unit = [dictionary objectForKey:@"unit"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.maxValue forKey:@"maxValue"];

    [dict setObjectIfNotNil:self.minValue forKey:@"minValue"];

    [dict setObjectIfNotNil:self.step forKey:@"step"];

    [dict setObjectIfNotNil:self.unit forKey:@"unit"];

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
    return [NSEntityDescription entityForName:@"DecimalConstraints" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.maxValue = managedObject.maxValue;

        self.minValue = managedObject.minValue;

        self.step = managedObject.step;

        self.unit = managedObject.unit;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"DecimalConstraints" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    managedObject.maxValue = self.maxValue;

    managedObject.minValue = self.minValue;

    managedObject.step = self.step;

    managedObject.unit = self.unit;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
