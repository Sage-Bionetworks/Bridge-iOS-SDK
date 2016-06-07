//
//  SBBConsentManagerIntegrationTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/18/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBConsentManagerInternal.h"
#import "SBBTestAuthManagerDelegate.h"

@interface SBBConsentManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@property (nonatomic, strong) NSString *testSubpopRequiredGuid;
@property (nonatomic, strong) NSString *testSubpopOptionalGuid;

@end

@implementation SBBConsentManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCTestExpectation *expectAddedRequiredSubpop = [self expectationWithDescription:@"required subpop added"];
    
    [self createSubpopulation:@"bridge-ios-sdk-required-subpop-test" forGroups:@[@"sdk-int-1"] notGroups:nil required:YES withCompletion:^(NSString *subpopGuid, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating required test subpop:\n%@\nResponse: %@", error, responseObject);
        } else {
            NSLog(@"Created required test subpop:\n%@", responseObject);
            self.testSubpopRequiredGuid = subpopGuid;
        }
        [expectAddedRequiredSubpop fulfill];
    }];
    
    XCTestExpectation *expectAddedOptionalSubpop = [self expectationWithDescription:@"optional subpop added"];
    
    [self createSubpopulation:@"bridge-ios-sdk-optional-subpop-test" forGroups:@[@"sdk-int-1"] notGroups:@[@"sdk-int-2"] required:NO withCompletion:^(NSString *subpopGuid, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating optional test subpop:\n%@\nResponse: %@", error, responseObject);
        } else {
            NSLog(@"Created optional test subpop:\n%@", responseObject);
            self.testSubpopOptionalGuid = subpopGuid;
        }
        [expectAddedOptionalSubpop fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout creating test subpopulations: %@", error);
        }
    }];    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    if (self.testSubpopRequiredGuid) {
        XCTestExpectation *expectDeletedRequiredSubpop = [self expectationWithDescription:@"required subpop deleted"];
        
        [self deleteSubpopulation:self.testSubpopRequiredGuid completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error deleting required test subpop:\n%@\nResponse: %@", error, responseObject);
            } else {
                NSLog(@"Deleted required test subpop:\n%@", responseObject);
                self.testSubpopRequiredGuid = nil;
            }
            [expectDeletedRequiredSubpop fulfill];
        }];
    }
    
    if (self.testSubpopOptionalGuid) {
        XCTestExpectation *expectDeletedOptionalSubpop = [self expectationWithDescription:@"optional subpop deleted"];
        
        [self deleteSubpopulation:self.testSubpopOptionalGuid completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error deleting optional test subpop:\n%@\nResponse: %@", error, responseObject);
            } else {
                NSLog(@"Deleted optional test subpop:\n%@", responseObject);
                self.testSubpopOptionalGuid = nil;
            }
            [expectDeletedOptionalSubpop fulfill];
        }];
    }
    
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout deleting test subpopulations: %@", error);
        }
    }];
   
    [super tearDown];
}

