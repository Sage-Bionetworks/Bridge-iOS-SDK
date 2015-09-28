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

@interface SBBBridgeAPIIntegrationTestCase : XCTestCase

@property (nonatomic, strong) NSString *testUserEmail;
@property (nonatomic, strong) NSString *testUserUsername;
@property (nonatomic, strong) NSString *testUserPassword;

@property (nonatomic, strong) id testSignInResponseObject;

- (void)createTestUserConsented:(BOOL)consented roles:(NSArray *)roles completionHandler:(SBBBridgeAPIIntegrationTestCaseCreateCompletionBlock)completion;
- (void)deleteUser:(NSString *)emailAddress completionHandler:(SBBNetworkManagerCompletionBlock)completion;

@end