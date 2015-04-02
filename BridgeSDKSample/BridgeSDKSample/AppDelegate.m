/*
 Copyright (c) 2015, Sage Bionetworks. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
    //SBBNetworkManager* networkMan = [SBBNetworkManager networkManagerForEnvironment:SBBEnvironmentCustom
    //    appURLPrefix:@"" baseURLPath:@"http://192.168.55.1:9000"];
    //[SBBComponentManager registerComponent:networkMan forClass:[SBBNetworkManager class]];

    // To run this sample app in your study, change this prefix to the one assigned to your study.
    // Leave it set to @"api" to run in the generic test study.
    [BridgeSDK setupWithAppPrefix:@"api"];
    
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
