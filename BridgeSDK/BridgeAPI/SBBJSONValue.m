//
//  SBBJSONValue.h
//  BridgeSDK
//
//
// Copyright (c) 2017, Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import"SBBJSONValue.h"

@implementation NSDictionary (SBBJSONValue)

- (BOOL)isValidJSON {
    // all keys must be strings
    for (NSObject *key in self.allKeys) {
        if (![key isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    
    // all values must conform to SBBJSONValue and be valid JSON themselves
    for (id<SBBJSONValue> value in self.allValues) {
        if (![value conformsToProtocol:@protocol(SBBJSONValue)] ||
            ![value isValidJSON]) {
            return NO;
        }
    }
    
    return YES;
}

@end

@implementation NSArray (SBBJSONValue)

- (BOOL)isValidJSON {
    // all values must conform to SBBJSONValue and be valid JSON themselves
    for (id<SBBJSONValue> value in self) {
        if (![value conformsToProtocol:@protocol(SBBJSONValue)] ||
            ![value isValidJSON]) {
            return NO;
        }
    }
    
    return YES;
}

@end

@implementation NSString (SBBJSONValue)

- (BOOL)isValidJSON {
    return YES;
}

@end

@implementation NSNumber (SBBJSONValue)

- (BOOL)isValidJSON {
    return YES;
}

@end

@implementation NSNull (SBBJSONValue)

- (BOOL)isValidJSON {
    return YES;
}

@end
