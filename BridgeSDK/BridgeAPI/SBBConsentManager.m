//
//  SBBConsentManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
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
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBConsentManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"

NSString* const kSBBApiConsentV1 = @"/api/v1/consent";
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

  return [self.networkManager post:@"/api/v2/consent" headers:headers parameters:ResearchConsent
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
  return [self.networkManager get:kSBBApiConsentV1 headers:headers parameters:nil
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

- (NSURLSessionDataTask *)dataSharing:(SBBConsentShareScope)scope completion:(SBBConsentManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *parameters = @{kSBBKeyConsentShareScope: kSBBConsentShareScopeStrings[scope]};
    return [self.networkManager post:@"/api/v2/consent/dataSharing" headers:headers parameters:parameters completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

@end
