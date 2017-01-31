//
//  SBBConsentManagerUnitTests.m
//  BridgeSDK
//
//  Created by Dwayne Jeng on 11/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBConsentManagerInternal.h"

static NSString * const kSBBKeyName = @"name";
static NSString * const kSBBKeyBirthdate = @"birthdate";
static NSString * const kSBBKeyImageData = @"imageData";
static NSString * const kSBBKeyImageMimeType = @"imageMimeType";
static NSString * const kSBBKeyAPIObjectType = @"type";

@interface SBBConsentManagerUnitTests : SBBBridgeAPIUnitTestCase

@end

@implementation SBBConsentManagerUnitTests

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
  NSDictionary* responseDict = @{kSBBKeyName:@"Eggplant McTester", kSBBKeyBirthdate:@"1970-01-01", kSBBKeyAPIObjectType:@"ConsentSignature"};
  NSString *endpoint = [NSString stringWithFormat:kSBBConsentSubpopulationsAPIFormat, [SBBBridgeInfo shared].studyIdentifier];
  [self.mockURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
  SBBConsentManager* consentMan = (SBBConsentManager *)SBBComponent(SBBConsentManager);

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
    kSBBKeyImageData:imageBase64String, kSBBKeyImageMimeType:kSBBMimeTypePng, kSBBKeyAPIObjectType:@"ConsentSignature"};
  NSString *endpoint = [NSString stringWithFormat:kSBBConsentSubpopulationsAPIFormat, [SBBBridgeInfo shared].studyIdentifier];
  [self.mockURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
  id<SBBConsentManagerProtocol> consentMan = SBBComponent(SBBConsentManager);

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

- (void)testGet {
    // construct consent manager with mock response
    NSDictionary* responseDict = @{kSBBKeyName:@"Eggplant McTester", kSBBKeyBirthdate:@"1970-01-01", kSBBKeyAPIObjectType:@"ConsentSignature"};
    NSString *testSubpopGuid = @"ABC123turtleturtleturtle";
    NSString *endpoint = [NSString stringWithFormat:kSBBConsentSubpopulationsAPIFormat, testSubpopGuid];
    [self.mockURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    SBBConsentManager* consentMan = (SBBConsentManager *)SBBComponent(SBBConsentManager);
    
    // execute and validate
    [consentMan getConsentSignatureForSubpopulation:testSubpopGuid completion:^(id consentSignature, NSError *error) {
        XCTAssert([@"Eggplant McTester" isEqualToString:[consentSignature name]], @"consent signature has name");
        XCTAssert([@"1970-01-01" isEqualToString:[consentSignature birthdate]], @"consent signature has birthdate");
        XCTAssertNil([consentSignature signatureImage], @"consent signature has no image");
    }];
}

- (void)testGetWithImage {
    // test signature image
    NSString* imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sample-signature" ofType:@"png"];
    NSData* imageData = [NSData dataWithContentsOfFile:imagePath];
    NSString* imageBase64String = [imageData base64EncodedStringWithOptions:kNilOptions];

    // construct consent manager with mock response
    NSDictionary* responseDict = @{kSBBKeyName:@"Eggplant McTester", kSBBKeyBirthdate:@"1970-01-01",
                                   kSBBKeyImageData:imageBase64String, kSBBKeyImageMimeType:kSBBMimeTypePng, kSBBKeyAPIObjectType:@"ConsentSignature"};
    NSString *testSubpopGuid = @"ABC123turtleturtleturtle";
    NSString *endpoint = [NSString stringWithFormat:kSBBConsentSubpopulationsAPIFormat, testSubpopGuid];
    [self.mockURLSession setJson:responseDict andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    SBBConsentManager* consentMan = (SBBConsentManager *)SBBComponent(SBBConsentManager);
    
    // execute and validate
    [consentMan getConsentSignatureForSubpopulation:testSubpopGuid completion:^(id consentSignature, NSError *error) {
        XCTAssert([@"Eggplant McTester" isEqualToString:[consentSignature name]], @"consent signature has name");
        XCTAssert([@"1970-01-01" isEqualToString:[consentSignature birthdate]], @"consent signature has birthdate");
        UIImage *signatureImage = [consentSignature signatureImage];
        
        // we validate the image simply by validating that it exists and has a positive height and width
        XCTAssertNotNil(signatureImage, @"consent signature image exists");
        XCTAssert([signatureImage size].height > 0, @"consent signature image has positive height");
        XCTAssert([signatureImage size].width > 0, @"consent signature image has positive width");
    }];
}



@end
