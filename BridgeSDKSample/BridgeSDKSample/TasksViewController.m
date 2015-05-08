//
//  TasksViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 5/8/15.
//
//	Copyright (c) 2015, Sage Bionetworks
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
