//
//  BridgeSDK.m
//  BridgeSDK
//
//	Copyright (c) 2014-2018, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "BridgeSDK+Internal.h"
#import "SBBAuthManagerInternal.h"
#import "SBBCacheManager.h"
#import "BridgeAPI/SBBBridgeInfo+Internal.h"
#import "ModelObjectInternal.h"
#import "SBBEncryptor.h"

const NSInteger SBBDefaultCacheDaysAhead = 4;
const NSInteger SBBDefaultCacheDaysBehind = 7;

const NSString *SBBDefaultUserDefaultsSuiteName = @"org.sagebase.Bridge";
const NSString *SBBAppConfigDefaultsKey = @"SBBAppConfig";

NSNotificationName const kSBBAppConfigUpdatedNotification = @"SBBAppConfigUpdatedNotification";
NSString * const kSBBAppConfigInfoKey = @"SBBAppConfigInfoKey";

id<SBBBridgeErrorUIDelegate> gSBBErrorUIDelegate = nil;
SBBAppConfig *gSBBAppConfig = nil;

@implementation BridgeSDK

+ (void)setup
{
    NSDictionary *plistDict = [SBBBridgeInfo dictionaryFromDefaultPlists];
    SBBBridgeInfo *defaultInfo = [[SBBBridgeInfo alloc] initWithDictionary:plistDict];
    [self setupWithBridgeInfo:defaultInfo];
}

+ (void)setupWithBridgeInfo:(id<SBBBridgeInfoProtocol>)info
{
    SBBBridgeInfo *sharedInfo = [SBBBridgeInfo shared];
    [sharedInfo copyFromBridgeInfo:info];
    gSBBUseCache = sharedInfo.cacheDaysAhead > 0 || sharedInfo.cacheDaysBehind > 0;
    
    // make sure the Bridge network manager is set up as the delegate for the background session
    [SBBComponent(SBBBridgeNetworkManager) restoreBackgroundSession:kBackgroundSessionIdentifier completionHandler:nil];
    
    // (re-)load the AppConfig for the specified study for this client version/platform/etc.
    [self loadAppConfig];
    
    // post the user session updated notification so subscribers get it without having to wait for the next sign-in/reauth
    id authMan = SBBComponent(SBBAuthManager);
    if ([authMan respondsToSelector:@selector(postUserSessionUpdatedNotification)]) {
        [authMan postUserSessionUpdatedNotification];
    }

    // now kickstart any potentially "orphaned" file uploads from a background thread (but first create the upload
    // manager instance so its notification handlers get set up in time)
    id<SBBUploadManagerProtocol> uMan = SBBComponent(SBBUploadManager);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray<NSString *> *uploads = SBBEncryptor.encryptedFilesAwaitingUploadResponse;
        for (NSString *file in uploads) {
            @autoreleasepool {
                NSURL *fileUrl = [NSURL fileURLWithPath:file];
                [uMan uploadFileToBridge:fileUrl completion:^(NSError *error) {
                    if (!error) {
                        [SBBEncryptor cleanUpEncryptedFile:fileUrl];
                    }
                }];
            }
        }
    });
}

+ (void)setupWithStudy:(NSString *)study
{
    [self setupWithStudy:study cacheDaysAhead:0 cacheDaysBehind:0 environment:gDefaultEnvironment];
}

+ (void)setupWithStudy:(NSString *)study useCache:(BOOL)useCache
{
    NSInteger cacheDaysAhead = useCache ? SBBDefaultCacheDaysAhead : 0;
    NSInteger cacheDaysBehind = useCache ? SBBDefaultCacheDaysBehind : 0;
    [self setupWithStudy:study cacheDaysAhead:cacheDaysAhead cacheDaysBehind:cacheDaysBehind environment:gDefaultEnvironment];
}

+ (void)setupWithAppPrefix:(NSString *)appPrefix
{
    [self setupWithStudy:appPrefix];
}

+ (void)setupWithStudy:(NSString *)study environment:(SBBEnvironment)environment
{
    [self setupWithStudy:study cacheDaysAhead:0 cacheDaysBehind:0 environment:environment];
}