- (void)testConsentSignature {
    // we need our own auth manager instance (with its own delegate) so we don't eff with the global test user
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    aMan.authDelegate = delegate;
    SBBConsentManager *cMan = [SBBConsentManager managerWithAuthManager:aMan networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
    UIImage *signatureImage = [UIImage imageNamed:@"sample-signature" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    XCTestExpectation *expectSigned = [self expectationWithDescription:@"consent signature recorded"];
    
    __block NSString *unconsentedEmail = nil;
    __block NSString *unconsentedId = nil;
    [self createTestUserConsented:NO roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating unconsented user %@:\n%@\nResponse: %@", unconsentedEmail, error, responseObject);
            [expectSigned fulfill];
        } else {
            unconsentedEmail = emailAddress;
            [aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error && error.code != SBBErrorCodeServerPreconditionNotMet) {
                    NSLog(@"Error signing in unconsented user %@:\n%@\nResponse: %@", unconsentedEmail, error, responseObject);
                    [expectSigned fulfill];
                } else {
                    unconsentedId = responseObject[kUserSessionInfoIdKey];
                    [cMan consentSignature:@"Eggplant McTester" birthdate:[NSDate dateWithTimeIntervalSinceNow:-(30 * 365.25 * 86400)] signatureImage:signatureImage dataSharing:SBBUserDataSharingScopeStudy completion:^(id responseObject, NSError *error) {
                        if (error) {
                            NSLog(@"Error recording consent signature:\n%@\nResponse: %@", error, responseObject);
                        }
                        XCTAssert(!error, @"Successfully recorded consent signature");
                        [expectSigned fulfill];
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout registering consent signature: %@", error);
        }
    }];
    
    // clean up the test user we just created (no need to wait for it to finish, nothing else depends on it)
    if (unconsentedId) {
        [self deleteUser:unconsentedId completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (!error) {
                NSLog(@"Deleted unconsented test account %@", unconsentedEmail);
            } else {
                NSLog(@"Failed to delete unconsented test account %@\n\nError:%@\nResponse:%@", unconsentedEmail, error, responseObject);
            }
        }];
    } else {
        NSLog(@"Failed to retrieve test account id for %@, account not deleted", unconsentedEmail);
    }
}

- (void)testConsentAndGetSignatureForSubpop {
    // we need our own auth manager instance (with its own delegate) so we don't eff with the global test user
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    aMan.authDelegate = delegate;
    SBBUserManager *uMan = [SBBUserManager managerWithAuthManager:aMan networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
    SBBConsentManager *cMan = [SBBConsentManager managerWithAuthManager:aMan networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
    UIImage *signatureImage = [UIImage imageNamed:@"sample-signature" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    XCTestExpectation *expectSigned = [self expectationWithDescription:@"consent signature recorded"];
    
    __block NSString *unconsentedEmail = nil;
    __block NSString *unconsentedId = nil;
    __block BOOL consentSigned = NO;
    
    NSString *signname = @"Eggplant McTester";
    NSDate *birthdate = [NSDate dateWithTimeIntervalSinceNow:-(30 * 365.25 * 86400)];
    
    [self createTestUserConsented:NO roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating unconsented user %@:\n%@\nResponse: %@", unconsentedEmail, error, responseObject);
            [expectSigned fulfill];
        } else {
            unconsentedEmail = emailAddress;
            NSArray *dataGroups = @[@"sdk-int-1", @"sdk-int-2"];
            [aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error && error.code != SBBErrorCodeServerPreconditionNotMet) {
                    NSLog(@"Error signing in unconsented user %@:\n%@\nResponse: %@", unconsentedEmail, error, responseObject);
                    [expectSigned fulfill];
                } else {
                    unconsentedId = responseObject[kUserSessionInfoIdKey];
                    // sign default (required) consent first
                    [cMan consentSignature:signname forSubpopulationGuid:gSBBAppStudy birthdate:birthdate signatureImage:signatureImage dataSharing:SBBUserDataSharingScopeStudy completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"Error recording default consent signature:\n%@\nResponse: %@", error, responseObject);
                            [expectSigned fulfill];
                        } else {
                            // add to subpopulation that has its own required consent
                            [uMan addToDataGroups:dataGroups completion:^(id responseObject, NSError *error) {
                                if (error && error.code != SBBErrorCodeServerPreconditionNotMet) {
                                    NSLog(@"Error adding user %@ to groups %@:\n%@\nResponse: %@", unconsentedEmail, dataGroups, error, responseObject);
                                    [expectSigned fulfill];
                                } else {
                                    // sign subpopulation consent
                                    [cMan consentSignature:signname forSubpopulationGuid:self.testSubpopRequiredGuid birthdate:birthdate signatureImage:signatureImage dataSharing:SBBUserDataSharingScopeStudy completion:^(id responseObject, NSError *error) {
                                        if (error) {
                                            NSLog(@"Error recording subpop consent signature:\n%@\nResponse: %@", error, responseObject);
                                        } else {
                                            consentSigned = YES;
                                        }
                                        XCTAssert(!error, @"Successfully recorded subpop consent signature");
                                        [expectSigned fulfill];
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout registering subpop consent signature: %@", error);
        }
    }];
    
    if (consentSigned) {
        // now try to get it back
        XCTestExpectation *expectReceived = [self expectationWithDescription:@"consent signature received"];
        
        [cMan getConsentSignatureForSubpopulation:self.testSubpopRequiredGuid completion:^(id consentSignature, NSError *error) {
            if (error) {
                NSLog(@"Error getting subpop consent signature:\n%@", error);
            }
            XCTAssert(!error, @"Successfully retrieved consent signature");
            XCTAssert([consentSignature isKindOfClass:[SBBConsentSignature class]], @"Converted incoming JSON to SBBConsentSignature");
            if ([consentSignature isKindOfClass:[SBBConsentSignature class]]) {
                SBBConsentSignature *cSig = consentSignature;
                XCTAssertEqualObjects(cSig.name, signname, @"Name as signed same as name retrieved");
                XCTAssertEqualObjects(cSig.birthdate, [birthdate ISO8601DateOnlyString], @"Birthdate as signed is same as birthdate retrieved");
                XCTAssertEqual([cSig signatureImage].size.height, signatureImage.size.height, @"Image as signed is same height as image retrieved");
                XCTAssertEqual([cSig signatureImage].size.width, signatureImage.size.width, @"Image as signed is same width as image retrieved");
            }
            [expectReceived fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Timeout getting subpop consent signature: %@", error);
            }
        }];
    }
    
    // clean up the test user we just created (no need to wait for it to finish, nothing else depends on it)
    if (unconsentedId) {
        [self deleteUser:unconsentedId completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (!error) {
                NSLog(@"Deleted unconsented test account %@", unconsentedEmail);
            } else {
                NSLog(@"Failed to delete unconsented test account %@\n\nError:%@\nResponse:%@", unconsentedEmail, error, responseObject);
            }
        }];
    } else {
        NSLog(@"Failed to retrieve test account id for %@, account not deleted", unconsentedEmail);
    }
}

- (void)testRetrieveConsentSignature
{
    XCTestExpectation *expectRetrieved = [self expectationWithDescription:@"retrieved consent signature"];
    // use default managers and the test account created on the default auth manager
    [SBBComponent(SBBConsentManager) retrieveConsentSignatureWithCompletion:^(NSString *name, NSString *birthdate, UIImage *signatureImage, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving consent signature:\n%@", error);
        }
        XCTAssert(!error && name.length && birthdate.length, @"Retrieved consent signature");
        [expectRetrieved fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout retrieving consent signature: %@", error);
        }
    }];
}

- (void)testWithdrawConsent {
    // we need our own auth manager instance (with its own delegate) so we don't eff with the global test user
    SBBAuthManager *aMan = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
    SBBTestAuthManagerDelegate *delegate = [SBBTestAuthManagerDelegate new];
    aMan.authDelegate = delegate;
    SBBConsentManager *cMan = [SBBConsentManager managerWithAuthManager:aMan networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
    XCTestExpectation *expectWithdrew = [self expectationWithDescription:@"consent withdrawn"];
    
    __block NSString *consentedEmail = nil;
    __block NSString *consentedId = nil;
    [self createTestUserConsented:YES roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (!error) {
            consentedEmail = emailAddress;
            [aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error && error.code != SBBErrorCodeServerPreconditionNotMet) {
                    NSLog(@"Error signing in consented user %@:\n%@\nResponse: %@", consentedEmail, error, responseObject);
                    [expectWithdrew fulfill];
                } else {
                    consentedId = responseObject[kUserSessionInfoIdKey];
                    [cMan withdrawConsentWithReason:nil completion:^(id responseObject, NSError *error) {
                        if (error) {
                            NSLog(@"Error withdrawing consent:\n%@\nResponse: %@", error, responseObject);
                        }
                        XCTAssert(!error, @"Successfully withdrew consent");
                        [expectWithdrew fulfill];
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout withdrawing consent: %@", error);
        }
    }];
    
    // clean up the test user we just created (no need to wait for it to finish, nothing else depends on it)
    if (consentedId) {
        [self deleteUser:consentedId completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            if (!error) {
                NSLog(@"Deleted consented test account %@", consentedEmail);
            } else {
                NSLog(@"Failed to delete consented test account %@\n\nError:%@\nResponse:%@", consentedEmail, error, responseObject);
            }
        }];
    } else {
        NSLog(@"Failed to retrieve test account id for %@, account not deleted", consentedEmail);
    }
}

@end
