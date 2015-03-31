//
//  SBBProfileManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBProfileManager.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"

@implementation SBBProfileManager

+ (instancetype)defaultComponent
{
  static SBBProfileManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (NSURLSessionDataTask *)getUserProfileWithCompletion:(SBBProfileManagerGetCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager get:@"/api/v1/profile" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id userProfile = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(userProfile, error);
    }
  }];
}

- (NSURLSessionDataTask *)updateUserProfileWithProfile:(id)profile completion:(SBBProfileManagerUpdateCompletionBlock)completion
{
  id jsonProfile = [self.objectManager bridgeJSONFromObject:profile];
  if (!jsonProfile) {
    NSLog(@"Unable to create Bridge JSON UserProfile object from %@", profile);
    return nil;
  }
  
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager post:@"/api/v1/profile" headers:headers parameters:jsonProfile completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)addExternalIdentifier:(NSString *)externalID completion:(SBBProfileManagerUpdateCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDictionary *params = @{
                                @"identifier": externalID,
                                @"type": @"ExternalIdentifier"
                             };
    return [self.networkManager post:@"/api/v1/profile/external-id" headers:headers parameters:params completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

@end
