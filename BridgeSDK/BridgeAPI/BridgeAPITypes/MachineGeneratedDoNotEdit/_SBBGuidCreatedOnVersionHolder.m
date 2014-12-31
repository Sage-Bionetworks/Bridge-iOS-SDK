//
//  SBBGuidCreatedOnVersionHolder.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBGuidCreatedOnVersionHolder.h instead.
//

#import "_SBBGuidCreatedOnVersionHolder.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBGuidCreatedOnVersionHolder()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (GuidCreatedOnVersionHolder)

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) int64_t versionValue;

@end

/** \ingroup DataModel */

@implementation _SBBGuidCreatedOnVersionHolder

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)versionValue
{
	return [self.version longLongValue];
}

- (void)setVersionValue:(int64_t)value_
{
	self.version = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

    self.guid = [dictionary objectForKey:@"guid"];

    self.version = [dictionary objectForKey:@"version"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

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
