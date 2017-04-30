//
//  BridgeSDK.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/8/14.
//
//	Copyright (c) 2014-2015, Sage Bionetworks
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

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
  
//! Project version number for BridgeSDK.
extern double BridgeSDKVersionNumber;

//! Project version string for BridgeSDK.
extern const unsigned char BridgeSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BridgeSDK/PublicHeader.h>
  
#import <BridgeSDK/SBBActivityManager.h>
#import <BridgeSDK/SBBAuthManager.h>
#import <BridgeSDK/SBBBridgeNetworkManager.h>
#import <BridgeSDK/SBBBridgeAppDelegate.h>
#import <BridgeSDK/SBBBridgeErrorUIDelegate.h>
#import <BridgeSDK/SBBBridgeInfoProtocol.h>
#import <BridgeSDK/SBBBridgeInfo.h>
#import <BridgeSDK/SBBJSONValue.h>
#import <BridgeSDK/SBBComponent.h>
#import <BridgeSDK/SBBComponentManager.h>
#import <BridgeSDK/SBBConsentManager.h>
#import <BridgeSDK/SBBUserManager.h>
#import <BridgeSDK/SBBObjectManager.h>
#import <BridgeSDK/SBBNetworkManager.h>
#import <BridgeSDK/SBBScheduleManager.h>
#import <BridgeSDK/SBBSurveyManager.h>
#import <BridgeSDK/SBBUploadManager.h>
#import <BridgeSDK/SBBErrors.h>
#import <BridgeSDK/SBBDataArchive.h>
#import <BridgeSDK/SBBBridgeObjects.h>
#import <BridgeSDK/NSData+SBBAdditions.h>
#import <BridgeSDK/NSDate+SBBAdditions.h>
#import <BridgeSDK/NSBundle+SBBAdditions.h>
#import <BridgeSDK/UIDevice+Hardware.h>

    
// This sets the default environment at app (not SDK) compile time to Staging for debug builds and Production for non-debug.
#if DEBUG
#define kDefaultEnvironment SBBEnvironmentStaging
#else
#define kDefaultEnvironment SBBEnvironmentProd
#endif
static SBBEnvironment gDefaultEnvironment = kDefaultEnvironment;

// The default number of days to cache
extern const NSInteger SBBDefaultCacheDaysAhead;
extern const NSInteger SBBDefaultCacheDaysBehind;

// The maximum number of days that are supported for caching.
extern const NSInteger SBBMaxSupportedCacheDays;
    
// The default NSUserDefaults suite to use if not otherwise specified at setup time
extern const NSString * _Nullable SBBDefaultUserDefaultsSuiteName;
  
@interface BridgeSDK : NSObject

/*!
 * Set up the Bridge SDK based on settings passed in a configuration object.
 *
 * This is and setupWithBridgeInfo: are now the preferred methods for initializing the Bridge SDK.
 * All other methods are deprecated.
 *
 * This method searches the main bundle for a plist resource with the filename `BridgeInfo.plist` and merges
 * its contents with a second (optional) plist called `BridgeInfo-private.plist`. The resulting dictionary of
 * settings is used to set up the SBBBridgeInfo shared object.
 *
 * See SBBBridgeInfoProtocol for a description of the keys and values for these plists. If not specified,
 * `environment` defaults to SBBEnvironmentProd, and `cacheDaysAhead` and `cacheDaysBehind` default to 0
 * (BridgeSDK caching disabled). You only need to specify `appGroupIdentifier` if you've set up an app group
 * under your target's Capabilities in Xcode, and you want BridgeSDK to use that shared space.
 */
+ (void)setup;

/*!
 * Set up the Bridge SDK based on settings passed in a configuration object.
 *
 * This is and setup are now the preferred methods for initializing the Bridge SDK.
 * All other methods are deprecated.
 *
 *  @param info An object of a class that conforms to SBBBridgeInfoProtocol containing the desired configuration settings.
 *  @see SBBBridgeInfoProtocol
 *  @see SBBBridgeInfo
 */
+ (void)setupWithBridgeInfo:(nonnull id<SBBBridgeInfoProtocol>)info;

/*!
 * Get the UserDefaults suite being used by BridgeSDK. This will either be the suite with the appGroupIdentifier name,
 * or if no appGroupIdentifier was specified in the setup info object, then this will be standardUserDefaults.
 */
+ (nonnull NSUserDefaults *)sharedUserDefaults;

