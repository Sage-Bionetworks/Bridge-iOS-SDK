//
//  SBBCacheManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 1/5/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
@import BridgeSDK;
#import "SBBTestBridgeObjects.h"
#import "SBBCacheManager.h"
#import "SBBTestAuthManagerDelegate.h"
#import "SBBObjectManagerInternal.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"
#import "SBBBridgeInfo+Internal.h"

#define STRINGIFY2( x) #x
#define STRINGIFY(x) STRINGIFY2(x)

@interface NSManagedObject (TestBridgeObject)

@property (nullable, nonatomic, retain) NSDate* dateField;

@property (nullable, nonatomic, retain) NSNumber* doubleField;

@property (nullable, nonatomic, retain) NSNumber* floatField;

@property (nullable, nonatomic, retain) NSString* guid;

@property (nullable, nonatomic, retain) NSArray* jsonArrayField;

@property (nullable, nonatomic, retain) NSDictionary* jsonDictField;

@property (nullable, nonatomic, retain) NSNumber* longField;

@property (nullable, nonatomic, retain) NSNumber* longLongField;

@property (nullable, nonatomic, retain) NSNumber* shortField;

@property (nullable, nonatomic, retain) NSString* stringField;

@property (nullable, nonatomic, retain) NSNumber* uLongField;

@property (nullable, nonatomic, retain) NSNumber* uLongLongField;

@property (nullable, nonatomic, retain) NSNumber* uShortField;

@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *bridgeObjectArrayField;

@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *bridgeObjectSetField;

@property (nullable, nonatomic, retain) NSManagedObject *bridgeSubObjectField;

- (void)addBridgeObjectArrayFieldObject:(NSManagedObject *)value;
- (void)removeBridgeObjectArrayFieldObject:(NSManagedObject *)value;
- (void)addBridgeObjectArrayField:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeBridgeObjectArrayField:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBridgeObjectArrayFieldAtIndex:(NSUInteger)idx;
- (void)insertBridgeObjectArrayField:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBridgeObjectArrayFieldAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceBridgeObjectArrayFieldAtIndexes:(NSIndexSet *)indexes withBridgeObjectArrayField:(NSArray<NSManagedObject *> *)values;

- (void)addBridgeObjectSetFieldObject:(NSManagedObject *)value;
- (void)removeBridgeObjectSetFieldObject:(NSManagedObject *)value;

- (void)addBridgeObjectSetField:(NSSet<NSManagedObject *> *)values;
- (void)removeBridgeObjectSetField:(NSSet<NSManagedObject *> *)values;

@end

@interface NSManagedObject (TestBridgeSubObject)

@property (nullable, nonatomic, retain) NSString* stringField;

@property (nullable, nonatomic, retain) NSManagedObject *testBridgeObjectArray;

@property (nullable, nonatomic, retain) NSManagedObject *testBridgeObjectSet;

@end

@interface SBBCacheManagerUnitTests : XCTestCase

@property (nonatomic, strong) NSMutableDictionary *jsonForTests;
@property (nonatomic, strong) SBBCacheManager *cacheManager;
@property (nonatomic, strong) id<SBBObjectManagerProtocol> objectManager;

@end

