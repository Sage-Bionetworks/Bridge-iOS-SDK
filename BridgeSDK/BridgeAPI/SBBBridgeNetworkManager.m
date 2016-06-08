//
//  SBBBridgeNetworkManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/26/15.
//
//	Copyright (c) 2015, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBBridgeNetworkManager.h"
#import "SBBNetworkManagerInternal.h"
#import "SBBAuthManagerInternal.h"
#import "SBBErrors.h"
#import "NSError+SBBAdditions.h"

@interface SBBBridgeNetworkManager ()

@property (nonatomic, strong, readonly) id<SBBAuthManagerInternalProtocol> authManager;

@end

@implementation SBBBridgeNetworkManager

+ (instancetype)defaultComponent
{
    if (!gSBBAppStudy) {
        return nil;
    }
    
    static SBBBridgeNetworkManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initWithAuthManager:SBBComponent(SBBAuthManager)];
    });
    
    return shared;
}

- (instancetype)initWithAuthManager:(id<SBBAuthManagerInternalProtocol>)authManager
{
    SBBEnvironment environment = gSBBDefaultEnvironment;
    
    NSString *baseURL = [[self class] baseURLForEnvironment:environment appURLPrefix:kAPIPrefix baseURLPath:@"sagebridge.org"];
    NSString *bridgeStudy = gSBBAppStudy;
    if (self = [super initWithBaseURL:baseURL bridgeStudy:bridgeStudy]) {
        self.environment = environment;
        _authManager = authManager;
    }
    
    return self;
}

- (NSURLSessionTask *)doDataTask:(NSString *)method
                       URLString:(NSString *)URLString
                         headers:(NSDictionary *)headers
                      parameters:(NSDictionary *)parameters
                      background:(BOOL)background
                      completion:(SBBNetworkManagerCompletionBlock)completion
{
    // If we have already tried to call services and the unsupported app exception code was returned
    // then do not try again. Just return the error.
    if (self.isUnsupportedAppVersion) {
        if (completion) {
            completion(nil, nil, [NSError SBBUnsupportedAppVersionError]);
        }
        return nil;
    }
    
    return [super doDataTask:method URLString:URLString headers:headers parameters:parameters background:background completion:completion];
}

- (NSURLSessionDownloadTask *)downloadFileFromURLString:(NSString *)urlString
                                                 method:(NSString *)httpMethod
                                            httpHeaders:(NSDictionary *)headers
                                             parameters:(NSDictionary *)parameters
                                        taskDescription:(NSString *)description
                                     downloadCompletion:(SBBNetworkManagerDownloadCompletionBlock)downloadCompletion
                                         taskCompletion:(SBBNetworkManagerTaskCompletionBlock)taskCompletion
{
    // If we have already tried to call services and the unsupported app exception code was returned
    // then do not try again. Just return the error.
    if (self.isUnsupportedAppVersion) {
        if (taskCompletion) {
            taskCompletion(nil, nil, [NSError SBBUnsupportedAppVersionError]);
        }
        return nil;
    }
    
    return [super downloadFileFromURLString:urlString method:httpMethod httpHeaders:headers parameters:parameters taskDescription:description downloadCompletion:downloadCompletion taskCompletion:taskCompletion];
}

- (void)handleHTTPError:(NSError *)error task:(NSURLSessionTask *)task response:(id)responseObject retryObject:(SBBNetworkRetryObject *)retryObject
{
    if (retryObject && retryObject.retryBlock && error.code == SBBErrorCodeServerNotAuthenticated && [_authManager isAuthenticated])
    {
#if DEBUG
        NSLog(@"Bridge API call returned status code 401; attempting to refresh session token");
#endif
        // clear the stored session token if any, and attempt reauth
        [_authManager clearSessionToken];
        [_authManager ensureSignedInWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            // ignore 412 Not Consented on signIn when auto-renewing the session token; some Bridge endpoints still work when not consented,
            // and those that don't will themselves return a 412 status code
            BOOL relevantError = (error && error.code != SBBErrorCodeServerPreconditionNotMet);
            if (relevantError) {
#if DEBUG
                NSLog(@"Session token auto-refresh failed:\n%@", error);
#endif
                [self checkForAndHandleUnsupportedAppVersionHTTPError:error];
                [super handleHTTPError:error task:task response:responseObject retryObject:retryObject];
            } else {
#if DEBUG
                NSLog(@"Session token auto-refresh succeeded, retrying original request");
#endif
                dispatch_async(dispatch_get_main_queue(), ^{
                    retryObject.retryBlock();
                    // don't count this against retries
                });
            }
        }];
    } else {
        [self checkForAndHandleUnsupportedAppVersionHTTPError:error];
        [self checkForAndHandleServerPreconditionNotMetHTTPError:error task:task responseObject:responseObject retryObject:retryObject];
        [super handleHTTPError:error task:task response:responseObject retryObject:retryObject];
    }
}

