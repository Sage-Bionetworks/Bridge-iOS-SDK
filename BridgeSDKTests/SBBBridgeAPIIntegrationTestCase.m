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

//#define ADMIN_API @"/admin/v1/users"
#define ADMIN_API @"/v3/users"
#define TEST_STUDY @"api"

@implementation SBBBridgeAPIIntegrationTestCase

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // set up a separate auth manager for admin, and just use the default base network manager, not the Bridge one
        gAdminAuthManager = [SBBAuthManager authManagerWithNetworkManager:SBBComponent(SBBNetworkManager)];
        gAdminAuthDelegate = [TestAdminAuthDelegate new];
        gAdminAuthManager.authDelegate = gAdminAuthDelegate;
    });
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (!gAdminAuthManager.isAuthenticated) {
        XCTestExpectation *expectAdminSignin = [self expectationWithDescription:@"admin account signed in"];
        
        // sensitive credentials are stored in a plist file that lives *outside* of the local git repo
        NSString *credentialsPlist = [[NSBundle bundleForClass:[self class]] pathForResource:@"BridgeAdminCredentials" ofType:@"plist"];
        NSDictionary *credentials = [[NSDictionary alloc] initWithContentsOfFile:credentialsPlist];
        
        [gAdminAuthManager signInWithUsername:credentials[@"username"] password:credentials[@"password"] completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error logging in to admin account:\n%@\nResponse: %@", error, responseObject);
            } else {
                NSLog(@"Logged in to admin account:\n%@", responseObject);
            }
            [expectAdminSignin fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Time out error trying to log in to admin account:\n%@", error);
            }
        }];
    }

    XCTestExpectation *expectCreated = [self expectationWithDescription:@"test user created"];

    [self createTestUserConsented:YES roles:@[] completionHandler:^(NSString *emailAddress, NSString *username, NSString *password, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error creating test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
            if (![error.domain isEqualToString:@"com.apple.XCTestErrorDomain"] || error.code != 0) {
                [expectCreated fulfill];
            }
        } else {
            _testUserEmail = emailAddress;
            _testUserUsername = username;
            _testUserPassword = password;
            [SBBComponent(SBBAuthManager) signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error signing in to test user account %@:\n%@\nResponse: %@", emailAddress, error, responseObject);
                }
                _testSignInResponseObject = responseObject;
                [expectCreated fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to create and sign in to test account:\n%@", error);
        }
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    XCTestExpectation *expectation = [self expectationWithDescription:@"test user deleted"];
    [self deleteUser:_testUserEmail completionHandler:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Deleted test account %@", _testUserEmail);
        } else {
            NSLog(@"Failed to delete test account %@\n\nError:%@\nResponse:%@", _testUserEmail, error, responseObject);
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error attempting to delete test user account %@: %@", _testUserEmail, error);
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
    NSString *usernameFormat = @"iOSIntegrationTestUser%@";
    NSString *username = [NSString stringWithFormat:usernameFormat, unique];
    NSString *password = @"123456";
    NSDictionary *signUpObject =
    @{
      @"email": emailAddress,
      @"username": username,
      @"password": password,
      @"consent": [NSNumber numberWithBool:consented],
      @"roles": roles,
      @"type": @"SignUp"
      };
    
    NSString *consentedState = consented ? @"consented" : @"unconsented";

    id<SBBBridgeNetworkManagerProtocol> bridgeMan = SBBComponent(SBBBridgeNetworkManager);
    [bridgeMan post:ADMIN_API headers:headers parameters:signUpObject completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Failed to create %@ user %@\nError:%@\nResponse:%@", consentedState, emailAddress, error, responseObject);
            emailAddress = nil;
        } else {
            NSLog(@"Created %@ test user %@", consentedState, emailAddress);
        }
        
        if (completion) {
            completion(emailAddress, username, password, responseObject, error);
        }
    }];
}

- (void)deleteUser:(NSString *)emailAddress completionHandler:(SBBNetworkManagerCompletionBlock)completion
{
    NSString *deleteEmailFormat = ADMIN_API @"?email=%@";
    NSString *deleteEmail = [NSString stringWithFormat:deleteEmailFormat, emailAddress];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [gAdminAuthManager addAuthHeaderToHeaders:headers];
    [SBBComponent(SBBNetworkManager) delete:deleteEmail headers:headers parameters:nil completion:completion];
}

@end
