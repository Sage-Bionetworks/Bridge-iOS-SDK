//
//  NSObject+SBBAdditions.m
//  BridgeSDK
//
//  Created by Erin Mounts on 3/31/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "NSObject+SBBAdditions.h"

@implementation NSObject (SBBAdditions)

#pragma mark key-value coding

- (id)valueForIndexedKey:(NSString *)key
{
    id result = nil;
    // Handle paths like items[0], items[1], ...
    NSRange startSubscript = [key rangeOfString:@"["];
    if (startSubscript.location != NSNotFound) {
        NSString *bareKey = [key substringToIndex:startSubscript.location];
        NSString *indexString = [key substringWithRange:NSMakeRange(startSubscript.location + 1, key.length - startSubscript.location - 2)];
        id containerObject = [self valueForKey:bareKey];
        if ([containerObject isKindOfClass:[NSArray class]]) {
            result = containerObject[[indexString integerValue]];
        } else if ([containerObject isKindOfClass:[NSDictionary class]]) {
            result = containerObject[indexString];
        }
    }
    
    if (!result) {
        [NSException raise:NSUndefinedKeyException format:@"Requested value for unknown key %@ on object of class %@", key, NSStringFromClass([self class])];
    }
    
    return result;
}

- (id)valueForKeyPath:(NSString *)keyPath
{
    id result = self;
    NSArray *keysInPath = [keyPath componentsSeparatedByString:@"."];
    for (NSString *key in keysInPath) {
        if ([key hasSuffix:@"]"]) {
            result = [result valueForIndexedKey:key];
        } else {
            result = [result valueForKey:key];
        }
        
        // don't keep going if we hit a dead end
        if (!result) {
            break;
        }
    }
    
    return result;
}

@end
