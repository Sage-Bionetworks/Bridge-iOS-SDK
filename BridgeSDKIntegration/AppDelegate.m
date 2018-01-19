//
//  AppDelegate.m
//  BridgeSDKIntegration
//
//  Created by Erin Mounts on 7/22/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "AppDelegate.h"
@import BridgeSDK;

// un-comment this and run on a device if you ever need to get a new base64encoded device token for
// integration testing. Copy the base64token from the console log and paste it in over the existing
// value for base64Token in the setUp method of SBBNotificationManagerIntegrationTests:
// #define GET_NEW_TOKEN 1

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // TODO: emm 2016-05-04 figure out how to do all tests both with and without caching in one run
    [BridgeSDK setup];
    
#if GET_NEW_TOKEN
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
    [application registerUserNotificationSettings:settings];
#endif
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    if ([identifier isEqualToString:kBackgroundSessionIdentifier]) {
        [SBBComponent(SBBBridgeNetworkManager) restoreBackgroundSession:identifier completionHandler:completionHandler];
    }
}

#if GET_NEW_TOKEN
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    NSLog(@"Device token: %@", deviceToken);
    NSString *base64Token = [deviceToken base64EncodedStringWithOptions:0];
    NSLog(@"base64encoded device token: %@", base64Token);
    NSString *deviceIdentifier = [[[deviceToken description]
                                   stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                  stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Device identifier: %@", deviceIdentifier);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