/*
 * Call this in your app delegate's application:handleEventsForBackgroundURLSession:completionHandler: method to
 * ensure that uploads to Bridge can be completed when a network connection becomes available.
 *
 * If this method returns NO, the session didn't belong to BridgeSDK, so your app will be responsible for
 * restoring it (or ignoring it, as the case may be).
 *
 *  @param identifier The background session identifier passed to your app delegate.
 *  @param completionHandler The completion handler passed to your app delegate.
 *  @return YES if the session belonged to BridgeSDK and was restored by this method, NO otherwise.
 */
+ (BOOL)restoreBackgroundSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler;

/*!
 * This is a convenience method for setting the auth delegate on the default or currently-registered auth manager.
 *
 *  @param delegate An object that conforms to SBBAuthManagerDelegateProtocol to serve as the auth delegate for the default or currently-registered auth manager.
 */
+ (void)setAuthDelegate:(nullable id<SBBAuthManagerDelegateProtocol>)delegate;

/*!
 * Set a delegate to handle presenting appropriate UI to the study participant in case of "not consented" (412) and "app version not supported" (409) error responses from Bridge.
 *
 *  @param delegate An object that conforms to the SBBBridgeErrorUIDelegate protocol to handle UI for Bridge "not consented" (412) and "app version not supported" (409) error responses.
 */
+ (void)setErrorUIDelegate:(nullable id<SBBBridgeErrorUIDelegate>)delegate;

/*!
 * Set up the Bridge SDK for the given study and pointing at the production environment.
 * Usually you would call this at the beginning of your AppDelegate's application:didFinishLaunchingWithOptions: method.
 *
 * This will register a default SBBNetworkManager instance configured correctly for the specified study and appropriate
 * server environment. If you register a custom (or custom-configured) NetworkManager yourself, don't call this method.
 *
 * Caching is turned off if `cacheDaysAhead = 0` AND `cacheDaysBehind = 0`
 *
 *  @param study   A string identifier for your app's Bridge study, assigned to you by Sage Bionetworks.
 *  @param cacheDaysAhead Number of days ahead to cache.
 *  @param cacheDaysBehind Number of days behind to cache.
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithStudy:(nonnull NSString *)study cacheDaysAhead:(NSInteger)cacheDaysAhead cacheDaysBehind:(NSInteger)cacheDaysBehind __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

/*!
 * Convenience method for setting up the study with default caching for days ahead and days behind.
 *
 * If `useCache` is set to `YES` then this method sets up caching using `SBBDefaultCacheDaysAhead` and
 * `SBBDefaultCacheDaysBehind`
 *
 *  @param study   A string identifier for your app's Bridge study, assigned to you by Sage Bionetworks.
 *  @param useCache A flag indicating whether to use the SDK's built-in persistent caching. Pass NO if you want to handle this yourself.
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithStudy:(nonnull NSString *)study useCache:(BOOL)useCache __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

/*!
 * Convenience method for setting up the study with caching turned off (default).
 *
 *  @param study   A string identifier for your app's Bridge study, assigned to you by Sage Bionetworks.
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithStudy:(nonnull NSString *)study __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

/*!
 * Set up the Bridge SDK for the given study and server environment. Usually you would only call this version
 * of the method from test suites, or if you have a non-DEBUG build configuration that you don't want running against
 * the production server environment. Otherwise call the version of the setupWithStudy: method that doesn't
 * take an environment parameter, and let the SDK use the default environment.
 *
 * This will register a default SBBNetworkManager instance conigured correctly for the specified environment and study.
 * If you register a custom (or custom-configured) NetworkManager yourself, don't call this method.
 *
 * Caching is turned off if `cacheDaysAhead = 0` AND `cacheDaysBehind = 0`
 *
 *  @param study   A string identifier for your app's Bridge study, assigned to you by Sage Bionetworks.
 *  @param cacheDaysAhead Number of days ahead to cache.
 *  @param cacheDaysBehind Number of days behind to cache.
 *  @param environment Which server environment to run against.
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithStudy:(nonnull NSString *)study cacheDaysAhead:(NSInteger)cacheDaysAhead cacheDaysBehind:(NSInteger)cacheDaysBehind environment:(SBBEnvironment)environment __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

/*!
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithStudy:(nonnull NSString *)study environment:(SBBEnvironment)environment __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

/*!
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithStudy:(nonnull NSString *)study useCache:(BOOL)useCache environment:(SBBEnvironment)environment __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

/*!
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithAppPrefix:(nonnull NSString *)appPrefix __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

/*!
 *  @deprecated For backward compatibility only. Use setup: or setupWithBridgeInfo: instead.
 */
+ (void)setupWithAppPrefix:(nonnull NSString *)appPrefix environment:(SBBEnvironment)environment __attribute__((deprecated("use setup: or setupWithBridgeInfo: instead")));

@end

#ifdef __cplusplus
}
#endif

