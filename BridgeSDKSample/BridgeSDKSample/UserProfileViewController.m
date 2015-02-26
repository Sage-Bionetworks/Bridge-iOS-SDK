//
//  UserProfileViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 9/30/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "UserProfileViewController.h"
@import BridgeSDK;

static NSString *kSBBConsentSharingScopeKey = @"SBBConsentSharingScope";

@interface UserProfileViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;
@property (weak, nonatomic) IBOutlet UIPickerView *scopePickerView;

- (IBAction)didTouchLoadButton:(id)sender;
- (IBAction)didTouchUpdateButton:(id)sender;

- (IBAction)didTouchGiveButton:(id)sender;
- (IBAction)didTouchChangeButton:(id)sender;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSInteger scope = [[NSUserDefaults standardUserDefaults] integerForKey:kSBBConsentSharingScopeKey];
    [_scopePickerView selectRow:scope inComponent:0 animated:YES];
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
    
    [SBBComponent(SBBProfileManager) updateUserProfileWithProfile:profile completion:^(id responseObject, NSError *error) {
        NSLog(@"%@", responseObject);
        NSLog(@"Error: %@", error);
    }];
    
}

- (IBAction)didTouchGiveButton:(id)sender {
    // Load sample signature from bundle and send it to the server.
    NSString* imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sample-signature" ofType:@"png"];
    NSData* imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage* image = [[UIImage alloc] initWithData:imageData];
    
    NSInteger scope = [_scopePickerView selectedRowInComponent:0];
    
    // call server
    [SBBComponent(SBBConsentManager) consentSignature:@"::name::"
                                            birthdate:[NSDate dateWithTimeIntervalSinceNow:-946684800.0]
                                       signatureImage:image
                                          dataSharing:scope
                                           completion:^(id responseObject, NSError *error) {
                                               NSLog(@"%@", responseObject);
                                               NSLog(@"Error: %@", error);
                                               if (!error) {
                                                   [[NSUserDefaults standardUserDefaults] setInteger:scope forKey:kSBBConsentSharingScopeKey];
                                               }
                                           }];
}

- (IBAction)didTouchGetButton:(id)sender {
    [SBBComponent(SBBConsentManager) retrieveConsentSignatureWithCompletion:^(NSString* name, NSString* birthdate,
                                                                              UIImage* signatureImage, NSError* error) {
        if (signatureImage != nil) {
            _signatureImageView.image = signatureImage;
        }
        NSLog(@"Name: %@", name);
        NSLog(@"Birthdate: %@", birthdate);
        NSLog(@"HasSignatureImage: %@", signatureImage != nil ? @"true" : @"false");
        NSLog(@"Error: %@", error);
    }];
}

- (IBAction)didTouchChangeButton:(id)sender {
    NSInteger scope = [_scopePickerView selectedRowInComponent:0];
    [SBBComponent(SBBConsentManager) dataSharing:scope completion:^(id responseObject, NSError *error) {
        NSLog(@"%@", responseObject);
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    static NSString *sharingScopes[] = {
        @"None",
        @"This study only",
        @"All qualified researchers"
    };
    return sharingScopes[row];
}

@end
