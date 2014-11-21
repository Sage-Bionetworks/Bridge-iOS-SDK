//
//  SBBMultiValueConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBMultiValueConstraints.h instead.
//

#import "_SBBMultiValueConstraints.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBMultiValueConstraints()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (MultiValueConstraints)

@property (nonatomic, strong) NSNumber* allowMultiple;

@property (nonatomic, assign) BOOL allowMultipleValue;

@property (nonatomic, strong) NSNumber* allowOther;

@property (nonatomic, assign) BOOL allowOtherValue;

@property (nonatomic, strong) NSArray* enumeration;

@end

/** \ingroup DataModel */

@implementation _SBBMultiValueConstraints

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)allowMultipleValue
{
	return [self.allowMultiple boolValue];
}

- (void)setAllowMultipleValue:(BOOL)value_
{
	self.allowMultiple = [NSNumber numberWithBool:value_];
}

- (BOOL)allowOtherValue
{
	return [self.allowOther boolValue];
}

- (void)setAllowOtherValue:(BOOL)value_
{
	self.allowOther = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.allowMultiple = [dictionary objectForKey:@"allowMultiple"];

        self.allowOther = [dictionary objectForKey:@"allowOther"];

        self.enumeration = [dictionary objectForKey:@"enumeration"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.allowMultiple forKey:@"allowMultiple"];

    [dict setObjectIfNotNil:self.allowOther forKey:@"allowOther"];

    [dict setObjectIfNotNil:self.enumeration forKey:@"enumeration"];

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

        self.allowMultiple = managedObject.allowMultiple;

        self.allowOther = managedObject.allowOther;

        self.enumeration = managedObject.enumeration;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    [cacheContext performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MultiValueConstraints" inManagedObjectContext:cacheContext];
    }];

    managedObject.allowMultiple = self.allowMultiple;

    managedObject.allowOther = self.allowOther;

    managedObject.enumeration = self.enumeration;

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

@end
