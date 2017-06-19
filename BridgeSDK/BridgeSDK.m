//
//  BridgeSDK.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/16/14.
//
//	Copyright (c) 2014, Sage Bionetworks
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

id<SBBBridgeErrorUIDelegate> gSBBErrorUIDelegate = nil;

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

    // now kickstart any potentially "orphaned" file uploads from a background thread (but first create the upload
    // manager instance so its notification handlers get set up in time)
    id<SBBUploadManagerProtocol> uMan = SBBComponent(SBBUploadManager);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray<NSString *> *uploads = SBBEncryptor.encryptedFilesAwaitingUploadResponse;
        for (NSString *file in uploads) {
            NSURL *fileUrl = [NSURL fileURLWithPath:file];
            [uMan uploadFileToBridge:fileUrl completion:^(NSError *error) {
                if (!error) {
                    [SBBEncryptor cleanUpEncryptedFile:fileUrl];
                }
            }];
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

+ (BOOL)restoreBackgroundSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
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

@end
