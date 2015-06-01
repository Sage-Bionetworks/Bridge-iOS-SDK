//
//  SBBObjectManagerTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <limits.h>
@import BridgeSDK;
#import "SBBTestBridgeObject.h"
#import "NSDate+SBBAdditions.h"

#if !defined INT_MAX
#error INT_MAX not defined!
#endif

@interface SBBObjectManagerTests : XCTestCase

@property (nonatomic, strong) NSDictionary *jsonForTests;
@property (nonatomic, strong) NSDictionary *mappingForObject;
@property (nonatomic, strong) NSDictionary *mappingForSubObject;

@end

@implementation SBBObjectManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  static NSDictionary *json;
  static NSDictionary *objectMapping;
  static NSDictionary *subObjectMapping;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSArray *arrayJson =
    @[
      @{@"type": @"TestBridgeSubObject", @"stringField": @"thing1"},
      @{@"type": @"TestBridgeSubObject", @"stringField": @"thing2"},
      @{@"type": @"TestBridgeSubObject", @"stringField": @"thing3"}
      ];
    
    json =
    @{
      @"type": @"TestBridgeObject",
      @"stringField": @"This is a string",
      @"charField": @'x',
      @"intField": @-1,
      @"shortField": @-2,
      @"longField": @-3,
      @"longLongField": @-4444444444444444,
      @"uCharField": @UCHAR_MAX,
      @"uIntField": @UINT_MAX,
      @"uShortField": @USHRT_MAX,
      @"uLongField": @ULONG_MAX,
      @"uLongLongField": @ULLONG_MAX,
      @"floatField": @3.7e-3,
      @"doubleField": @6.022e123,
      @"dateField": @"2011-12-03T22:11:34.554Z",
      @"jsonArrayField": @[@"thing1", @"thing2", @"thing3"],
      @"jsonDictField": @{@"thing1": @1, @"thing2": @2, @"thing3": @3},
      @"bridgeSubObjectField": @{@"type": @"TestBridgeSubObject", @"stringField": @"sub object"},
      @"bridgeObjectArrayField": arrayJson,
      @"noSuchField": @{@"something": @"goes here"}
      };
    
    objectMapping =
    @{
      @"uIntField": @"numericField",
      @"bridgeObjectArrayField": @"mappedObjectArrayField",
      @"bridgeSubObjectField": @"mappedObjectSubField",
      @"dateField": @"dateStringField"
      };
    
    subObjectMapping =
    @{
      @"stringField": @"textField"
      };
  });
  
  _jsonForTests = json;
  _mappingForObject = objectMapping;
  _mappingForSubObject = subObjectMapping;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
  _jsonForTests = nil;
}

- (void)testObjectFromBridgeJSONNoMapping {
  SBBTestBridgeObject *testObject = [SBBComponent(SBBObjectManager) objectFromBridgeJSON:_jsonForTests];
  XCTAssert([testObject isKindOfClass:[SBBTestBridgeObject class]], @"Creates correct type");
  XCTAssert([testObject.bridgeSubObjectField isKindOfClass:[SBBTestBridgeSubObject class]], @"Creates correct subtype for Bridge-object field");
  XCTAssert([testObject.bridgeObjectArrayField[0] isKindOfClass:[SBBTestBridgeSubObject class]], @"Creates correct subtype for Bridge-object array field");
  XCTAssert([testObject.dateField isKindOfClass:[NSDate class]], @"Creates NSDate from string for date field");
}

- (void)testObjectFromBridgeJSONWithMapping {
  id<SBBObjectManagerProtocol> om = SBBComponent(SBBObjectManager);
  [om setupMappingForType:@"TestBridgeObject" toClass:[TestMappedObject class] fieldToPropertyMappings:_mappingForObject];
  [om setupMappingForType:@"TestBridgeSubObject" toClass:[TestMappedSubObject class] fieldToPropertyMappings:_mappingForSubObject];
  TestMappedObject *testObject = [SBBComponent(SBBObjectManager) objectFromBridgeJSON:_jsonForTests];
  XCTAssert([testObject isKindOfClass:[TestMappedObject class]], @"Creates correct type");
  XCTAssert([testObject.mappedObjectSubField isKindOfClass:[TestMappedSubObject class]], @"Creates correct subtype for Bridge-object field");
  XCTAssert([testObject.mappedObjectArrayField[0] isKindOfClass:[TestMappedSubObject class]], @"Creates correct subtype for Bridge-object array field");
  XCTAssert([testObject.dateStringField isKindOfClass:[NSString class]] && [testObject.dateStringField isEqualToString:_jsonForTests[@"dateField"]], @"Correctly maps date field as string");
  [om clearMappingForType:@"TestBridgeSubObject"];
  [om clearMappingForType:@"TestBridgeObject"];
}

