//
//  SBBBridgeObject_test.m
//	
//  $Id$
//

#import "SBBBridgeObject_test.h"

@implementation SBBBridgeObject_test

#pragma mark Abstract method overrides

// Custom logic goes here.

- (id)init
{
    if (self = [super init]) {
        NSString *className = NSStringFromClass([self class]);
        if ([className hasPrefix:@"SBB"]) {
            // set default type string (the property is read-only so we have to use the back door)
            NSDictionary *dict = @{@"type": [className substringFromIndex:3]};
            self = [super initWithDictionaryRepresentation:dict];
        }
    }
    
    return self;
}

@end
