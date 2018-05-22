//
//  SBBBridgeTestHarness.m
//  BridgeSDK-Test
//
//    Copyright (c) 2018, Sage Bionetworks
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//        * Redistributions of source code must retain the above copyright
//          notice, this list of conditions and the following disclaimer.
//        * Redistributions in binary form must reproduce the above copyright
//          notice, this list of conditions and the following disclaimer in the
//          documentation and/or other materials provided with the distribution.
//        * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//          contributors may be used to endorse or promote products derived from
//          this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBBridgeTestHarness.h"
#import "MockURLSession.h"
#import "SBBComponentManager.h"
#import "SBBAuthManagerInternal.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBNetworkManagerInternal.h"
#import "SBBTestAuthKeychainManager.h"
#import "SBBCacheManager.h"
#import "SBBObjectManagerInternal.h"
#import "SBBCacheManager.h"
#import "SBBBridgeInfo+Internal.h"
#import "SBBStudyManagerInternal.h"

@interface SBBBridgeTestHarness ()

@property (nonatomic, strong) MockURLSession *mockURLSession;
@property (nonatomic, strong) MockURLSession *mockBackgroundURLSession;

@property (nonatomic, strong) SBBCacheManager *cacheManager;
@property (nonatomic, strong) id<SBBObjectManagerProtocol> objectManager;

@end

@implementation SBBBridgeTestHarness

- (instancetype)initWithStudyIdentifier: (NSString *)studyIdentifier {
    self = [super init];
    if (!self) { return nil; }

    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (![SBBBridgeInfo shared].studyIdentifier) {
        [[SBBBridgeInfo shared] setStudyIdentifier:studyIdentifier];
        gSBBUseCache = YES;
    }
    
    SBBBridgeNetworkManager *bridgeNetMan = (SBBBridgeNetworkManager *)SBBComponent(SBBBridgeNetworkManager);
    id mainSessionDelegate = bridgeNetMan.mainSession.delegate;
    id backgroundSessionDelegate = bridgeNetMan.backgroundSession.delegate;
    
    _mockURLSession = [MockURLSession new];
    bridgeNetMan.mainSession = _mockURLSession;
    _mockURLSession.mockDelegate = mainSessionDelegate;
    
    _mockBackgroundURLSession = [MockURLSession new];
    bridgeNetMan.backgroundSession = _mockBackgroundURLSession;
    _mockBackgroundURLSession.mockDelegate = backgroundSessionDelegate;
    
    [SBBComponentManager registerComponent:bridgeNetMan forClass:[SBBBridgeNetworkManager class]];
    
    // on first run set up an in-memory cache and an object manager that uses it, and point the global auth manager at it
    static SBBAuthManager *aMan = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aMan = (SBBAuthManager *)SBBComponent(SBBAuthManager);
        SBBCacheManager *cMan = [self testCacheManagerWithAuthManager:aMan andPersistentStoreName:@"test-store"];
        aMan.objectManager = [self testObjectManagerWithCacheManager:cMan];
    });
    
    aMan.keychainManager = [SBBTestAuthKeychainManager new];
    [aMan.keychainManager setKeysAndValues:@{ aMan.passwordKey: @"123456" }];
    
    // make sure each test that accesses Bridge APIs has access to its own object manager pointed at
    // a cache manager with a unique persistent store (by using the object instance ptr's hex representation as the store name)
    // so they can run concurrently without tripping over each other
    _cacheManager = [self testCacheManagerWithAuthManager:aMan andPersistentStoreName:[NSString stringWithFormat:@"%p", self]];
    _objectManager = [self testObjectManagerWithCacheManager:_cacheManager];
    
    // Look for an AppConfig.json file and set it up if it exists.
    NSString *endpoint = [NSString stringWithFormat:kSBBStudyAPIFormat, studyIdentifier];
    [self setJSONWithFile:@"AppConfig" forEndpoint:endpoint andMethod:@"GET"];
    
    return self;
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

- (void)setJSONWithFile:(NSString *)filename forEndpoint:(NSString *)endpoint andMethod:(NSString *)method {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:@"json"];
    if (fileURL) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:fileURL options:0 error:nil];
        if (data) {
            NSError *err;
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if (json) {
                [self.mockURLSession setJson:json andResponseCode:200 forEndpoint:endpoint andMethod:method];
            } else {
                NSLog(@"WARNING: Failed to decode JSON: %@", err);
            }
        } else {
            NSLog(@"WARNING: Failed to get data from: %@", fileURL);
        }
    }
    else {
        NSLog(@"WARNING: Failed to get url for: %@", filename);
    }
}

- (void)postStudyParticipant: (SBBStudyParticipant *)participant {
    NSDictionary *info = @{ @"authenticated" : @(true),
                            @"consented" : @(true),
                            @"reauthToken" : [[NSUUID UUID] UUIDString],
                            @"sessionToken" : [[NSUUID UUID] UUIDString],
                            @"signedMostRecentConsent" : @(true)};
    SBBUserSessionInfo *sessionInfo = [[SBBUserSessionInfo alloc] initWithDictionaryRepresentation: info];
    sessionInfo.studyParticipant = participant;
    SBBAuthManager *aMan = (SBBAuthManager *)SBBComponent(SBBAuthManager);
    [aMan postNewSessionInfo:sessionInfo];
}

@end
