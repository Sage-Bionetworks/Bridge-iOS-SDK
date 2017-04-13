//
//  SBBBridgeAPIIntegrationTestCase.m
//  BridgeSDK
//
//  Created by Erin Mounts on 7/15/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIIntegrationTestCase.h"
#import "SBBAuthManagerInternal.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBNetworkManagerInternal.h"
#import "TestAdminAuthDelegate.h"

static SBBAuthManager *gAdminAuthManager;
static TestAdminAuthDelegate *gAdminAuthDelegate;

static SBBAuthManager *gDevAuthManager;
static TestAdminAuthDelegate *gDevAuthDelegate;

NSString * const kUserSessionInfoIdKey = @"id";

//#define ADMIN_API @"/admin/v1/users"
#define ADMIN_API @"/v3/users"
#define ADMIN_SUBPOP_API @"/v3/subpopulations"
#define ADMIN_SUBPOP_API_FORMAT @"/v3/subpopulations/%@"
#define ADMIN_SUBPOP_API_DELETE_FORMAT @"/v3/subpopulations/%@?physical=true"

@implementation SBBBridgeAPIIntegrationTestCase

- (void)setUp {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // set up a separate auth manager for admin, and just use the default base network manager, not the Bridge one
        gAdminAuthManager = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
        gAdminAuthDelegate = [TestAdminAuthDelegate new];
        gAdminAuthManager.authDelegate = gAdminAuthDelegate;
        
        // ditto for dev
        gDevAuthManager = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
        gDevAuthDelegate = [TestAdminAuthDelegate new];
        gDevAuthManager.authDelegate = gDevAuthDelegate;
    });

    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (!gAdminAuthManager.isAuthenticated) {
        XCTestExpectation *expectAdminSignin = [self expectationWithDescription:@"admin account signed in"];
        
        // if available, get credentials from environment vars
        NSDictionary *environment = NSProcessInfo.processInfo.environment;
        NSString *credentialsEmail = environment[@"SAGE_ADMIN_EMAIL"];
        NSString *credentialsPassword = environment[@"SAGE_ADMIN_PASSWORD"];

        // if either is missing from environment vars, fall back to looking for the credentials
        // in a plist file that lives *outside* of the local git repo
        if (!credentialsEmail.length || !credentialsPassword.length) {
            NSString *credentialsPlist = [[NSBundle bundleForClass:[self class]] pathForResource:@"BridgeAdminCredentials" ofType:@"plist"];
            if (credentialsPlist) {
                NSDictionary *credentials = [[NSDictionary alloc] initWithContentsOfFile:credentialsPlist][@"studies"];
                NSDictionary *studyCredentials = credentials[[SBBBridgeInfo shared].studyIdentifier];
                credentialsEmail = studyCredentials[@"email"];
                credentialsPassword = studyCredentials[@"password"];
            }
        }
        
        if (credentialsEmail.length && credentialsPassword.length) {
            [gAdminAuthManager signInWithEmail:credentialsEmail password:credentialsPassword completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error logging in to admin account:\n%@\nResponse: %@", error, responseObject);
                } else {
                    NSLog(@"Logged in to admin account:\n%@", responseObject);
                }
                [expectAdminSignin fulfill];
            }];
            
            [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
                if (error) {
                    NSLog(@"Time out error trying to log in to admin account:\n%@", error);
                }
            }];
        } else {
            NSLog(@"Error: Missing admin email (%@) and/or password (%@) for integration test study", credentialsEmail, credentialsPassword);
        }
    }
    
    // create & sign in a dev user
    XCTestExpectation *expectDevCreated = [self expectationWithDescription:@"dev user created"];
    
    [self createTestUserConsented:YES roles:@[@"developer"] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating dev user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
            if (![error.domain isEqualToString:@"com.apple.XCTestErrorDomain"] || error.code != 0) {
                [expectDevCreated fulfill];
            }
        } else {
            _devUserEmail = emailAddress;
            _devUserPassword = password;
            [gDevAuthManager signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error signing in to dev user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                }
                _devSignInResponseObject = responseObject;
                [expectDevCreated fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to create and sign in to test account:\n%@", error);
        }
    }];
    
    // create & sign in a test user
    XCTestExpectation *expectTestCreated = [self expectationWithDescription:@"test user created"];
    
    [self createTestUserConsented:YES roles:@[] completionHandler:^(NSString *emailAddress, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
            if (![error.domain isEqualToString:@"com.apple.XCTestErrorDomain"] || error.code != 0) {
                [expectTestCreated fulfill];
            }
        } else {
            _testUserEmail = emailAddress;
            _testUserPassword = password;
            [SBBComponent(SBBAuthManager) signInWithEmail:emailAddress password:password completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error signing in to test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                }
                _testSignInResponseObject = responseObject;
                [expectTestCreated fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to create and sign in to test account:\n%@", error);
        }
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    XCTestExpectation *expectTestDeleted = [self expectationWithDescription:@"test user deleted"];
    [self deleteUser:_testSignInResponseObject[kUserSessionInfoIdKey] completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted test account %@", _testUserEmail);
        } else {
            NSLog(@"Failed to delete test account %@\n\nError:%@\nResponse:%@", _testUserEmail, error, responseObject);
        }
        [expectTestDeleted fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error attempting to delete test user account %@: %@", _testUserEmail, error);
        }
    }];
    
    XCTestExpectation *expectDevSignedOut = [self expectationWithDescription:@"dev user signed out"];

    [gDevAuthManager signOutWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        [expectDevSignedOut fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error attempting to sign out from dev user account %@: %@", _devUserEmail, error);
        }
    }];
    
    XCTestExpectation *expectDevDeleted = [self expectationWithDescription:@"dev user deleted"];
    [self deleteUser:_devSignInResponseObject[kUserSessionInfoIdKey] completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted dev account %@", _devUserEmail);
        } else {
            NSLog(@"Failed to delete dev account %@\n\nError:%@\nResponse:%@", _devUserEmail, error, responseObject);
        }
        [expectDevDeleted fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error attempting to delete dev user account %@: %@", _devUserEmail, error);
        }
    }];
    
    [super tearDown];
}

