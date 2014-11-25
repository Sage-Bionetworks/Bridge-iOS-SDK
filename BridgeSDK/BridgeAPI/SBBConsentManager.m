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
#import "SBBStringUtils.h"

@implementation SBBConsentManager

+ (instancetype)defaultComponent
{
  static SBBConsentManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (NSURLSessionDataTask *)consentSignature:(NSString *)name birthdate:(NSDate *)date imageData:(NSString*)imageData
    imageMimeType:(NSString*)imageMimeType completion:(SBBConsentManagerCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
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

  // Add signature image, if it's specified
  if (![SBBStringUtils isNullOrEmpty:imageData])
  {
    [ResearchConsent setValue:imageData forKey:@"imageData"];
  }
  if (![SBBStringUtils isNullOrEmpty:imageMimeType])
  {
    [ResearchConsent setValue:imageMimeType forKey:@"imageMimeType"];
  }

  return [self.networkManager post:@"/api/v1/consent" headers:headers parameters:ResearchConsent completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)suspendConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager post:@"/api/v1/consent/dataSharing/suspend" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)resumeConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager post:@"/api/v1/consent/dataSharing/resume" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

@end
