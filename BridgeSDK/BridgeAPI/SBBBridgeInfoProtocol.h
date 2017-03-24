//
//  SBBBridgeInfoProtocol.h
//  BridgeSDK
//
// Copyright (c) 2017, Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "SBBNetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SBBBridgeInfoProtocol <NSObject>

/**
 Study identifier used to setup the study with Bridge
 */
@property (nonatomic, readonly, copy) NSString *studyIdentifier;

/**
 Name of .pem certificate file to use for uploading to Bridge (without the .pem extension)
 */
@property (nonatomic, readonly, copy) NSString * _Nullable certificateName;

/**
 If using BridgeSDK's built-in caching, number of days ahead to cache.
 Set both this and cacheDaysBehind to 0 to disable caching in BridgeSDK.
 */
@property (nonatomic, readonly) NSInteger cacheDaysAhead;

/**
 If using BridgeSDK's built-in caching, number of days behind to cache.
 Set both this and cacheDaysAhead to 0 to disable caching in BridgeSDK.
 */
@property (nonatomic, readonly) NSInteger cacheDaysBehind;

/**
 Server environment to use.
 Generally you should not set this to anything other than SBBEnvironmentProd unless you are running your own
 Bridge server, and then only to test changes to the server which you have not yet deployed to production.
 */
@property (nonatomic, readonly) SBBEnvironment environment;

/**
 Tells the Bridge libraries to use the standard user defaults suite.
 
 @note This flag is intended only for backward compatibility when upgrading apps built with older versions of Bridge libraries that used the standard user defaults suite. It will be ignored in any case if either userDefaultsSuiteName or appGroupIdentifier are set.
 */
@property (nonatomic, readonly) BOOL usesStandardUserDefaults;

/**
 The name of the user defaults suite for the Bridge libraries to use internally. Only needs to be set if you want
 the Bridge libraries to use something other than their default internal suite name (org.sagebase.Bridge)
 or, in conjunction with appGroupIdentifier, to have them use a different suite other than the
 shared suite.
 */
@property (nonatomic, readonly, copy) NSString * _Nullable userDefaultsSuiteName;

/**
 This property, if set, is used for the suite name of NSUserDefaults (if userDefaultsSuiteName
 is not explicitly set), and for the name of the shared container, which is used both to configure the
 background session and as the place to store temporary copies of files being uploaded to Bridge
 (if provided).
 */
@property (nonatomic, readonly, copy) NSString * _Nullable appGroupIdentifier;

@end

NS_ASSUME_NONNULL_END
