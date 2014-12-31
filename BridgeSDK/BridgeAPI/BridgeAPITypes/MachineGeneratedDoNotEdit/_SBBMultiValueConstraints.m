//
//  SBBMultiValueConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBMultiValueConstraints.h instead.
//

#import "_SBBMultiValueConstraints.h"
#import "ModelObjectInternal.h"
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

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.allowMultiple = [dictionary objectForKey:@"allowMultiple"];

    self.allowOther = [dictionary objectForKey:@"allowOther"];

    self.enumeration = [dictionary objectForKey:@"enumeration"];

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

#pragma mark Direct access

@end
