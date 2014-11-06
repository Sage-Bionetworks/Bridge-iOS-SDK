//
//  SBBBridgeObject_test.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBBridgeObject_test.h instead.
//

#import "_SBBBridgeObject_test.h"
#import "NSDate+SBBAdditions.h"

#import "SBBTestBridgeObject.h"

@interface _SBBBridgeObject_test()

@end

/** \ingroup DataModel */

@implementation _SBBBridgeObject_test

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
	if((self = [super initWithDictionaryRepresentation:dictionary]))
	{

        _type = [dictionary objectForKey:@"type"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.type forKey:@"type"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.parentTestBridgeObject awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setParentTestBridgeObject: (SBBTestBridgeObject*) parentTestBridgeObject_ settingInverse: (BOOL) setInverse
{
    if (parentTestBridgeObject_ == nil) {
        [_parentTestBridgeObject removeBridgeObjectArrayFieldObject: (SBBBridgeObject_test*)self settingInverse: NO];
    }

    _parentTestBridgeObject = parentTestBridgeObject_;

    if (setInverse == YES) {
        [_parentTestBridgeObject addBridgeObjectArrayFieldObject: (SBBBridgeObject_test*)self settingInverse: NO];
    }
}

- (void) setParentTestBridgeObject: (SBBTestBridgeObject*) parentTestBridgeObject_
{
    [self setParentTestBridgeObject: parentTestBridgeObject_ settingInverse: YES];
}

- (SBBTestBridgeObject*) parentTestBridgeObject
{
    return _parentTestBridgeObject;
}

@synthesize parentTestBridgeObject = _parentTestBridgeObject;

@end
