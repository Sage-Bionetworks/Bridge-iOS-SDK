//
//  SBBConsentManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBConsentManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"

NSString* const kSBBKeyName = @"name";
NSString* const kSBBKeyBirthdate = @"birthdate";
NSString* const kSBBKeyImageData = @"imageData";
NSString* const kSBBKeyImageMimeType = @"imageMimeType";
NSString* const kSBBMimeTypePng = @"image/png";
NSString* const kSBBKeyConsentShareScope = @"scope";

NSString* const kSBBConsentShareScopeStrings[] = {
    @"no_sharing",
    @"sponsors_and_partners",
    @"all_qualified_researchers"
};

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

- (NSString *)apiManagerName
{
    return @"consent";
}

- (NSURLSessionDataTask *)consentSignature:(NSString *)name
                                 birthdate:(NSDate *)date
                            signatureImage:(UIImage*)signatureImage
                              dataSharing:(SBBConsentShareScope)scope
                                completion:(SBBConsentManagerCompletionBlock)completion
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
  NSMutableDictionary *ResearchConsent = [NSMutableDictionary dictionary];
  [ResearchConsent setObject:name forKey:kSBBKeyName];
  [ResearchConsent setObject:birthdate forKey:kSBBKeyBirthdate];

  // Add signature image, if it's specified
  if (signatureImage != nil) {
    NSData* imageData = UIImagePNGRepresentation(signatureImage);
    NSString* imageBase64String = [imageData base64EncodedStringWithOptions:kNilOptions];
    [ResearchConsent setObject:imageBase64String forKey:kSBBKeyImageData];
    [ResearchConsent setObject:kSBBMimeTypePng forKey:kSBBKeyImageMimeType];
  }
    
  // Add sharing scope
  [ResearchConsent setObject:kSBBConsentShareScopeStrings[scope] forKey:kSBBKeyConsentShareScope];

  NSString *urlString = [self urlStringForManagerEndpoint:@"" version:@"v2"];
  return [self.networkManager post:urlString headers:headers parameters:ResearchConsent
      completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask*)retrieveConsentSignatureWithCompletion:(SBBConsentManagerRetrieveCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  NSString *urlString = [self urlStringForManagerEndpoint:@"" version:@"v1"];
  return [self.networkManager get:urlString headers:headers parameters:nil
      completion:^(NSURLSessionDataTask* task, id responseObject, NSError* error) {
    NSString* name = nil;
    NSString* birthdate = nil;
    UIImage* image = nil;

    // parse consent signature dictionary, if we have one
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary* responseDict = responseObject;
      name = responseDict[kSBBKeyName];
      birthdate = responseDict[kSBBKeyBirthdate];

      // create signature image, if we have one
      if (responseDict[kSBBKeyImageData] != nil) {
        NSData* imageData = [[NSData alloc] initWithBase64EncodedString:responseDict[kSBBKeyImageData]
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
  NSString *urlString = [self urlStringForManagerEndpoint:@"/dataSharing/suspend" version:@"v1"];
  return [self.networkManager post:urlString headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)resumeConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  NSString *urlString = [self urlStringForManagerEndpoint:@"/dataSharing/resume" version:@"v1"];
  return [self.networkManager post:urlString headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)dataSharing:(SBBConsentShareScope)scope completion:(SBBConsentManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *parameters = @{kSBBKeyConsentShareScope: kSBBConsentShareScopeStrings[scope]};
    NSString *urlString = [self urlStringForManagerEndpoint:@"/dataSharing" version:@"v2"];
    return [self.networkManager post:urlString headers:headers parameters:parameters completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

@end