- (void)createTestUserConsented:(BOOL)consented roles:(NSArray *)roles completionHandler:(SBBBridgeAPIIntegrationTestCaseCreateCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [gAdminAuthManager addAuthHeaderToHeaders:headers];
    
    NSString *emailFormat = @"bridge-testing+test%@@sagebase.org";
    NSString *unique = [[NSProcessInfo processInfo] globallyUniqueString];
    __block NSString *emailAddress = [NSString stringWithFormat:emailFormat, unique];
    NSString *password = @"123456";
    NSDictionary *signUpObject =
    @{
      @"email": emailAddress,
      @"password": password,
      @"consent": [NSNumber numberWithBool:consented],
      @"roles": roles,
      @"type": @"SignUp"
      };
    
    NSString *consentedState = consented ? @"consented" : @"unconsented";
    
    id<SBBBridgeNetworkManagerProtocol> bridgeMan = SBBComponent(SBBBridgeNetworkManager);
    [bridgeMan post:ADMIN_API headers:headers parameters:signUpObject completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Failed to create %@ user %@\nError:%@\nResponse:%@", consentedState, emailAddress, error, responseObject);
            emailAddress = nil;
        } else {
            NSLog(@"Created %@ test user %@", consentedState, emailAddress);
        }
        
        if (completion) {
            completion(emailAddress, password, responseObject, error);
        }
    }];
}

- (void)deleteUser:(NSString *)userId completionHandler:(SBBNetworkManagerCompletionBlock)completion
{
    NSString *deleteUserFormat = ADMIN_API @"/%@";
    NSString *deleteUser = [NSString stringWithFormat:deleteUserFormat, userId];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [gAdminAuthManager addAuthHeaderToHeaders:headers];
    [SBBComponent(SBBNetworkManager) delete:deleteUser headers:headers parameters:nil completion:completion];
}

- (void)createSubpopulation:(NSString *)subpopName forGroups:(NSArray *)inGroups notGroups:(NSArray *)outGroups required:(BOOL)required withCompletion:(SBBBridgeAPIIntegrationTestCaseCreateSubpopCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [gDevAuthManager addAuthHeaderToHeaders:headers];
    
    NSNumber *isRequired = [NSNumber numberWithBool:required];
    
    NSMutableDictionary *subpopObject =
    [@{
      @"name": subpopName,
      @"guid": [NSNull null],
      @"description": @"for Bridge iOS SDK integration tests",
      @"required": isRequired,
      @"defaultGroup": @NO,
      @"type": @"Subpopulation"
      } mutableCopy];
    
    if (inGroups) {
        [subpopObject setObject:inGroups forKey:@"allOfGroups"];
    }
    if (outGroups) {
        [subpopObject setObject:outGroups forKey:@"noneOfGroups"];
    }
    
    id<SBBBridgeNetworkManagerProtocol> bridgeMan = SBBComponent(SBBBridgeNetworkManager);
    [bridgeMan post:ADMIN_SUBPOP_API headers:headers parameters:subpopObject completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        NSString *guid = nil;
        
        if (error) {
            NSLog(@"Failed to create %@ test subpopulation %@\nError:%@\nResponse:%@", isRequired, subpopName, error, responseObject);
        } else {
            NSLog(@"Created %@ test subpopulation %@", isRequired, subpopName);
            guid = responseObject[@"guid"];
        }
        
        if (completion) {
            completion(guid, responseObject, error);
        }
    }];
}

- (void)deleteSubpopulation:(NSString *)subpopGuid completionHandler:(SBBNetworkManagerCompletionBlock)completion
{
    NSString *deleteSubpopAPI = [NSString stringWithFormat:ADMIN_SUBPOP_API_DELETE_FORMAT, subpopGuid];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [gAdminAuthManager addAuthHeaderToHeaders:headers];
    [SBBComponent(SBBNetworkManager) delete:deleteSubpopAPI headers:headers parameters:nil completion:completion];
}

@end
