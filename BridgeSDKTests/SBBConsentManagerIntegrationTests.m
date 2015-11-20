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

@end

@implementation SBBConsentManagerIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    [self createTestUserConsented:NO roles:@[] completionHandler:^(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error) {
        if (!error) {
            unconsentedEmail = emailAddress;
            [aMan signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                if (error && error.code != SBBErrorCodeServerPreconditionNotMet) {
                    NSLog(@"Error signing in unconsented user %@:\n%@\nResponse: %@", unconsentedEmail, error, responseObject);
                    [expectSigned fulfill];
                } else {
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
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout registering consent signature: %@", error);
        }
    }];
    
    // clean up the test user we just created (no need to wait for it to finish, nothing else depends on it)
    [self deleteUser:unconsentedEmail completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted unconsented test account %@", unconsentedEmail);
        } else {
            NSLog(@"Failed to delete unconsented test account %@\n\nError:%@\nResponse:%@", unconsentedEmail, error, responseObject);
        }
    }];
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
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
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
    [self createTestUserConsented:YES roles:@[] completionHandler:^(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error) {
        if (!error) {
            consentedEmail = emailAddress;
            [aMan signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                if (error && error.code != SBBErrorCodeServerPreconditionNotMet) {
                    NSLog(@"Error signing in consented user %@:\n%@\nResponse: %@", consentedEmail, error, responseObject);
                    [expectWithdrew fulfill];
                } else {
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
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout withdrawing consent: %@", error);
        }
    }];
    
    // clean up the test user we just created (no need to wait for it to finish, nothing else depends on it)
    [self deleteUser:consentedEmail completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted consented test account %@", consentedEmail);
        } else {
            NSLog(@"Failed to delete consented test account %@\n\nError:%@\nResponse:%@", consentedEmail, error, responseObject);
        }
    }];
}

@end
