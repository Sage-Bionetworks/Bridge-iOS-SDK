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

#import "ViewController.h"
#import "AppDelegate.h"
#import "SignUpSignInViewController.h"
#import "UserProfileViewController.h"
#import "SurveyViewController.h"
#import "SchedulesTableViewController.h"
#import "TasksTableViewController.h"
#import <BridgeSDK/BridgeSDK.h>

@interface ViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moreBarButtonItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (((AppDelegate*)[UIApplication sharedApplication].delegate).isLoggedIn) {
        [self didTouchMoreBarButtonitem:nil];
    }
    else
    {
        // show sign up/sign in screen, and upon successful completion call uponLogin
        UIStoryboard *sus = [UIStoryboard storyboardWithName:@"SignUpSignIn" bundle:nil];
        SignUpSignInViewController *suvc = [sus instantiateInitialViewController];
        [self.navigationController pushViewController:suvc animated:YES];
    }
}


- (IBAction)didTouchMoreBarButtonitem:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do what?"
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Sign Up/Sign In", @"Sign Up/Sign In"),
                                  NSLocalizedString(@"Sign Out", @"Sign Out"),
                                  NSLocalizedString(@"Simulate Expired Session", @"Simulate Expired Session"),
                                  NSLocalizedString(@"Profile", @"Profile"),
                                  NSLocalizedString(@"Consent", @"Consent"),
                                  NSLocalizedString(@"Survey", @"Survey"),
                                  NSLocalizedString(@"Upload", @"Upload"),
                                  NSLocalizedString(@"Schedule", @"Schedule"),
                                  NSLocalizedString(@"Tasks", @"Tasks"),
                                  nil];
    [actionSheet showFromBarButtonItem:self.moreBarButtonItem animated:YES];
}

typedef NS_ENUM(NSInteger, _ActionButtons) {
  asCancel = -1,
  asSignUpSignIn,
  asSignOut,
  asExpireSession,
  asProfile,
  asConsent,
  asSurvey,
  asUpload,
  asSchedule,
  asTasks
};

#pragma mark - Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case asCancel:
            break;
            
        case asSignUpSignIn:
        {
            UIStoryboard *sus = [UIStoryboard storyboardWithName:@"SignUpSignIn" bundle:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                SignUpSignInViewController *suvc = [sus instantiateInitialViewController];
                [self.navigationController pushViewController:suvc animated:YES];
            });
        }
            break;
            
        case asSignOut:
        {
            [SBBComponent(SBBAuthManager) signOutWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ((AppDelegate*)[UIApplication sharedApplication].delegate).loggedIn = NO;
                    UIStoryboard *sus = [UIStoryboard storyboardWithName:@"SignUpSignIn" bundle:nil];
                    SignUpSignInViewController *suvc = [sus instantiateInitialViewController];
                    [self.navigationController pushViewController:suvc animated:YES];
                });
            }];
        }
            break;
            
        case asExpireSession:
        {
            // give it a bogus session token so the Bridge API will return "401 not auth" from the next call
            // to any endpoint requiring auth, e.g. profile, schedules, surveys, etc.
            id<SBBAuthManagerProtocol> authMan = SBBComponent(SBBAuthManager);
            [authMan.authDelegate authManager:authMan didGetSessionToken:@"notAValidSessionToken"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didTouchMoreBarButtonitem:nil];
            });
        }
            break;
            
        case asProfile:
        {
            UIStoryboard *ups = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
            UserProfileViewController *upvc = [ups instantiateInitialViewController];
            [self.navigationController pushViewController:upvc animated:YES];
        }
            break;
            
        case asConsent:
        {
            UIStoryboard *ups = [UIStoryboard storyboardWithName:@"Consent" bundle:nil];
            UserProfileViewController *upvc = [ups instantiateInitialViewController];
            [self.navigationController pushViewController:upvc animated:YES];
        }
            break;
            
        case asSurvey:
        {
            UIStoryboard *ss = [UIStoryboard storyboardWithName:@"Survey" bundle:nil];
            SurveyViewController *svc = [ss instantiateInitialViewController];
            [self.navigationController pushViewController:svc animated:YES];
        }
            break;
            
        case asUpload:
        {
            NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"cat" withExtension:@"jpg"];
            [SBBComponent(SBBUploadManager) uploadFileToBridge:fileUrl contentType:@"image/jpeg" completion:^(NSError *error) {
                if (error) {
                    NSLog(@"Error uploading file:\n%@", error);
                } else {
                    NSLog(@"Uploaded file");
                }
            }];
        }
            break;
            
        case asSchedule:
        {
            UIStoryboard *ss = [UIStoryboard storyboardWithName:@"Schedule" bundle:nil];
            SchedulesTableViewController *stvc = [ss instantiateInitialViewController];
            [self.navigationController pushViewController:stvc animated:YES];
        }
            break;
            
        case asTasks:
        {
            UIStoryboard *ss = [UIStoryboard storyboardWithName:@"Tasks" bundle:nil];
            TasksTableViewController *ttvc = [ss instantiateInitialViewController];
            [self.navigationController pushViewController:ttvc animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