@implementation SBBCacheManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (![SBBBridgeInfo shared].studyIdentifier) {
        [[SBBBridgeInfo shared] setStudyIdentifier:@"ios-sdk-int-tests"];
        gSBBUseCache = YES;
    }
    id<SBBAuthManagerProtocol> aMan = SBBComponent(SBBAuthManager);
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    delegate.password = @"123456";
    aMan.authDelegate = delegate;
    _cacheManager = [SBBCacheManager cacheManagerWithDataModelName:@"TestModel" bundleId:SBBBUNDLEIDSTRING storeType:NSInMemoryStoreType authManager:aMan];
    _objectManager = [SBBObjectManager objectManagerWithCacheManager:_cacheManager];

    static NSDictionary *json;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *arrayJson =
        @[
          @{@"type": [SBBTestBridgeSubObject entityName], @"stringField": @"thing1"},
          @{@"type": [SBBTestBridgeCacheableSubObject entityName], @"stringField": @"thing2"},
          @{@"type": [SBBTestBridgeSubObject entityName], @"stringField": @"thing3"}
          ];
        
        NSArray *setJson =
        @[
          @{@"type": [SBBTestBridgeCacheableSubObject entityName], @"stringField": @"dingEins"},
          @{@"type": [SBBTestBridgeSubObject entityName], @"stringField": @"dingZwei"},
          @{@"type": [SBBTestBridgeCacheableSubObject entityName], @"stringField": @"dingDrei"}
          ];
        
        json =
        @{
          @"guid": @"placeholder",
          @"type": [SBBTestBridgeObject entityName],
          @"stringField": @"This is a string",
          @"shortField": @-2,
          @"longField": @-3,
          @"longLongField": @-4444444444444444,
          @"uShortField": @SHRT_MAX,
          @"uLongField": @0x7fffffff,
          @"uLongLongField": @LLONG_MAX,
          @"floatField": @3.7e-3f,
          @"doubleField": @6.022e123,
          @"dateField": @"2011-12-03T22:11:34.554Z",
          @"jsonArrayField": @[@"thing1", @"thing2", @"thing3"],
          @"jsonDictField": @{@"thing1": @1, @"thing2": @2, @"thing3": @3},
          @"bridgeSubObjectField": @{@"type": @"TestBridgeSubObject", @"stringField": @"sub object"},
          @"bridgeObjectArrayField": arrayJson,
          @"bridgeObjectSetField": setJson,
          @"noSuchField": @{@"something": @"goes here"}
          };
    });
    
    // give each test's json object a unique entity key so they can
    // run concurrently without tripping over each other
    _jsonForTests = [json mutableCopy];
    _jsonForTests[@"guid"] = [NSUUID UUID].UUIDString;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [_cacheManager resetCache];
    [SBBComponentManager reset];
    _jsonForTests = nil;
}

- (void)testCachedObjectOfTypewithIdcreateIfMissing {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    // first try getting a cached object that doesn't exist yet (not creating if missing)
    ModelObject *object = [_cacheManager cachedObjectOfType:_jsonForTests[@"type"] withId:_jsonForTests[@"guid"] createIfMissing:NO];
    XCTAssertNil(object, @"Successfully failed to get non-existent cached object");
    
    // now try getting one that doesn't exist, creating if missing
    object = [_cacheManager cachedObjectOfType:_jsonForTests[@"type"] withId:_jsonForTests[@"guid"] createIfMissing:YES];
    XCTAssertNotNil(object, @"Successfully got (created) previously non-existent cached object");
    XCTAssert([object isKindOfClass:[SBBTestBridgeObject class]], @"Created object is of class SBBTestBridgeObject");
    
    SBBTestBridgeObject *testObject = (SBBTestBridgeObject *)object;
    XCTAssertEqualObjects(testObject.guid, _jsonForTests[@"guid"], @"Created object has correct guid");
    XCTAssertNil(testObject.stringField, @"Created object correctly has nil stringField");
    
    // now create an object with the same guid from JSON
    SBBTestBridgeObject *newTestObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    
    // ...and make sure it's the same actual object we got before, just updated
    XCTAssertEqual(testObject, newTestObject, @"Created object with same guid is the same object as before");
    XCTAssertEqualObjects(testObject.stringField, _jsonForTests[@"stringField"], @"Existing object was updated from JSON");
}

