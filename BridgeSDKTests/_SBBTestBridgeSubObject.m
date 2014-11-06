//
//  SBBTestBridgeSubObject.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBTestBridgeSubObject.h instead.
//

#import "_SBBTestBridgeSubObject.h"
#import "NSDate+SBBAdditions.h"

#import "SBBTestBridgeObject.h"

@interface _SBBTestBridgeSubObject()

@end

/** \ingroup DataModel */

@implementation _SBBTestBridgeSubObject

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

        self.stringField = [dictionary objectForKey:@"stringField"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];

    [dict setObjectIfNotNil:self.stringField forKey:@"stringField"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.testBridgeObject awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setTestBridgeObject: (SBBTestBridgeObject*) testBridgeObject_ settingInverse: (BOOL) setInverse
{
    if (testBridgeObject_ == nil) {
        [_testBridgeObject setBridgeSubObjectField: nil settingInverse: NO];
    }

    _testBridgeObject = testBridgeObject_;

    if (setInverse == YES) {
        [_testBridgeObject setBridgeSubObjectField: (SBBTestBridgeSubObject*)self settingInverse: NO];
    }
}

- (void) setTestBridgeObject: (SBBTestBridgeObject*) testBridgeObject_
{
    [self setTestBridgeObject: testBridgeObject_ settingInverse: YES];
}

- (SBBTestBridgeObject*) testBridgeObject
{
    return _testBridgeObject;
}

@synthesize testBridgeObject = _testBridgeObject;

@end
