//
//  TaskViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 5/6/15.
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

#import "TaskViewController.h"
#import "ActivityViewController.h"
@import BridgeSDK;

@interface TaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *guidTextField;
@property (weak, nonatomic) IBOutlet UITextField *scheduledOnTextField;
@property (weak, nonatomic) IBOutlet UITextField *expiresOnTextField;
@property (weak, nonatomic) IBOutlet UITextField *startedOnTextField;
@property (weak, nonatomic) IBOutlet UITextField *finishedOnTextField;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;
@property (weak, nonatomic) IBOutlet UIView *ActivityContainer;

- (IBAction)didTouchStartButton:(id)sender;
- (IBAction)didTouchFinishButton:(id)sender;
- (IBAction)didTouchDeleteButton:(id)sender;

@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.guidTextField.text = _task.guid;
    self.scheduledOnTextField.text = [_task.scheduledOn description];
    self.expiresOnTextField.text = [_task.expiresOn description];
    self.startedOnTextField.text = [_task.startedOn description];
    self.finishedOnTextField.text = [_task.finishedOn description];
    self.statusTextField.text = _task.status;
    
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
    ActivityViewController *avc = (ActivityViewController *)[segue destinationViewController];
    avc.activity = _task.activity;
}

- (IBAction)didTouchStartButton:(id)sender {
    [SBBComponent(SBBTaskManager) startTask:_task asOf:[NSDate date] withCompletion:^(id responseObject, NSError *error) {
        NSLog(@"Start task %@ response:\n%@\nerror:\n%@", _task.guid, responseObject, error);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (IBAction)didTouchFinishButton:(id)sender {
    [SBBComponent(SBBTaskManager) finishTask:_task asOf:[NSDate date] withCompletion:^(id responseObject, NSError *error) {
        NSLog(@"Finish task %@ response:\n%@\nerror:\n%@", _task.guid, responseObject, error);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (IBAction)didTouchDeleteButton:(id)sender {
    [SBBComponent(SBBTaskManager) deleteTask:_task withCompletion:^(id responseObject, NSError *error) {
        NSLog(@"Delete task %@ response:\n%@\nerror:\n%@", _task.guid, responseObject, error);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

@end