- (void)compareJSON:(id)json toManagedObject:(NSManagedObject *)mo
{
    NSDictionary<NSString *,__kindof NSPropertyDescription *> *props = mo.entity.propertiesByName;
    for (NSString *key in props) {
        id jsonForKey = json[key];
        id cachedForKey = [mo valueForKey:key];
        NSPropertyDescription *prop = props[key];
        
        // skip fields that aren't included in the JSON/PONSO objects
        if (!prop.userInfo[@"notInPONSODictionary"]) {
            if ([prop isKindOfClass:[NSAttributeDescription class]]) {
                NSAttributeDescription *attr = (NSAttributeDescription *)prop;
                if ([attr.attributeValueClassName isEqualToString:@"NSDate"]) {
                    NSDate *dateFromJSON = [NSDate dateWithISO8601String:[_jsonForTests objectForKey:@"dateField"]];
                    XCTAssertEqualObjects(dateFromJSON, cachedForKey, @"%@ NSDate field cached correctly", key);
                } else {
                    XCTAssertEqualObjects(jsonForKey, cachedForKey, @"%@ %@ field cached correctly", key, attr.attributeValueClassName);
                }
            } else if ([prop isKindOfClass:[NSRelationshipDescription class]]) {
                NSRelationshipDescription *rel = (NSRelationshipDescription *)prop;
                if (rel.toMany) {
                    XCTAssertEqual([jsonForKey count], [cachedForKey count], @"count (%lu) of items for %@ relationship matches JSON", (unsigned long)[jsonForKey count], key);
                } else {
                    [self compareJSON:jsonForKey toManagedObject:(NSManagedObject *)cachedForKey];
                }
            }
        }
    }
}

- (void)testCachedObjectFromBridgeJSON {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    id testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    XCTAssert([testObject isKindOfClass:[SBBTestBridgeObject class]], @"Returned NSObject is of expected class");

    NSManagedObjectContext *context = _cacheManager.cacheIOContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:[SBBTestBridgeObject entityName] inManagedObjectContext:context];
    __block NSManagedObject *fetchedMO = nil;
    [context performBlockAndWait:^{
        fetchedMO = [_cacheManager managedObjectOfEntity:entity withId:_jsonForTests[@"guid"] atKeyPath:@"guid"];
    }];
    XCTAssert([fetchedMO.bridgeSubObjectField.entity.name isEqualToString:[SBBTestBridgeSubObject entityName]], @"Cached NSManagedObject's bridgeSubObjectField contains a TestBridgeSubObject entity");
    XCTAssert([fetchedMO.bridgeObjectArrayField isKindOfClass:[NSOrderedSet class]], @"Cached NSManagedObject's bridgeObjectArrayField contains an ordered set");
    XCTAssert([fetchedMO.bridgeObjectSetField isKindOfClass:[NSSet class]], @"Cached NSManagedObject's bridgeObjectSetField contains an unordered set");
    
    [self compareJSON:_jsonForTests toManagedObject:fetchedMO];
    
    SBBTestBridgeObject *reconstitutedObject = [[SBBTestBridgeObject alloc] initWithManagedObject:fetchedMO objectManager:_objectManager cacheManager:_cacheManager];
    NSMutableDictionary *reconstitutedJSON = [[reconstitutedObject dictionaryRepresentation] mutableCopy];
    NSDate *reconstitutedDate = [NSDate dateWithISO8601String:[reconstitutedJSON objectForKey:@"dateField"]];
    [reconstitutedJSON removeObjectForKey:@"dateField"];
    NSSet *reconstitutedSet = [NSSet setWithArray:[reconstitutedJSON objectForKey:@"bridgeObjectSetField"]];
    [reconstitutedJSON removeObjectForKey:@"bridgeObjectSetField"];
    NSMutableDictionary *cleanedOriginal = [_jsonForTests mutableCopy];
    [cleanedOriginal removeObjectForKey:@"noSuchField"];
    NSDate *originalDate = [NSDate dateWithISO8601String:[cleanedOriginal objectForKey:@"dateField"]];
    [cleanedOriginal removeObjectForKey:@"dateField"];
    NSSet *originalSet = [NSSet setWithArray:[cleanedOriginal objectForKey:@"bridgeObjectSetField"]];
    [cleanedOriginal removeObjectForKey:@"bridgeObjectSetField"];
    XCTAssertEqualObjects(reconstitutedDate, originalDate, @"Roundtrip preserves equivalence of date field, if not original time zone offset");
    XCTAssertEqualObjects(reconstitutedSet, originalSet, @"Roundtrip preserves membership of set field, if not original JSON array item order");
    XCTAssert([reconstitutedJSON isEqualToDictionary:cleanedOriginal], @"Roundtrip results in JSON identical to the original (except for the unsupported key in the original JSON)");
}

