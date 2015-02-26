//
//  SBBConsentManagerTests.m
//  BridgeSDK
//
//  Created by Dwayne Jeng on 11/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPITestCase.h"
#import "SBBConsentManagerInternal.h"

@interface SBBConsentManagerTests : SBBBridgeAPITestCase

@end

@implementation SBBConsentManagerTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testRetrieve {
  // construct consent manager with mock response
  NSDictionary* responseDict = @{kSBBKeyName:@"Eggplant McTester", kSBBKeyBirthdate:@"1970-01-01"};
  [self.mockNetworkManager setJson:responseDict andResponseCode:200 forEndpoint:kSBBApiConsentV1 andMethod:@"GET"];
  SBBConsentManager* consentMan = [SBBConsentManager managerWithAuthManager:SBBComponent(SBBAuthManager)
    networkManager:self.mockNetworkManager objectManager:SBBComponent(SBBObjectManager)];

  // execute and validate
  [consentMan retrieveConsentSignatureWithCompletion:^(NSString* name, NSString* birthdate, UIImage* signatureImage,
      NSError* error) {
    XCTAssert([@"Eggplant McTester" isEqualToString:name], @"consent signature has name");
    XCTAssert([@"1970-01-01" isEqualToString:birthdate], @"consent signature has birthdate");
    XCTAssertNil(signatureImage, @"consent signature has no image");
  }];
}

- (void)testRetrieveWithImage {
  // test signature image
  NSString* imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sample-signature" ofType:@"png"];
  NSData* imageData = [NSData dataWithContentsOfFile:imagePath];
  NSString* imageBase64String = [imageData base64EncodedStringWithOptions:kNilOptions];

  // construct consent manager with mock response
  NSDictionary* responseDict = @{kSBBKeyName:@"Eggplant McTester", kSBBKeyBirthdate:@"1970-01-01",
    kSBBKeyImageData:imageBase64String, kSBBKeyImageMimeType:kSBBMimeTypePng};
  [self.mockNetworkManager setJson:responseDict andResponseCode:200 forEndpoint:kSBBApiConsentV1 andMethod:@"GET"];
  SBBConsentManager* consentMan = [SBBConsentManager managerWithAuthManager:SBBComponent(SBBAuthManager)
    networkManager:self.mockNetworkManager objectManager:SBBComponent(SBBObjectManager)];

  // execute and validate
  [consentMan retrieveConsentSignatureWithCompletion:^(NSString* name, NSString* birthdate, UIImage* signatureImage,
      NSError* error) {
    XCTAssert([@"Eggplant McTester" isEqualToString:name], @"consent signature has name");
    XCTAssert([@"1970-01-01" isEqualToString:birthdate], @"consent signature has birthdate");

    // we validate the image simply by validating that it has a positive height and width
    XCTAssert([signatureImage size].height > 0, @"consent signature image has positive height");
    XCTAssert([signatureImage size].width > 0, @"consent signature image has positive width");
  }];
}

@end
