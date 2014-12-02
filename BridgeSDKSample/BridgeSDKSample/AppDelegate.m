//
//  AppDelegate.m
//  singleView
//
//  Created by Dhanush Balachandran on 10/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpSignInViewController.h"
#import <BridgeSDK/BridgeSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Bridge developers: To run this sample app against your own local copy of the Bridge server, un-comment the
    // following code and replace "<server>" with your Bridge server (ex: "https://localhost:9000" or
    // "http://192.168.2.1:9000"). Also be sure to change the setupWithAppPrefix call below to match your network
    // manager.
    SBBNetworkManager* networkMan = [SBBNetworkManager networkManagerForEnvironment:SBBEnvironmentCustom
        appURLPrefix:@"" baseURLPath:@"http://192.168.55.1:9000"];
    [SBBComponentManager registerComponent:networkMan forClass:[SBBNetworkManager class]];

    // To run this sample app in your study, change this prefix to the one assigned to your study.
    // Leave it set to @"api" to run in the generic test study.
    [BridgeSDK setupWithAppPrefix:@"" environment:SBBEnvironmentCustom];
    
    [SBBComponent(SBBAuthManager) ensureSignedInWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (error.code == kSBBNoCredentialsAvailable)
        {
            self.loggedIn = NO;
        } else
        {
            self.loggedIn = YES;
        }
    }];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:kBackgroundSessionIdentifier]) {
        [SBBComponent(SBBNetworkManager) restoreBackgroundSession:identifier completionHandler:completionHandler];
    }
}

@end
