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

NSString* const API_CONSENT = @"/api/v1/consent";
NSString* const KEY_NAME = @"name";
NSString* const KEY_BIRTHDATE = @"birthdate";
NSString* const KEY_IMAGE_DATA = @"imageData";
NSString* const KEY_IMAGE_MIME_TYPE = @"imageMimeType";
NSString* const MIME_TYPE_PNG = @"image/png";

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

- (NSURLSessionDataTask *)consentSignature:(NSString *)name birthdate:(NSDate *)date
    signatureImage:(UIImage*)signatureImage completion:(SBBConsentManagerCompletionBlock)completion
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
  NSDictionary *ResearchConsent = [NSMutableDictionary dictionary];
  [ResearchConsent setValue:name forKey:KEY_NAME];
  [ResearchConsent setValue:birthdate forKey:KEY_BIRTHDATE];

  // Add signature image, if it's specified
  if (signatureImage != nil) {
    NSData* imageData = UIImagePNGRepresentation(signatureImage);
    NSString* imageBase64String = [imageData base64EncodedStringWithOptions:kNilOptions];
    [ResearchConsent setValue:imageBase64String forKey:KEY_IMAGE_DATA];
    [ResearchConsent setValue:MIME_TYPE_PNG forKey:KEY_IMAGE_MIME_TYPE];
  }

  return [self.networkManager post:API_CONSENT headers:headers parameters:ResearchConsent
      completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask*)retrieveConsentSignature:(SBBConsentManagerRetrieveCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager get:API_CONSENT headers:headers parameters:nil
      completion:^(NSURLSessionDataTask* task, id responseObject, NSError* error) {
    NSString* name = nil;
    NSString* birthdate = nil;
    UIImage* image = nil;

    // parse consent signature dictionary, if we have one
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary* responseDict = responseObject;
      name = responseDict[KEY_NAME];
      birthdate = responseDict[KEY_BIRTHDATE];

      // create signature image, if we have one
      if (responseDict[KEY_IMAGE_DATA] != nil) {
        NSData* imageData = [[NSData alloc] initWithBase64EncodedString:responseDict[KEY_IMAGE_DATA]
          options:kNilOptions];
        image = [[UIImage alloc] initWithData:imageData];
      }
    }

    // call the completion call back
    if (completion != nil) {
      completion(name, birthdate, image, error);
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
