//
//  SchedulesTableViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 10/27/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SchedulesTableViewController.h"
#import "ScheduleViewController.h"
#import <BridgeSDK/BridgeSDK.h>

@interface SchedulesTableViewController ()

@property (nonatomic, strong) NSArray *schedules;

- (IBAction)didTouchReloadButton:(id)sender;

@end

@implementation SchedulesTableViewController

- (void)reloadSchedules
{
    NSURLSessionDataTask *task = [SBBComponent(SBBScheduleManager) getSchedulesWithCompletion:^(id schedulesList, NSError *error) {
        SBBResourceList *list = (SBBResourceList *)schedulesList;
        self.schedules = list.items;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self reloadSchedules];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.schedules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scheduleCell" forIndexPath:indexPath];
    
    // Configure the cell...
    SBBSchedule *schedule = [self.schedules objectAtIndex:indexPath.row];
    cell.textLabel.text = schedule.scheduleType;
    NSString *detailText = schedule.cronTrigger;
    if ([schedule.scheduleType isEqualToString:@"once"]) {
        detailText = [schedule.startsOn description];
    }
    cell.detailTextLabel.text = detailText ? detailText : @"";
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ScheduleViewController *svc = (ScheduleViewController *)[segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    svc.schedule = self.schedules[indexPath.row];
}

- (IBAction)didTouchReloadButton:(id)sender {
    [self reloadSchedules];
}

@end
