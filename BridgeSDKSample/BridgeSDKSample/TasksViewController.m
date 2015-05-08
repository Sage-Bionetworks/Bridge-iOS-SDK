//
//  TasksViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 5/8/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "TasksViewController.h"
#import "TasksTableViewController.h"
@import BridgeSDK;

@interface TasksViewController ()

@property (strong, nonatomic) NSArray *tasks;
@property (weak, nonatomic) TasksTableViewController *tasksTableViewController;
@property (weak, nonatomic) IBOutlet UIDatePicker *untilDatePicker;

- (IBAction)didTouchLoadButton:(id)sender;

@end

@implementation TasksViewController

- (void)reloadTasks
{
    NSURLSessionDataTask *sdtask = [SBBComponent(SBBTaskManager) getTasksUntil:_untilDatePicker.date withCompletion:^(id tasksList, NSError *error) {
        SBBResourceList *list = (SBBResourceList *)tasksList;
        self.tasks = list.items;
        dispatch_async(dispatch_get_main_queue(), ^{
            _tasksTableViewController.tasks = _tasks;
            [_tasksTableViewController.tableView reloadData];
        });
    }];
#pragma unused(sdtask)
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _untilDatePicker.date = [NSDate date];
    [self reloadTasks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    _tasksTableViewController = [segue destinationViewController];
    _tasksTableViewController.tasks = _tasks;
    
}

- (IBAction)didTouchLoadButton:(id)sender
{
    [self reloadTasks];
}

@end
