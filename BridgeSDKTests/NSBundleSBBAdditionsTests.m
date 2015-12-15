//
//  NSBundleSBBAdditionsTests.m
//  BridgeSDK
//
// Copyright (c) 2015, Sage Bionetworks. All rights reserved.
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

#import "SBBBridgeAPIUnitTestCase.h"
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

@interface NSBundleSBBAdditionsTests : XCTestCase

@end

@interface PartialMockNSBundle : NSBundle

@property NSDictionary <NSString *,id> *mockInfoDictionary;

@end

@implementation PartialMockNSBundle

- (NSDictionary<NSString *,id> *)infoDictionary {
    return self.mockInfoDictionary ?: [super infoDictionary];
}

@end

@implementation NSBundleSBBAdditionsTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testAppStoreURL
{
    //Remove all whitespace
    //Convert all characters to lower-case
    //Remove all copyright (©), trademark (™) and registered mark (®) symbols
    //Replace ampersands ("&") with "and"
    //Remove most punctuation !¡"#$%'()*+,\-./:;<=>¿?@[\]^_`{|}~
    //Replace accented and other "decorated" characters (ü, å, etc.) with their elemental character (u, a, etc.)
    //Leave all other characters as-is.
    
    PartialMockNSBundle *bundle = [PartialMockNSBundle new];
    
    bundle.mockInfoDictionary = @{ @"CFBundleName" : @"Gameloft" };
    XCTAssertEqualObjects([[bundle appStoreLinkURL] lastPathComponent], @"gameloft");
    
    bundle.mockInfoDictionary = @{ @"CFBundleName" : @"Activision Publishing, Inc." };
    XCTAssertEqualObjects([[bundle appStoreLinkURL] lastPathComponent], @"activisionpublishinginc");
    
    bundle.mockInfoDictionary = @{ @"CFBundleName" : @"Chen's Photography & Software" };
    XCTAssertEqualObjects([[bundle appStoreLinkURL] lastPathComponent], @"chensphotographyandsoftware");
    
    bundle.mockInfoDictionary = @{ @"CFBundleName" : @"Where’s My Perry?" };
    XCTAssertEqualObjects([[bundle appStoreLinkURL] lastPathComponent], @"wheresmyperry");
    
    bundle.mockInfoDictionary = @{ @"CFBundleName" : @"Brain Challenge™" };
    XCTAssertEqualObjects([[bundle appStoreLinkURL] lastPathComponent], @"brainchallenge");
    
    bundle.mockInfoDictionary = @{ @"CFBundleName" : @"Übertastic!" };
    XCTAssertEqualObjects([[bundle appStoreLinkURL] lastPathComponent], @"ubertastic");
    
    bundle.mockInfoDictionary = @{ @"CFBundleName" : @"a!b¡c\"d#e$f%g'h(i)j*k+l,m\\-no.p/q:r;s<t=u>v¿w?x@y[z\\]^_`{|}~" };
    XCTAssertEqualObjects([[bundle appStoreLinkURL] lastPathComponent], @"abcdefghijklmnopqrstuvwxyz");
    
}




@end