+ (void)setupWithStudy:(NSString *)study useCache:(BOOL)useCache environment:(SBBEnvironment)environment
{
    NSInteger cacheDaysAhead = useCache ? SBBDefaultCacheDaysAhead : 0;
    NSInteger cacheDaysBehind = useCache ? SBBDefaultCacheDaysBehind : 0;
    [self setupWithStudy:study cacheDaysAhead:cacheDaysAhead cacheDaysBehind:cacheDaysBehind environment:environment];
}

+ (void)setupWithStudy:(NSString *)study cacheDaysAhead:(NSInteger)cacheDaysAhead cacheDaysBehind:(NSInteger)cacheDaysBehind
{
    [self setupWithStudy:study cacheDaysAhead:cacheDaysAhead cacheDaysBehind:cacheDaysBehind environment:gDefaultEnvironment];
}

+ (void)setupWithStudy:(NSString *)study cacheDaysAhead:(NSInteger)cacheDaysAhead cacheDaysBehind:(NSInteger)cacheDaysBehind environment:(SBBEnvironment)environment
{
    NSDictionary *bridgeInfoDict = @{
                                     NSStringFromSelector(@selector(studyIdentifier)) : study,
                                     NSStringFromSelector(@selector(environment)) : @(environment),
                                     NSStringFromSelector(@selector(cacheDaysAhead)) : @(cacheDaysAhead),
                                     NSStringFromSelector(@selector(cacheDaysBehind)) : @(cacheDaysBehind)
                                     };
    SBBBridgeInfo *bridgeInfo = [[SBBBridgeInfo alloc] initWithDictionary:bridgeInfoDict];
    
    [self setupWithBridgeInfo:bridgeInfo];
}

+ (void)setupWithAppPrefix:(NSString *)appPrefix environment:(SBBEnvironment)environment
{
    [self setupWithStudy:appPrefix environment:environment];
}

+ (NSUserDefaults *)sharedUserDefaults
{
    static NSUserDefaults *bridgeUserDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SBBBridgeInfo *sharedInfo = [SBBBridgeInfo shared];
        if (sharedInfo.userDefaultsSuiteName.length > 0) {
            bridgeUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:sharedInfo.userDefaultsSuiteName];
        } else if (sharedInfo.appGroupIdentifier.length > 0) {
            bridgeUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:sharedInfo.appGroupIdentifier];
        } else if (sharedInfo.usesStandardUserDefaults) {
            bridgeUserDefaults = [NSUserDefaults standardUserDefaults];
        } else {
            bridgeUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:(NSString *)SBBDefaultUserDefaultsSuiteName];
        }
    });
    
    return bridgeUserDefaults;
}

+ (BOOL)restoreBackgroundSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    BOOL restored = NO;
    if ([identifier hasPrefix:kBackgroundSessionIdentifier]) {
        [SBBComponent(SBBBridgeNetworkManager) restoreBackgroundSession:identifier completionHandler:completionHandler];
        restored = YES;
    }
    
    return restored;
}

+ (void)setAuthDelegate:(id<SBBAuthManagerDelegateProtocol>)delegate
{
    [SBBComponent(SBBAuthManager) setAuthDelegate:delegate];
}

+ (void)setErrorUIDelegate:(id<SBBBridgeErrorUIDelegate>)delegate
{
    gSBBErrorUIDelegate = delegate;
}

+ (BOOL)isRunningInAppExtension
{
    // "An app extension target’s Info.plist file identifies the extension point and may specify some details
    // about your extension. At a minimum, the file includes the NSExtension key and a dictionary of keys and
    // values that the extension point specifies."
    // (see https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/ExtensionCreation.html)
    // We also double-check that the Bundle OS Type Code is not APPL, just to be sure they haven't for some
    // reason added that key to their app's infoDict.
    NSDictionary *infoDict = NSBundle.mainBundle.infoDictionary;
    return (![infoDict[@"CFBundlePackageType"] isEqualToString:@"APPL"] &&
            infoDict[@"NSExtension"] != nil);
}

+ (void)loadAppConfig
{
    [SBBComponent(SBBStudyManager) getAppConfigWithCompletion:^(id appConfig, NSError *error) {
        if (!error) {
            gSBBAppConfig = appConfig;
            
            if (!gSBBUseCache) {
                id appConfigJSON = [SBBComponent(SBBObjectManager) bridgeJSONFromObject:appConfig];
                [[self sharedUserDefaults] setObject:appConfigJSON forKey:(NSString *)SBBAppConfigDefaultsKey];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kSBBAppConfigUpdatedNotification object:nil userInfo:@{ kSBBAppConfigInfoKey : appConfig }];
        }
    }];
}

