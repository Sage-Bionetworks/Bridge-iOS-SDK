//
//  UserProfileViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 9/30/14.
//
//	Copyright (c) 2014, Sage Bionetworks
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
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "UserProfileViewController.h"
@import BridgeSDK;

// Add support for custom fields in SBBUserProfile. Custom fields must be of type NSString *
// and must be configured in the Bridge study before use.
//
// The default getters and setters for custom fields provided by the iOS Bridge SDK are
// implemented in such a way that they are effectively nonatomic and strong. Use of
// custom getter and setter names with default implementations is not supported; in those
// cases you will need to provide your own. See SBBUserProfile.m for an example of how to
// implement custom properties in Objective-C categories using associated objects.
@interface SBBUserProfile (customFields)

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *can_be_recontacted;

@end

// By declaring the implementations of custom fields as @dynamic, the iOS Bridge SDK
// will install default implementations at runtime. If you choose to provide your own
// implementations you will need to provide a getter and a setter. See SBBUserProfile.m
// for an example of how to implement custom properties in Objective-C categories using
// associated objects.
@implementation SBBUserProfile (customFields)

@dynamic phone;
@dynamic can_be_recontacted;

@end

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UISwitch *canRecontactSwitch;
@property (weak, nonatomic) IBOutlet UITextField *externalIDTextField;

- (IBAction)didTouchLoadButton:(id)sender;
- (IBAction)didTouchUpdateButton:(id)sender;
- (IBAction)didTouchSetButton:(id)sender;

@end

@implementation UserProfileViewController

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

- (void)updateWithProfile:(SBBUserProfile *)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _emailAddressTextField.text = profile.email;
        _usernameTextField.text = profile.username;
        _firstNameTextField.text = profile.firstName;
        _lastNameTextField.text = profile.lastName;
        _phoneTextField.text = profile.phone;
        [_canRecontactSwitch setOn:[profile.can_be_recontacted boolValue] animated:YES];
    });
}

- (IBAction)didTouchLoadButton:(id)sender {
    [SBBComponent(SBBProfileManager) getUserProfileWithCompletion:^(id userProfile, NSError *error) {
        if (userProfile) {
            SBBUserProfile *profile = userProfile;
            [self updateWithProfile:profile];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (IBAction)didTouchUpdateButton:(id)sender {
    SBBUserProfile *profile = [SBBUserProfile new];
    profile.email = _emailAddressTextField.text;
    profile.username = _usernameTextField.text;
    profile.firstName = _firstNameTextField.text;
    profile.lastName = _lastNameTextField.text;
    profile.phone = _phoneTextField.text;
    profile.can_be_recontacted = [[NSNumber numberWithBool:_canRecontactSwitch.on] stringValue];
    
    [SBBComponent(SBBProfileManager) updateUserProfileWithProfile:profile completion:^(id responseObject, NSError *error) {
        NSLog(@"%@", responseObject);
        NSLog(@"Error: %@", error);
    }];
    
}

- (IBAction)didTouchSetButton:(id)sender {
    [SBBComponent(SBBProfileManager) addExternalIdentifier:_externalIDTextField.text completion:^(id responseObject, NSError *error) {
        NSLog(@"%@", responseObject);
        NSLog(@"Error: %@", error);
    }];
}

@end
