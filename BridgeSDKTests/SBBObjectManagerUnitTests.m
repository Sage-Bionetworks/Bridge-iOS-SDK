//
//  SBBObjectManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <limits.h>
@import BridgeSDK;
#import "SBBTestBridgeObjects.h"
#import "NSDate+SBBAdditions.h"
#import "SBBCacheManager.h"
#import "SBBTestAuthManagerDelegate.h"
#import "SBBObjectManagerInternal.h"
#import "ModelObjectInternal.h"
#import "SBBBridgeInfo+Internal.h"

@interface SBBObjectManagerUnitTests : XCTestCase

@property (nonatomic, strong) NSDictionary *jsonForTests;
@property (nonatomic, strong) NSDictionary *mappingForObject;
@property (nonatomic, strong) NSDictionary *mappingForSubObject;
@property (nonatomic, strong) SBBCacheManager *cacheManager;
@property (nonatomic, strong) SBBObjectManager *objectManager;

@end

@implementation SBBObjectManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (![SBBBridgeInfo shared].studyIdentifier) {
        [[SBBBridgeInfo shared] setStudyIdentifier:@"ios-sdk-int-tests"];
        gSBBUseCache = YES;
    }
    static NSDictionary *json;
    static NSDictionary *objectMapping;
    static NSDictionary *subObjectMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *arrayJson =
        @[
          @{@"type": [SBBTestBridgeSubObject entityName], @"stringField": @"thing1"},
          @{@"type": [SBBTestBridgeSubObject entityName], @"stringField": @"thing2"},
          @{@"type": [SBBTestBridgeSubObject entityName], @"stringField": @"thing3"}
          ];
        
        json =
        @{
          @"guid": @"NotReallyAGuidButShouldWorkIfThere'sOnlyOne",
          @"type": [SBBTestBridgeObject entityName],
          @"stringField": @"This is a string",
          @"shortField": @-2,
          @"longField": @-3,
          @"longLongField": @-4444444444444444,
          @"uShortField": @SHRT_MAX,
          @"uLongField": @0x7fffffff,
          @"uLongLongField": @LLONG_MAX,
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
    
    id<SBBAuthManagerProtocol> aMan = SBBComponent(SBBAuthManager);
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    delegate.password = @"123456";
    aMan.authDelegate = delegate;
    _cacheManager = [SBBCacheManager cacheManagerWithDataModelName:@"TestModel" bundleId:SBBBUNDLEIDSTRING storeType:NSInMemoryStoreType authManager:aMan];
    // make sure each test has a unique persistent store (by using the object instance ptr's hex representation as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = [NSString stringWithFormat:@"%p", self];
    _objectManager = [SBBObjectManager objectManagerWithCacheManager:_cacheManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [SBBComponentManager reset];
    _jsonForTests = nil;
    
}

- (void)testObjectFromBridgeJSONNoMapping {
    SBBTestBridgeObject *testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    XCTAssert([testObject isKindOfClass:[SBBTestBridgeObject class]], @"Creates correct type");
    XCTAssert([testObject.bridgeSubObjectField isKindOfClass:[SBBTestBridgeSubObject class]], @"Creates correct subtype for Bridge-object field");
    XCTAssert([testObject.bridgeObjectArrayField[0] isKindOfClass:[SBBTestBridgeSubObject class]], @"Creates correct subtype for Bridge-object array field");
    XCTAssert([testObject.dateField isKindOfClass:[NSDate class]], @"Creates NSDate from string for date field");
    
    if (gSBBUseCache) {
        // now do it again with the same JSON and make sure it gives back the same PONSO object
        SBBTestBridgeObject *testObject2 = [_objectManager objectFromBridgeJSON:_jsonForTests];
        XCTAssertEqual(testObject2, testObject, @"Returns same instance from JSON with same entity key");
    }
}

- (void)testObjectFromBridgeJSONWithMapping {
    [_objectManager setupMappingForType:@"TestBridgeObject" toClass:[TestMappedObject class] fieldToPropertyMappings:_mappingForObject];
    [_objectManager setupMappingForType:@"TestBridgeSubObject" toClass:[TestMappedSubObject class] fieldToPropertyMappings:_mappingForSubObject];
    TestMappedObject *testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    XCTAssert([testObject isKindOfClass:[TestMappedObject class]], @"Creates correct type");
    XCTAssert([testObject.mappedObjectSubField isKindOfClass:[TestMappedSubObject class]], @"Creates correct subtype for Bridge-object field");
    XCTAssert([testObject.mappedObjectArrayField[0] isKindOfClass:[TestMappedSubObject class]], @"Creates correct subtype for Bridge-object array field");
    XCTAssert([testObject.dateStringField isKindOfClass:[NSString class]] && [[NSDate dateWithISO8601String:testObject.dateStringField] isEqual:[NSDate dateWithISO8601String:_jsonForTests[@"dateField"]]], @"Correctly maps date field as string");
    [_objectManager clearMappingForType:@"TestBridgeSubObject"];
    [_objectManager clearMappingForType:@"TestBridgeObject"];
}

- (void)testBridgeJSONFromObjectNoMapping {
    SBBTestBridgeSubObject *subObject = [SBBTestBridgeSubObject new];
    subObject.stringField = @"thing1";
    SBBTestBridgeObject *object = [SBBTestBridgeObject new];
    object.guid = _jsonForTests[@"guid"];
    object.stringField = _jsonForTests[@"stringField"];
    object.shortField = _jsonForTests[@"shortField"];
    object.longField = _jsonForTests[@"longField"];
    object.longLongField = _jsonForTests[@"longLongField"];
    object.uShortField = _jsonForTests[@"uShortField"];
    object.uLongField = _jsonForTests[@"uLongField"];
    object.uLongLongField = _jsonForTests[@"uLongLongField"];
    object.floatField = _jsonForTests[@"floatField"];
    object.doubleField = _jsonForTests[@"doubleField"];
    object.dateField = [NSDate dateWithISO8601String:_jsonForTests[@"dateField"]];
    [object setBridgeSubObjectField:subObject];
    
    for (int i = 0; i < 3; ++i) {
        SBBTestBridgeSubObject *aSubObject = [SBBTestBridgeSubObject new];
        aSubObject.stringField = [NSString stringWithFormat:@"thing%d", i];
        [object addBridgeObjectArrayFieldObject:aSubObject];
    }
    
    NSDictionary *json = [_objectManager bridgeJSONFromObject:object];
    
    XCTAssert([json isKindOfClass:[NSDictionary class]], @"Converted object to json dict");
    XCTAssert([json[@"guid"] isEqualToString:object.guid], @"Correctly set guid");
    XCTAssert([json[@"type"] isEqualToString:@"TestBridgeObject"], @"Correctly set type field");
    XCTAssert([json[@"stringField"] isEqualToString:object.stringField], @"Correctly converted string field");
    XCTAssert([json[@"shortField"] isEqual:object.shortField], @"Correctly converted short field");
    XCTAssert([json[@"longField"] isEqual:object.longField], @"Correctly converted long field");
    XCTAssert([json[@"longLongField"] isEqual:object.longLongField], @"Correctly converted long long field");
    XCTAssert([json[@"uShortField"] isEqual:object.uShortField], @"Correctly converted unsigned short field");
    XCTAssert([json[@"uLongField"] isEqual:object.uLongField], @"Correctly converted unsigned long field");
    XCTAssert([json[@"uLongLongField"] isEqual:object.uLongLongField], @"Correctly converted unsigned long long field");
    XCTAssert([json[@"floatField"] isEqual:object.floatField], @"Correctly converted float field");
    XCTAssert([json[@"doubleField"] isEqual:object.doubleField], @"Correctly converted double field");
    XCTAssert([[NSDate dateWithISO8601String:json[@"dateField"]] isEqual:object.dateField], @"Correctly converted date field");
    XCTAssert([json[@"bridgeSubObjectField"][@"stringField"] isEqualToString:subObject.stringField], @"Correctly converted sub object field");
    
    for (int i = 0; i < 3; ++i) {
        NSDictionary *item = json[@"bridgeObjectArrayField"][i];
        SBBTestBridgeSubObject *aSubObject = [object.bridgeObjectArrayField objectAtIndex:i];
        XCTAssert([item[@"stringField"] isEqualToString:aSubObject.stringField], @"Correctly converted sub object array element");
        XCTAssert([item[@"type"] isEqualToString:@"TestBridgeSubObject"], @"Correctly set sub object array element type field");
    }
}

- (void)testBridgeJSONFromObjectWithMapping {
    [_objectManager setupMappingForType:@"TestBridgeObject" toClass:[TestMappedObject class] fieldToPropertyMappings:_mappingForObject];
    [_objectManager setupMappingForType:@"TestBridgeSubObject" toClass:[TestMappedSubObject class] fieldToPropertyMappings:_mappingForSubObject];
    
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
    
    NSDictionary *json = [_objectManager bridgeJSONFromObject:testObject];
    
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
