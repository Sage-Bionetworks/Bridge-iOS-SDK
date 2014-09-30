//
//  SBBConsentManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBConsentManager.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"

@interface SBBConsentManager ()

@property (nonatomic, strong) id<SBBNetworkManagerProtocol> networkManager;
@property (nonatomic, strong) id<SBBAuthManagerProtocol> authManager;

@end

@implementation SBBConsentManager

+ (instancetype)defaultComponent
{
  static SBBConsentManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
    shared.networkManager = SBBComponent(SBBNetworkManager);
    shared.authManager = SBBComponent(SBBAuthManager);
  });
  
  return shared;
}

+ (instancetype)consentManagerWithAuthManager:(SBBAuthManager *)authManager networkManager:(id<SBBNetworkManagerProtocol>)networkManager
{
  SBBConsentManager *manager = [[self alloc] init];
  manager.networkManager = networkManager;
  manager.authManager = authManager;
  
  return manager;
}

- (NSURLSessionDataTask *)consentSignature:(NSString *)name birthdate:(NSDate *)date completion:(SBBConsentManagerCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [_authManager addAuthHeaderToHeaders:headers];
  static NSDateFormatter *birthdateFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    birthdateFormatter = [[NSDateFormatter alloc] init];
    [birthdateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [birthdateFormatter setLocale:enUSPOSIXLocale];
  });
  
  NSString *birthdate = [birthdateFormatter stringFromDate:date];
  NSDictionary *ResearchConsent = @{@"name": name, @"birthdate": birthdate};
  return [_networkManager post:@"api/v1/consent" headers:headers parameters:ResearchConsent completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)suspendConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [_authManager addAuthHeaderToHeaders:headers];
  return [_networkManager post:@"api/v1/consent/dataSharing/suspend" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)resumeConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [_authManager addAuthHeaderToHeaders:headers];
  return [_networkManager post:@"api/v1/consent/dataSharing/resume" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

@end