- (void)testCachedObjectForBridgeObject {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    // create & cache the test object
    ModelObject *testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    
    // now get it from the cache
    NSManagedObject *testCachedObject = [_cacheManager cachedObjectForBridgeObject:testObject inContext:_cacheManager.cacheIOContext];
    [self compareJSON:_jsonForTests toManagedObject:testCachedObject];
}

- (void)testManagedObjectOfEntitywithIdatKeyPath {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    // create & cache a directly-cacheable test object
    id testJSONDirectlyCacheable = @{@"type": [SBBTestBridgeCacheableSubObject entityName], @"stringField": @"testManagedObjectOfEntitywithIdatKeyPath"};
    NSString *keyPath = @"stringField";
    __unused ModelObject *testObject = [_objectManager objectFromBridgeJSON:testJSONDirectlyCacheable];
    
    // now try to get it from the cache
    NSManagedObjectContext *context = _cacheManager.cacheIOContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:testJSONDirectlyCacheable[@"type"] inManagedObjectContext:context];
    __block NSManagedObject *fetchedMO = nil;
    [context performBlockAndWait:^{
        fetchedMO = [_cacheManager managedObjectOfEntity:entity withId:testJSONDirectlyCacheable[keyPath] atKeyPath:keyPath];
    }];
    
    XCTAssertNotNil(fetchedMO, @"Successfully retrieved directly-cacheable test object");
    if (fetchedMO) {
        // make sure it matches the JSON
        [self compareJSON:testJSONDirectlyCacheable toManagedObject:fetchedMO];

        // ...and then delete it
        [_cacheManager removeFromCacheObjectOfType:testJSONDirectlyCacheable[@"type"] withId:testJSONDirectlyCacheable[keyPath]];
    }
    
    // now create a non-directly-cacheable test object
    id testJSONNonDirectlyCacheable = @{@"type": [SBBTestBridgeSubObject entityName], @"stringField": @"testManagedObjectOfEntitywithIdatKeyPath"};
    testObject = [_objectManager objectFromBridgeJSON:testJSONNonDirectlyCacheable];
    
    // now try to get it from the cache and make sure it's not there
    entity = [NSEntityDescription entityForName:testJSONNonDirectlyCacheable[@"type"] inManagedObjectContext:context];
    [context performBlockAndWait:^{
        fetchedMO = [_cacheManager managedObjectOfEntity:entity withId:testJSONNonDirectlyCacheable[keyPath] atKeyPath:keyPath];
    }];
    
    XCTAssertNil(fetchedMO, @"Successfully failed to retrieve non-directly-cacheable test object");
    
    // now try a fancy-schmancy key path with indexes and everything
    testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    entity = [NSEntityDescription entityForName:_jsonForTests[@"type"] inManagedObjectContext:context];
    [context performBlockAndWait:^{
        fetchedMO = [_cacheManager managedObjectOfEntity:entity withId:@"thing2" atKeyPath:@"bridgeObjectArrayField[1].stringField"];
    }];

    XCTAssertNotNil(fetchedMO, @"Successfully retrieved test object with indexed key path");
    if (fetchedMO) {
        // make sure it matches the JSON
        [self compareJSON:_jsonForTests toManagedObject:fetchedMO];
    }
}