+ (SBBAppConfig *)appConfig
{
    if (!gSBBAppConfig) {
        if (gSBBUseCache) {
            gSBBAppConfig = (SBBAppConfig *)[SBBComponent(SBBCacheManager) cachedSingletonObjectOfType:@"AppConfig" createIfMissing:NO];
        } else {
            id appConfigJSON = [[self sharedUserDefaults] objectForKey:(NSString *)SBBAppConfigDefaultsKey];
            if (appConfigJSON) {
                gSBBAppConfig = [SBBComponent(SBBObjectManager) objectFromBridgeJSON:appConfigJSON];
            }
        }
    }
    
    return gSBBAppConfig;
}

+ (id<SBBActivityManagerProtocol>)activityManager
{
    return SBBComponent(SBBActivityManager);
}

+ (void)setActivityManager:(id<SBBActivityManagerProtocol>)activityManager
{
    [SBBComponentManager registerComponent:activityManager forClass:SBBActivityManager.class];
}

+ (id<SBBAuthManagerProtocol>)authManager
{
    return SBBComponent(SBBAuthManager);
}

+ (void)setAuthManager:(id<SBBAuthManagerProtocol>)authManager
{
    [SBBComponentManager registerComponent:authManager forClass:SBBAuthManager.class];
}

+ (id<SBBBridgeInfoProtocol>)bridgeInfo
{
    return SBBBridgeInfo.shared;
}

+ (id<SBBConsentManagerProtocol>)consentManager
{
    return SBBComponent(SBBConsentManager);
}

+ (void)setConsentManager:(id<SBBConsentManagerProtocol>)consentManager
{
    [SBBComponentManager registerComponent:consentManager forClass:SBBConsentManager.class];
}

+ (id<SBBNotificationManagerProtocol>)notificationManager
{
    return SBBComponent(SBBNotificationManager);
}

+ (void)setNotificationManager:(id<SBBNotificationManagerProtocol>)notificationManager
{
    [SBBComponentManager registerComponent:notificationManager forClass:SBBNotificationManager.class];
}

+ (id<SBBOAuthManagerProtocol>)OAuthManager
{
    return SBBComponent(SBBOAuthManager);
}

+ (void)setOAuthManager:(id<SBBOAuthManagerProtocol>)OAuthManager
{
    [SBBComponentManager registerComponent:OAuthManager forClass:SBBOAuthManager.class];
}

+ (id<SBBObjectManagerProtocol>)objectManager
{
    return SBBComponent(SBBObjectManager);
}

+ (void)setObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [SBBComponentManager registerComponent:objectManager forClass:SBBObjectManager.class];
}

+ (id<SBBParticipantManagerProtocol>)participantManager
{
    return SBBComponent(SBBParticipantManager);
}

+ (void)setParticipantManager:(id<SBBParticipantManagerProtocol>)participantManager
{
    [SBBComponentManager registerComponent:participantManager forClass:SBBParticipantManager.class];
}

+ (id<SBBSurveyManagerProtocol>)surveyManager
{
    return SBBComponent(SBBSurveyManager);
}

+ (void)setSurveyManager:(id<SBBSurveyManagerProtocol>)surveyManager
{
    [SBBComponentManager registerComponent:surveyManager forClass:SBBSurveyManager.class];
}

+ (id<SBBStudyManagerProtocol>)studyManager
{
    return SBBComponent(SBBStudyManager);
}

+ (void)setStudyManager:(id<SBBStudyManagerProtocol>)studyManager
{
    [SBBComponentManager registerComponent:studyManager forClass:SBBStudyManager.class];
}

+ (id<SBBUploadManagerProtocol>)uploadManager
{
    return SBBComponent(SBBUploadManager);
}

+ (void)setUploadManager:(id<SBBUploadManagerProtocol>)uploadManager
{
    [SBBComponentManager registerComponent:uploadManager forClass:SBBUploadManager.class];
}

@end
