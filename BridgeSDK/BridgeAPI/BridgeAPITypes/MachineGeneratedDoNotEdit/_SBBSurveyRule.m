//
//  SBBSurveyRule.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyRule.h instead.
//

#import "_SBBSurveyRule.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBSurveyRule()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyRule)

@property (nonatomic, strong) NSString* operator;

@property (nonatomic, strong) NSString* skipTo;

@property (nonatomic, strong) id value;

@end

/** \ingroup DataModel */

@implementation _SBBSurveyRule

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.operator = [dictionary objectForKey:@"operator"];

    self.skipTo = [dictionary objectForKey:@"skipTo"];

    self.value = [dictionary objectForKey:@"value"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.operator forKey:@"operator"];

    [dict setObjectIfNotNil:self.skipTo forKey:@"skipTo"];

    [dict setObjectIfNotNil:self.value forKey:@"value"];

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
