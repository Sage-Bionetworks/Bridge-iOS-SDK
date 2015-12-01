//
//  NSBundleSBBAdditionsTests.m
//  BridgeSDK
//
//  Created by Shannon Young on 11/23/15.
//  Copyright © 2015 Sage Bionetworks. All rights reserved.
//

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


