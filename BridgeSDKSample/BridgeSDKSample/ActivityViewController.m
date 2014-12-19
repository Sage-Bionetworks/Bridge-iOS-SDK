//
//  ActivityViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 12/17/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "ActivityViewController.h"

@interface ActivityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *labelTextField;
@property (weak, nonatomic) IBOutlet UITextField *refTextField;
@property (weak, nonatomic) IBOutlet UITextField *activityTypeTextField;

@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.labelTextField.text = self.activity.label;
    self.refTextField.text = self.activity.ref;
    self.activityTypeTextField.text = self.activity.activityType;
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

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

@end
