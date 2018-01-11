//
//  SBBBridgeAPIUnitTestCase.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBNetworkManagerInternal.h"
#import "TestAdminAuthDelegate.h"
#import "SBBTestAuthManagerDelegate.h"
#import "SBBCacheManager.h"
#import "SBBObjectManagerInternal.h"
#import "SBBCacheManager.h"
#import "SBBBridgeInfo+Internal.h"

@interface SBBBridgeAPIUnitTestCase ()

@property (nonatomic, strong) NSURLSession *savedMainSession;
@property (nonatomic, strong) NSURLSession *savedBackgroundSession;

@end

@implementation SBBBridgeAPIUnitTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (![SBBBridgeInfo shared].studyIdentifier) {
        [[SBBBridgeInfo shared] setStudyIdentifier:@"ios-sdk-int-tests"];
        gSBBUseCache = YES;
    }
    _mockURLSession = [MockURLSession new];
    SBBBridgeNetworkManager *bridgeNetMan = (SBBBridgeNetworkManager *)SBBComponent(SBBBridgeNetworkManager);
    _savedMainSession = bridgeNetMan.mainSession;
    bridgeNetMan.mainSession = _mockURLSession;
    _mockURLSession.mockDelegate = _savedMainSession.delegate;
    
    _mockBackgroundURLSession = [MockURLSession new];
    _savedBackgroundSession = bridgeNetMan.backgroundSession;
    bridgeNetMan.backgroundSession = _mockBackgroundURLSession;
    _mockBackgroundURLSession.mockDelegate = _savedBackgroundSession.delegate;
    
    [SBBComponentManager registerComponent:bridgeNetMan forClass:[SBBBridgeNetworkManager class]];
    
    // on first run set up an in-memory cache and an object manager that uses it, and point the global auth manager at it
    static SBBAuthManager *aMan = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aMan = (SBBAuthManager *)SBBComponent(SBBAuthManager);
        SBBCacheManager *cMan = [self testCacheManagerWithAuthManager:aMan andPersistentStoreName:@"test-store"];
        aMan.objectManager = [self testObjectManagerWithCacheManager:cMan];
    });
    
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    delegate.password = @"123456";
    aMan.authDelegate = delegate;
    
    // make sure each test that accesses Bridge APIs has access to its own object manager pointed at
    // a cache manager with a unique persistent store (by using the object instance ptr's hex representation as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager = [self testCacheManagerWithAuthManager:aMan andPersistentStoreName:[NSString stringWithFormat:@"%p", self]];
    _objectManager = [self testObjectManagerWithCacheManager:_cacheManager];
}

- (SBBCacheManager *)testCacheManagerWithAuthManager:(id<SBBAuthManagerProtocol>)aMan andPersistentStoreName:(NSString *)name {
    // use the "real" Bridge data model for cache managers for tests that access Bridge APIs, but use in-memory store
    // so it doesn't persist across test runs on a given simulator
    SBBCacheManager *cacheManager = [SBBCacheManager cacheManagerWithDataModelName:@"SBBDataModel" bundleId:SBBBUNDLEIDSTRING storeType:NSInMemoryStoreType authManager:aMan];
    // also give each cache manager a different persistent store name
    cacheManager.persistentStoreName = name;
    
    return cacheManager;
}

- (SBBObjectManager *)testObjectManagerWithCacheManager:(SBBCacheManager *)cacheManager {
    return [SBBObjectManager objectManagerWithCacheManager:cacheManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    SBBBridgeNetworkManager *bridgeNetMan = (SBBBridgeNetworkManager *)SBBComponent(SBBBridgeNetworkManager);
    bridgeNetMan.mainSession = _savedMainSession;

    [super tearDown];
    [_cacheManager resetCache];
    [SBBComponentManager reset];
}

@end
