//
//  SignUpSignInViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 9/17/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SignUpSignInViewController.h"
#import "AppDelegate.h"
#import <BridgeSDK/BridgeSDK.h>

@interface SignUpSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *resetTokenTextField;
@property (weak, nonatomic) IBOutlet UITextField *resetPasswordTextField;

- (IBAction)didTouchSignUpSignInButton:(id)sender;
- (IBAction)didTouchResendVerificationButton:(id)sender;
- (IBAction)didTouchRequestPasswordResetButton:(id)sender;
- (IBAction)didTouchResetPasswordButton:(id)sender;
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
                    [self finishUp];
                    NSLog(@"Signed up successfully!");
                } else {
                    NSLog(@"Sign up failed:\n%@", error);
                }
            }];
        } else {
            [SBBComponent(SBBAuthManager) signInWithUsername:username password:password completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                if (responseObject[@"sessionToken"]) {
                    [self finishUp];
                    NSLog(@"Signed in successfully to existing account!");
                    NSLog(@"Sharing scope:%@", responseObject[@"sharingScope"]);
                } else {
                    NSLog(@"Sign in failed:\n%@", error);
                }
            }];
        }
    }
}

- (IBAction)didTouchResendVerificationButton:(id)sender {
    NSString *emailAddress = _emailAddressTextField.text;
    
    if (emailAddress.length) {
        [SBBComponent(SBBAuthManager) resendEmailVerification:emailAddress completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            if (!error) {
                [self finishUp];
                NSLog(@"%@", [responseObject objectForKey:@"message"]);
            } else {
                NSLog(@"Error attempting to re-send email verification:\n%@", error);
            }
        }];
    }
}

- (IBAction)didTouchRequestPasswordResetButton:(id)sender {
  NSString *emailAddress = _emailAddressTextField.text;
  
  if (emailAddress.length) {
    [SBBComponent(SBBAuthManager) requestPasswordResetForEmail:emailAddress completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
      NSLog(@"request password reset response:\n%@\nerror:\n%@", responseObject, error);
    }];
  }
}

- (IBAction)didTouchResetPasswordButton:(id)sender {
  NSString *token = _resetTokenTextField.text;
  NSString *newPassword = _resetPasswordTextField.text;
  
  if (token.length && newPassword.length) {
    [SBBComponent(SBBAuthManager) resetPasswordToNewPassword:newPassword resetToken:token completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
      NSLog(@"reset password response:\n%@\nerror:\n%@", responseObject, error);
    }];
  }
}

- (void) finishUp
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ((AppDelegate*)[UIApplication sharedApplication].delegate).loggedIn = YES;
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
