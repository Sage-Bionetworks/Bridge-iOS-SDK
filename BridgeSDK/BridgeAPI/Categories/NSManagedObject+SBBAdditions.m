//
//  NSObject+SBBAdditions.m
//  BridgeSDK
//
//	Copyright (c) 2016, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSManagedObject+SBBAdditions.h"

@implementation NSManagedObject (SBBAdditions)

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
        if ([containerObject isKindOfClass:[NSOrderedSet class]]) {
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
