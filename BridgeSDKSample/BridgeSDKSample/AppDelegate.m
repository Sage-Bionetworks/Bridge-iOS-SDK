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
    
    // To run this sample app in your study, change this prefix to the one assigned to your study.
    // Leave it set to @"api" to run in the generic test study.
    [BridgeSDK setupWithAppPrefix:@"pd"];
    
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
