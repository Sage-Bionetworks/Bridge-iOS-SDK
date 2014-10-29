//
//  AppDelegate.h
//  singleView
//
//  Created by Dhanush Balachandran on 10/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, getter=isLoggedIn) BOOL loggedIn;


@end

