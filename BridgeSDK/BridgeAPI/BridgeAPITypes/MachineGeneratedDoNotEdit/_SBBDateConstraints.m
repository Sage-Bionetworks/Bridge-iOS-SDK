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

#pragma mark Direct access

@end
