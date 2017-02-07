//
//  SBBBridgeInfo.m
//  BridgeSDK
//
//	Copyright (c) 2017, Sage Bionetworks
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

#import "SBBBridgeInfo+Internal.h"

const NSInteger SBBMaxSupportedCacheDays = 30;

@interface SBBBridgeInfo()

@property (nonatomic, strong) NSMutableDictionary *bridgeInfo;

@end

@implementation SBBBridgeInfo

+ (instancetype)shared
{
    static SBBBridgeInfo *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SBBBridgeInfo new];
    });
    
    return shared;
}

+ (NSMutableDictionary *)dictionaryFromDefaultPlists
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *basePlist = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"BridgeInfo" ofType:@"plist"]];
    NSMutableDictionary *bridgePlist = [(basePlist ?: @{}) mutableCopy];
    NSDictionary *privatePlist = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"BridgeInfo-private" ofType:@"plist"]];
    if (privatePlist) {
        [bridgePlist addEntriesFromDictionary:privatePlist];
    }
    
    return bridgePlist;
}

- (instancetype)init
{
    if (self = [super init]) {
        _bridgeInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _bridgeInfo = [dictionary mutableCopy];
    }
    return self;
}

- (void)copyFromBridgeInfo:(id<SBBBridgeInfoProtocol>)info
{
    self.studyIdentifier = info.studyIdentifier;
    self.cacheDaysAhead = info.cacheDaysAhead;
    self.cacheDaysBehind = info.cacheDaysBehind;
    self.environment = info.environment;
    self.certificateName = info.certificateName;
    self.appGroupIdentifier = info.appGroupIdentifier;
    self.usesStandardUserDefaults = info.usesStandardUserDefaults;
    self.userDefaultsSuiteName = info.userDefaultsSuiteName;
}

- (NSString *)studyIdentifier
{
    return _bridgeInfo[NSStringFromSelector(@selector(studyIdentifier))];
}

- (void)setStudyIdentifier:(NSString *)studyIdentifier
{
    _bridgeInfo[NSStringFromSelector(@selector(studyIdentifier))] = [studyIdentifier copy];
}

- (NSInteger)cacheDaysAhead
{
    return [((NSNumber *)_bridgeInfo[NSStringFromSelector(@selector(cacheDaysAhead))]) integerValue];
}

- (void)setCacheDaysAhead:(NSInteger)cacheDaysAhead
{
    NSUInteger daysAhead = MIN(SBBMaxSupportedCacheDays, cacheDaysAhead);
    _bridgeInfo[NSStringFromSelector(@selector(cacheDaysAhead))] = @(daysAhead);
}

- (NSInteger)cacheDaysBehind
{
    return [((NSNumber *)_bridgeInfo[NSStringFromSelector(@selector(cacheDaysBehind))]) integerValue];
}

- (void)setCacheDaysBehind:(NSInteger)cacheDaysBehind
{
    NSUInteger daysBehind = MIN(SBBMaxSupportedCacheDays, cacheDaysBehind);
    _bridgeInfo[NSStringFromSelector(@selector(cacheDaysBehind))] = @(daysBehind);
}

- (SBBEnvironment)environment
{
    return [((NSNumber *)_bridgeInfo[NSStringFromSelector(@selector(environment))]) integerValue];
}

- (void)setEnvironment:(SBBEnvironment)environment
{
    _bridgeInfo[NSStringFromSelector(@selector(environment))] = @(environment);
}

- (NSString *)certificateName
{
    return _bridgeInfo[NSStringFromSelector(@selector(certificateName))];
}

- (void)setCertificateName:(NSString *)certificateName
{
    _bridgeInfo[NSStringFromSelector(@selector(certificateName))] = [certificateName copy];
}

- (NSString *)appGroupIdentifier
{
    return _bridgeInfo[NSStringFromSelector(@selector(appGroupIdentifier))];
}

- (void)setAppGroupIdentifier:(NSString *)appGroupIdentifier
{
    _bridgeInfo[NSStringFromSelector(@selector(appGroupIdentifier))] = [appGroupIdentifier copy];
}

- (BOOL)usesStandardUserDefaults
{
    return [((NSNumber *)_bridgeInfo[NSStringFromSelector(@selector(usesStandardUserDefaults))]) boolValue];
}

- (void)setUsesStandardUserDefaults:(BOOL)usesStandardUserDefaults
{
    _bridgeInfo[NSStringFromSelector(@selector(usesStandardUserDefaults))] = @(usesStandardUserDefaults);
}

- (NSString *)userDefaultsSuiteName
{
    return _bridgeInfo[NSStringFromSelector(@selector(userDefaultsSuiteName))];
}

- (void)setUserDefaultsSuiteName:(NSString *)userDefaultsSuiteName
{
    _bridgeInfo[NSStringFromSelector(@selector(userDefaultsSuiteName))] = [userDefaultsSuiteName copy];
}

@end
