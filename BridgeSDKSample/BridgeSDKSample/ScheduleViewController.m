//
//  ScheduleViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 10/27/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ActivitiesTableViewController.h"

@interface ScheduleViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *labelTextField;
@property (weak, nonatomic) IBOutlet UITextField *activityRefTextField;
@property (weak, nonatomic) IBOutlet UITextField *scheduleTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cronTriggerTextField;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.labelTextField.text = self.schedule.label;
  self.scheduleTypeTextField.text = self.schedule.scheduleType;
  self.cronTriggerTextField.text = self.schedule.cronTrigger;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ActivitiesTableViewController *atvc = (ActivitiesTableViewController *)[segue destinationViewController];
    atvc.activities = self.schedule.activities;
}



@end