- (void)testBridgeJSONFromObjectNoMapping {
  SBBTestBridgeSubObject *subObject = [SBBTestBridgeSubObject new];
  subObject.stringField = @"thing1";
  SBBTestBridgeObject *object = [SBBTestBridgeObject new];
  object.stringField = _jsonForTests[@"stringField"];
  object.charField = [_jsonForTests[@"charField"] charValue];
  object.intField = [_jsonForTests[@"intField"] intValue];
  object.shortField = [_jsonForTests[@"shortField"] shortValue];
  object.longField = [_jsonForTests[@"longField"] longValue];
  object.longLongField = [_jsonForTests[@"longLongField"] longLongValue];
  object.uCharField = [_jsonForTests[@"uCharField"] unsignedCharValue];
  object.uIntField = [_jsonForTests[@"uIntField"] unsignedIntValue];
  object.uShortField = [_jsonForTests[@"uShortField"] unsignedShortValue];
  object.uLongField = [_jsonForTests[@"uLongField"] unsignedLongValue];
  object.uLongLongField = [_jsonForTests[@"uLongLongField"] unsignedLongLongValue];
  object.floatField = [_jsonForTests[@"floatField"] floatValue];
  object.doubleField = [_jsonForTests[@"doubleField"] doubleValue];
  object.dateField = [NSDate dateWithISO8601String:_jsonForTests[@"dateField"]];
  object.bridgeSubObjectField = subObject;
  
  NSMutableArray *subObjectArray = [NSMutableArray array];
  for (int i = 0; i < 3; ++i) {
    SBBTestBridgeSubObject *object = [SBBTestBridgeSubObject new];
    object.stringField = [NSString stringWithFormat:@"thing%d", i];
    [subObjectArray addObject:object];
  }
  object.bridgeObjectArrayField = subObjectArray;
 
  NSDictionary *json = [SBBComponent(SBBObjectManager) bridgeJSONFromObject:object];

  XCTAssert([json isKindOfClass:[NSDictionary class]], @"Converted object to json dict");
  XCTAssert([json[@"type"] isEqualToString:@"TestBridgeObject"], @"Correctly set type field");
  XCTAssert([json[@"stringField"] isEqualToString:object.stringField], @"Correctly converted string field");
  XCTAssert(json[@"charField"] == nil, @"Correctly ignored char field");
  XCTAssert(json[@"intField"] == nil, @"Correctly ignored int field");
  XCTAssert(json[@"shortField"] == nil, @"Correctly ignored short field");
  XCTAssert(json[@"longField"] == nil, @"Correctly ignored long field");
  XCTAssert(json[@"longLongField"] == nil, @"Correctly ignored long long field");
  XCTAssert(json[@"uCharField"] == nil, @"Correctly ignored unsigned char field");
  XCTAssert(json[@"uIntField"] == nil, @"Correctly ignored unsigned int field");
  XCTAssert(json[@"uShortField"] == nil, @"Correctly ignored unsigned short field");
  XCTAssert(json[@"uLongField"] == nil, @"Correctly ignored unsigned long field");
  XCTAssert(json[@"uLongLongField"] == nil, @"Correctly ignored unsigned long long field");
  XCTAssert(json[@"floatField"] == nil, @"Correctly ignored float field");
  XCTAssert(json[@"doubleField"] == nil, @"Correctly ignored double field");
  XCTAssert([[NSDate dateWithISO8601String:json[@"dateField"]] isEqual:object.dateField], @"Correctly converted date field");
  XCTAssert([json[@"bridgeSubObjectField"][@"stringField"] isEqualToString:subObject.stringField], @"Correctly converted sub object field");
  
  for (int i = 0; i < 3; ++i) {
    NSDictionary *item = json[@"bridgeObjectArrayField"][i];
    SBBTestBridgeSubObject *object = subObjectArray[i];
    XCTAssert([item[@"stringField"] isEqualToString:object.stringField], @"Correctly converted sub object array element");
    XCTAssert([item[@"type"] isEqualToString:@"TestBridgeSubObject"], @"Correctly set sub object array element type field");
  }
}

- (void)testBridgeJSONFromObjectWithMapping {
  id<SBBObjectManagerProtocol> om = [SBBObjectManager objectManager];
  [om setupMappingForType:@"TestBridgeObject" toClass:[TestMappedObject class] fieldToPropertyMappings:_mappingForObject];
  [om setupMappingForType:@"TestBridgeSubObject" toClass:[TestMappedSubObject class] fieldToPropertyMappings:_mappingForSubObject];
  
  TestMappedSubObject *testSubObject = [TestMappedSubObject new];
  testSubObject.textField = @"thing1";
  
  NSMutableArray *testSubObjectArray = [NSMutableArray array];
  for (int i = 0; i < 3; ++i) {
    TestMappedSubObject *object = [TestMappedSubObject new];
    object.textField = [NSString stringWithFormat:@"thing%d", i];
    [testSubObjectArray addObject:object];
  }
  
  TestMappedObject *testObject = [TestMappedObject new];
  testObject.mappedObjectSubField = testSubObject;
  testObject.mappedObjectArrayField = testSubObjectArray;
  testObject.numericField = 6072.0;

  NSDictionary *json = [om bridgeJSONFromObject:testObject];

  XCTAssert([json isKindOfClass:[NSDictionary class]], @"Converted object to json dict");
  NSLog(@"json type: '%@'", json[@"type"]);
  XCTAssert([json[@"type"] isEqualToString:@"TestBridgeObject"], @"Correctly set type field");
  XCTAssert([json[@"uIntField"] unsignedIntValue] == 6072, @"Correctly converted numericField to uIntField");
  XCTAssert([json[@"bridgeSubObjectField"] isKindOfClass:[NSDictionary class]], @"Converted sub object to json dict");
  XCTAssert([json[@"bridgeSubObjectField"][@"stringField"] isEqualToString:testSubObject.textField], @"Correctly converted sub object's textField to stringField");
  
  for (int i = 0; i < 3; ++i) {
    NSDictionary *item = json[@"bridgeObjectArrayField"][i];
    TestMappedSubObject *object = testSubObjectArray[i];
    XCTAssert([item[@"stringField"] isEqualToString:object.textField], @"Correctly converted sub object array element");
    NSLog(@"item type: '%@'", item[@"type"]);
    XCTAssert([item[@"type"] isEqualToString:@"TestBridgeSubObject"], @"Correctly set sub object array element type field");
  }
}

@end
