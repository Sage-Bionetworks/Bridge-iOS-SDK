//
//  SBBBridgeAppDelegate.h
//  BridgeSDK
//
//  Created by Shannon Young on 12/1/15.
//  Copyright © 2015 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef SBBBridgeAppDelegate_h
#define SBBBridgeAppDelegate_h

/**
 * If the app delegate conforms to this protocol then the methods included will be called as appropriate.
 */
@protocol SBBBridgeAppDelegate <UIApplicationDelegate>

@optional
/**
 * Method called when the Bridge services return an error code that this version of the app is no longer supported.
 * If not implemented or returns @NO then the BridgeNetworkManager should handle the error with a general message.
 * This method will only be called once per app launch.
 *
 * @return @YES if the error has been handled by the delegate.
 */
- (BOOL)handleUnsupportedAppVersionError:(NSError*)error networkManager:(id)networkManager;

@end

#endif /* SBBBridgeAppDelegate_h */
