//
//  SBBBridgeObject.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBBridgeObject.h instead.
//

#import "_SBBBridgeObject.h"
#import "NSDate+SBBAdditions.h"

#import "SBBResourceList.h"

@interface _SBBBridgeObject()

@end

/** \ingroup DataModel */

@implementation _SBBBridgeObject

- (id)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
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

	[self.resourceList awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setResourceList: (SBBResourceList*) resourceList_ settingInverse: (BOOL) setInverse
{
    if (resourceList_ == nil) {
        [_resourceList removeItemsObject: (SBBBridgeObject*)self settingInverse: NO];
    }

    _resourceList = resourceList_;

    if (setInverse == YES) {
        [_resourceList addItemsObject: (SBBBridgeObject*)self settingInverse: NO];
    }
}

- (void) setResourceList: (SBBResourceList*) resourceList_
{
    [self setResourceList: resourceList_ settingInverse: YES];
}

- (SBBResourceList*) resourceList
{
    return _resourceList;
}

@synthesize resourceList = _resourceList;

@end
