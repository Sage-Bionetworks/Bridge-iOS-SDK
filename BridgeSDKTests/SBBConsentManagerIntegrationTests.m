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
#import "SBBParticipantManagerInternal.h"
#import "SBBCacheManager.h"
#import "ModelObjectInternal.h"

@interface SBBConsentManagerIntegrationTests : SBBBridgeAPIIntegrationTestCase

@property (nonatomic, strong) NSString *testSubpopRequiredGuid;
@property (nonatomic, strong) NSString *testSubpopOptionalGuid;

@end

@implementation SBBConsentManagerIntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.testSubpopOptionalGuid = @"0c132b61-f5fd-4e75-9813-5b7dce04cdd7";
    self.testSubpopRequiredGuid = @"cfbbbaed-bf7a-4b20-aad8-f649a7e6e7fc";
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
                    [cMan consentSignature:@"Eggplant McTester" birthdate:[NSDate dateWithTimeIntervalSinceNow:-(30 * 365.25 * 86400)] signatureImage:signatureImage dataSharing:SBBParticipantDataSharingScopeStudy completion:^(id responseObject, NSError *error) {
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
    SBBParticipantManager *pMan = [SBBParticipantManager managerWithAuthManager:aMan networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
    SBBConsentManager *cMan = [SBBConsentManager managerWithAuthManager:aMan networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
    UIImage *signatureImage = [UIImage imageNamed:@"sample-signature" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    XCTestExpectation *expectSigned = [self expectationWithDescription:@"consent signature recorded"];
    
    __block NSString *unconsentedEmail = nil;
    __block NSString *unconsentedId = nil;
    __block BOOL consentSigned = NO;
    
    NSString *signname = @"Eggplant McTester";
    NSDate *birthdate = [NSDate dateWithTimeIntervalSinceNow:-(30 * 365.25 * 86400)];
    
    [self createTestUserConsented:NO roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        XCTAssert(!error, @"Error creating unconsented user %@:\n%@\nResponse: %@", unconsentedEmail, error, responseObject);
        if (error) {
            [expectSigned fulfill];
        } else {
            unconsentedEmail = emailAddress;
            NSSet *dataGroups = [NSSet setWithArray:@[@"sdk-int-1", @"sdk-int-2"]];
            [aMan signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                BOOL relevantError = (error && error.code != SBBErrorCodeServerPreconditionNotMet);
                XCTAssert(!relevantError, @"Error signing in unconsented user %@:\n%@\nResponse: %@", unconsentedEmail, error, responseObject);
                if (relevantError) {
                    [expectSigned fulfill];
                } else {
                    unconsentedId = responseObject[kUserSessionInfoIdKey];
                    // sign default (required) consent first
                    SBBParticipantDataSharingScope scope = SBBParticipantDataSharingScopeStudy;
                    [cMan consentSignature:signname forSubpopulationGuid:[SBBBridgeInfo shared].studyIdentifier birthdate:birthdate signatureImage:signatureImage dataSharing:scope completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
                        XCTAssert(!error, @"Error recording default consent signature:\n%@\nResponse: %@", error, responseObject);
                        if (error) {
                            [expectSigned fulfill];
                        } else {
                            // verify that the cached participant manager got updated
                            if (gSBBUseCache) {
                                NSString *participantType = [SBBStudyParticipant entityName];
                                SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[pMan.cacheManager cachedSingletonObjectOfType:participantType createIfMissing:NO];
                                XCTAssertEqualObjects(cachedParticipant.sharingScope, kSBBParticipantDataSharingScopeStrings[scope], "Cached participant scope: expected %@, got %@", kSBBParticipantDataSharingScopeStrings[scope], cachedParticipant.sharingScope);
                            }
                            // add to subpopulation that has its own required consent
                            [pMan addToDataGroups:dataGroups completion:^(id responseObject, NSError *error) {
                                BOOL relevantError = (error && error.code != SBBErrorCodeServerPreconditionNotMet);
                                XCTAssert(!relevantError, @"Error adding user %@ to groups %@:\n%@\nResponse: %@", unconsentedEmail, dataGroups, error, responseObject);
                                if (relevantError) {
                                    [expectSigned fulfill];
                                } else {
                                    // sign subpopulation consent
                                    [cMan consentSignature:signname forSubpopulationGuid:self.testSubpopRequiredGuid birthdate:birthdate signatureImage:signatureImage dataSharing:SBBParticipantDataSharingScopeStudy completion:^(id responseObject, NSError *error) {
                                        XCTAssert(!error, @"Error recording subpop consent signature:\n%@\nResponse: %@", error, responseObject);
                                        consentSigned = !error;
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
    
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout registering subpop consent signature: %@", error);
        }
    }];
    
    if (consentSigned) {
        // check that UserSessionInfo was updated with the new consent status
        SBBUserSessionInfo *sessionInfo = (SBBUserSessionInfo *)[SBBComponent(SBBCacheManager) cachedSingletonObjectOfType:SBBUserSessionInfo.entityName createIfMissing:NO];
        XCTAssert(sessionInfo, @"Failed to retrieve updated UserSessionInfo from cache");
        if (sessionInfo) {
            SBBConsentStatus *status = sessionInfo.consentStatuses[self.testSubpopRequiredGuid];
            XCTAssert(status, @"Failed to retrieve ConsentStatus for %@", self.testSubpopRequiredGuid);
            if (status) {
                XCTAssert(status.consentedValue, @"Cached ConsentStatus for %@ does not reflect having consented", self.testSubpopRequiredGuid);
            }
        }
        // now try to get it back
        XCTestExpectation *expectReceived = [self expectationWithDescription:@"consent signature received"];
        
        [cMan getConsentSignatureForSubpopulation:self.testSubpopRequiredGuid completion:^(id consentSignature, NSError *error) {
            XCTAssert(!error, @"Error getting subpop consent signature:\n%@", error);
            XCTAssert([consentSignature isKindOfClass:[SBBConsentSignature class]], @"Failed to convert incoming JSON to SBBConsentSignature");
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

#pragma clang diagnostic pop

@end
