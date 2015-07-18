//
//  SBBBridgeAPIIntegrationTestCase.h
//  BridgeSDK
//
//  Created by Erin Mounts on 7/15/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import <XCTest/XCTest.h>
@import BridgeSDK;

typedef void (^SBBBridgeAPIIntegrationTestCaseCreateCompletionBlock)(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error);

@interface SBBBridgeAPIIntegrationTestCase : XCTestCase

@property (nonatomic, strong) NSString *testUserEmail;
@property (nonatomic, strong) NSString *testUserUsername;
@property (nonatomic, strong) NSString *testUserPassword;

- (void)createTestUserConsented:(BOOL)consented completionHandler:(SBBBridgeAPIIntegrationTestCaseCreateCompletionBlock)completion;
- (void)deleteUser:(NSString *)emailAddress completionHandler:(SBBNetworkManagerCompletionBlock)completion;

@end