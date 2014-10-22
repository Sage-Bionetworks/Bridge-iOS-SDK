//
//  SignUpSignInViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 9/17/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SignUpSignInViewController.h"
#import <BridgeSDK/BridgeSDK.h>

@interface SignUpSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)didTouchSignUpSignInButton:(id)sender;
@end

@implementation SignUpSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTouchSignUpSignInButton:(id)sender {
  NSString *emailAddress = _emailAddressTextField.text;
  NSString *username = _usernameTextField.text;
  NSString *password = _passwordTextField.text;
  
  if (username.length && password.length) {
    if (emailAddress.length) {
      [SBBComponent(SBBAuthManager) signUpWithEmail:emailAddress username:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (!error) {
          NSLog(@"Signed up successfully!");
        } else {
          NSLog(@"Sign up failed: %@", error.description);
        }
      }];
    } else {
      [SBBComponent(SBBAuthManager) signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (responseObject[@"sessionToken"]) {
          NSLog(@"Signed in successfully to existing account!");
        } else {
          NSLog(@"Sign in failed: %@", error.description);
        }
      }];
    }
  }
}

@end
