//
//  SBBBridgeAPIIntegrationTestCase.h
//  BridgeSDK
//
//  Created by Erin Mounts on 7/15/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import <XCTest/XCTest.h>
@import BridgeSDK;

#define TEST_STUDY @"api"

typedef void (^SBBBridgeAPIIntegrationTestCaseCreateCompletionBlock)(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error);
typedef void (^SBBBridgeAPIIntegrationTestCaseCreateSubpopCompletionBlock)(NSString *subpopGuid, id responseObject, NSError *error);

@interface SBBBridgeAPIIntegrationTestCase : XCTestCase

@property (nonatomic, strong) NSString *testUserEmail;
@property (nonatomic, strong) NSString *testUserUsername;
@property (nonatomic, strong) NSString *testUserPassword;

@property (nonatomic, strong) NSString *devUserEmail;
@property (nonatomic, strong) NSString *devUserUsername;
@property (nonatomic, strong) NSString *devUserPassword;

@property (nonatomic, strong) id testSignInResponseObject;
@property (nonatomic, strong) id devSignInResponseObject;

- (void)createTestUserConsented:(BOOL)consented roles:(NSArray *)roles completionHandler:(SBBBridgeAPIIntegrationTestCaseCreateCompletionBlock)completion;
- (void)deleteUser:(NSString *)emailAddress completionHandler:(SBBNetworkManagerCompletionBlock)completion;
- (void)createSubpopulation:(NSString *)subpopName forGroups:(NSArray *)inGroups notGroups:(NSArray *)outGroups required:(BOOL)required withCompletion:(SBBBridgeAPIIntegrationTestCaseCreateSubpopCompletionBlock)completion;
- (void)deleteSubpopulation:(NSString *)subpopGuid completionHandler:(SBBNetworkManagerCompletionBlock)completion;

@end