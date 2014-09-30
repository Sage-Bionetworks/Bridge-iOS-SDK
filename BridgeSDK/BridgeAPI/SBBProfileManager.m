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

@interface SBBProfileManager ()

@property (nonatomic, strong) id<SBBNetworkManagerProtocol> networkManager;
@property (nonatomic, strong) id<SBBAuthManagerProtocol> authManager;
@property (nonatomic, strong) id<SBBObjectManagerProtocol> objectManager;

@end

@implementation SBBProfileManager

+ (instancetype)defaultComponent
{
  static SBBProfileManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
    shared.networkManager = SBBComponent(SBBNetworkManager);
    shared.authManager = SBBComponent(SBBAuthManager);
    shared.objectManager = SBBComponent(SBBObjectManager);
  });
  
  return shared;
}

+ (instancetype)profileManagerWithAuthManager:(id<SBBAuthManagerProtocol>)authManager networkManager:(id<SBBNetworkManagerProtocol>)networkManager objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  SBBProfileManager *manager = [[self alloc] init];
  manager.networkManager = networkManager;
  manager.authManager = authManager;
  manager.objectManager = objectManager;
  
  return manager;
}

- (NSURLSessionDataTask *)getUserProfileWithCompletion:(SBBProfileManagerGetCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [_authManager addAuthHeaderToHeaders:headers];
  return [_networkManager get:@"api/v1/profile" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id userProfile = [_objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(userProfile, error);
    }
  }];
}

- (NSURLSessionDataTask *)updateUserProfileWithProfile:(id)profile completion:(SBBProfileManagerUpdateCompletionBlock)completion
{
  id jsonProfile = [_objectManager bridgeJSONFromObject:profile];
  if (!jsonProfile) {
    NSLog(@"Unable to create Bridge JSON UserProfile object from %@", profile);
    return nil;
  }
  
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [_authManager addAuthHeaderToHeaders:headers];
  return [_networkManager post:@"api/v1/profile" headers:headers parameters:jsonProfile completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

@end