- (void)testRemoveFromCacheObjectOfTypewithId {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    // create & cache the test object
    NSManagedObjectContext *context = _cacheManager.cacheIOContext;
    NSString *type = _jsonForTests[@"type"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:type inManagedObjectContext:context];
    NSString *keyPath = entity.userInfo[@"entityIDKeyPath"];
    NSString *objectId = [_jsonForTests valueForKeyPath:keyPath];
    SBBBridgeObject_test *testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];

    // make sure it's in the cache now, both in CoreData and in memory, before testing removal
    ModelObject *cachedObject = [_cacheManager cachedObjectOfType:type withId:objectId createIfMissing:NO];
    XCTAssertNotNil(cachedObject, @"Test object is in the memory cache");
    
    NSManagedObject *fetchedMO = [_cacheManager cachedObjectForBridgeObject:testObject inContext:context];
    XCTAssertNotNil(fetchedMO, @"Test object is in the CoreData cache");
    
    // now remove it
    [_cacheManager removeFromCacheObjectOfType:type withId:objectId];
    
    // make sure the object itself is gone, both from memory and CoreData
    cachedObject = [_cacheManager cachedObjectOfType:type withId:objectId createIfMissing:NO];
    XCTAssertNil(cachedObject, @"Test object has been removed from the memory cache");
    
    fetchedMO = [_cacheManager cachedObjectForBridgeObject:testObject inContext:context];
    XCTAssertNil(fetchedMO, @"Test object has been removed from the CoreData cache");
    
    // ...aaand make sure the cache (which was pristine at the start of this test) is now empty
    NSEntityDescription *baseEntity = [NSEntityDescription entityForName:[SBBBridgeObject_test entityName] inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:baseEntity];
    
    __block NSArray *objects = nil;
    __block NSError *error = nil;
    [context performBlockAndWait:^{
        objects = [context executeFetchRequest:request error:&error];
    }];
    
    XCTAssert(objects.count == 0, @"There are no entities of type BridgeObject_test in the CoreData cache");
    
    NSDictionary *memCache = [_cacheManager performSelector:@selector(objectsCachedByTypeAndID)];
    XCTAssert(memCache.count == 0, @"The in-memory cache is empty");
}

- (void)testWriteableObjectsDontOverwriteFromServer {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    _jsonForTests[@"type"] = [SBBTestBridgeWritableObject entityName];
    SBBTestBridgeWritableObject *testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    XCTAssert([testObject isKindOfClass:[SBBTestBridgeWritableObject class]], @"Returned NSObject is of expected class");
    
    NSString *oldStringField = testObject.stringField;
    NSString *newStringField = [oldStringField stringByAppendingString:@" too, but not the same string"];
    testObject.stringField = newStringField;
    
    // now "fetch the object from the server" again
    SBBTestBridgeWritableObject *reTestObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    
    // it should be the same actual object
    XCTAssertEqual(reTestObject, testObject, @"Object manager returns the same PONSO object for the same guid");
    
    // it should still have the new string field even though it was created from JSON with the old
    XCTAssertEqualObjects(reTestObject.stringField, newStringField, @"Cache manager didn't overwrite object with writable fields");
}

- (void)testExtendableObjectsDontOverwriteFromServer {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    _jsonForTests[@"type"] = [SBBTestBridgeExtendableObject entityName];
    SBBTestBridgeExtendableObject *testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    XCTAssert([testObject isKindOfClass:[SBBTestBridgeExtendableObject class]], @"Returned NSObject is of expected class");
    
    NSString *oldStringField = testObject.stringField;
    NSString *newStringField = [oldStringField stringByAppendingString:@" too, but not the same string"];
    testObject.stringField = newStringField;
    
    // now "fetch the object from the server" again
    SBBTestBridgeExtendableObject *reTestObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    
    // it should be the same actual object
    XCTAssertEqual(reTestObject, testObject, @"Object manager returns the same PONSO object for the same guid");
    
    // it should still have the new string field even though it was created from JSON with the old
    XCTAssertEqualObjects(reTestObject.stringField, newStringField, @"Cache manager didn't overwrite extendable object");
}

- (void)testReadonlyObjectsDoOverwriteFromServer {
    // make sure each test has a unique persistent store (by using the method name as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager.persistentStoreName = NSStringFromSelector(_cmd);
    
    SBBTestBridgeObject *testObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    XCTAssert([testObject isKindOfClass:[SBBTestBridgeObject class]], @"Returned NSObject is of expected class");
    
    NSString *oldStringField = testObject.stringField;
    NSString *newStringField = [oldStringField stringByAppendingString:@" too, but not the same string"];
    testObject.stringField = newStringField;
    
    // now "fetch the object from the server" again
    SBBTestBridgeObject *reTestObject = [_objectManager objectFromBridgeJSON:_jsonForTests];
    
    // it should be the same actual object
    XCTAssertEqual(reTestObject, testObject, @"Object manager returns the same PONSO object for the same guid");
    
    // it should once again have the old string field
    XCTAssertEqualObjects(reTestObject.stringField, oldStringField, @"Cache manager did overwrite 'read-only' object");
}

@end
