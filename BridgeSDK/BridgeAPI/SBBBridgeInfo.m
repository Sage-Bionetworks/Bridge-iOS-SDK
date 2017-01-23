//
//  SBBBridgeInfo.m
//  BridgeSDK
//
//  Created by Erin Mounts on 1/12/17.
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeInfo.h"

const NSInteger SBBMaxSupportedCacheDays = 30;

@interface SBBBridgeInfo()

@property (nonatomic, strong) NSMutableDictionary *bridgeInfo;

@end

@implementation SBBBridgeInfo

+ (instancetype)shared
{
    static SBBBridgeInfoDict *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SBBBridgeInfo new];
    });
    
    return shared;
}

- (instancetype)init
{
    if (self = [super init]) {
        _bridgeInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setFromBridgeInfo:(id<SBBBridgeInfoProtocol>)info
{
    self.studyIdentifier = info.studyIdentifier;
    self.cacheDaysAhead = info.cacheDaysAhead;
    self.cacheDaysBehind = info.cacheDaysBehind;
    self.environment = info.environment;
    self.certificateName = info.certificateName;
    self.appGroupIdentifier = info.appGroupIdentifier;
}

- (NSString *)studyIdentifier
{
    return _bridgeInfo[NSStringFromSelector(@selector(studyIdentifier))];
}

- (void)setStudyIdentifier:(NSString *)studyIdentifier
{
    _bridgeInfo[NSStringFromSelector(@selector(studyIdentifier))] = studyIdentifier;
}

- (NSUInteger)cacheDaysAhead
{
    return [((NSNumber *)_bridgeInfo[NSStringFromSelector(@selector(cacheDaysAhead))]) unsignedIntegerValue];
}

- (void) setCacheDaysAhead:(NSUInteger)cacheDaysAhead
{
    NSUInteger daysAhead = MIN(SBBMaxSupportedCacheDays, cacheDaysAhead)
    _bridgeInfo[NSStringFromSelector(@selector(cacheDaysAhead))] = @(daysAhead);
}

- (NSUInteger)cacheDaysBehind
{
    return [((NSNumber *)_bridgeInfo[NSStringFromSelector(@selector(cacheDaysBehind))]) unsignedIntegerValue];
}

- (void)setCacheDaysBehind:(NSUInteger)cacheDaysBehind
{
    NSUInteger daysBehind = MIN(SBBMaxSupportedCacheDays, cacheDaysBehind)
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
    _bridgeInfo[NSStringFromSelector(@selector(certificateName))] = certificateName;
}

- (NSString *)appGroupIdentifier
{
    return _bridgeInfo[NSStringFromSelector(@selector(appGroupIdentifier))];
}

- (void)setAppGroupIdentifier:(NSString *)appGroupIdentifier
{
    _bridgeInfo[NSStringFromSelector(@selector(appGroupIdentifier))] = appGroupIdentifier;
}

@end