- (void)checkForAndHandleUnsupportedAppVersionHTTPError:(NSError *)error
{
    // Set flag that blocks attempting further retries once this error has been received.
    // All future attempts to access services will fail.
    if (error.code == SBBErrorCodeUnsupportedAppVersion && !self.isUnsupportedAppVersion)
    {
        // Set flag that this exception has already been thrown by the server
        _unsupportedAppVersion = YES;
        
        // Look to see if the app delegate handles this error or if this SDK should do so.
        // Note: check conforms to protocol to ensure that the app delegate is intentionally
        // implementing this method and not coincidentally using the same method signature for something else.
        id appDelegate = [[UIApplication sharedApplication] delegate];
        if (![appDelegate conformsToProtocol:@protocol(SBBBridgeAppDelegate)] ||
            ![appDelegate respondsToSelector:@selector(handleUnsupportedAppVersionError:networkManager:)] ||
            ![appDelegate handleUnsupportedAppVersionError:error networkManager:self])
        {
            // Show default alert with a button tap to take the user to the app store to update
            NSString *localizedTitle = NSLocalizedStringWithDefaultValue(@"SBB_ALERT_TITLE_UNSUPPORTED_APP", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Unsupported App Version", @"Alert title: Unsupported App Version");
            NSString *localizedDismiss = NSLocalizedStringWithDefaultValue(@"SBB_ALERT_DISMISS_BUTTON", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Dismiss", @"Alert button: dismiss");
            NSString *localizedAppStore = NSLocalizedStringWithDefaultValue(@"SBB_ALERT_APPSTORE_BUTTON", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"App Store", @"Alert button: App Store");
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:localizedTitle message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:localizedDismiss style:UIAlertActionStyleDefault handler:^(UIAlertAction *__unused action) {
            }];
            [alertController addAction:dismiss];
            UIAlertAction *appStore = [UIAlertAction actionWithTitle:localizedAppStore style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
                [[UIApplication sharedApplication] openURL:[[NSBundle mainBundle] appStoreLinkURL]];
            }];
            [alertController addAction:appStore];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)checkForAndHandleServerPreconditionNotMetHTTPError:(NSError *)error task:(NSURLSessionTask *)task responseObject:(id)responseObject retryObject:(SBBNetworkRetryObject *)retryObject
{
    if (error.code == SBBErrorCodeServerPreconditionNotMet)
    {
        // Look to see if the app delegate handles this error.
        // Note: check conforms to protocol to ensure that the app delegate is intentionally
        // implementing this method and not coincidentally using the same method signature for something else.
        id appDelegate = [[UIApplication sharedApplication] delegate];
        if (![appDelegate conformsToProtocol:@protocol(SBBBridgeAppDelegate)] ||
            ![appDelegate respondsToSelector:@selector(handleUserNotConsentedError:sessionInfo:networkManager:)] ||
            ![appDelegate handleUserNotConsentedError:error sessionInfo:responseObject networkManager:self])
        {
#if DEBUG
            // Log the error to the console
            NSLog(@"User Not Consented error not handled by app delegate:\n%@", error);
#endif
        }
    }
}

- (NSDictionary *)headersPreparedForRetry:(NSDictionary *)headers
{
    NSMutableDictionary *preparedHeaders = [headers mutableCopy];
    
    // rewrite the auth headers in case the session token got refreshed
    [_authManager addAuthHeaderToHeaders:preparedHeaders];
    
    return preparedHeaders;
}

@end
