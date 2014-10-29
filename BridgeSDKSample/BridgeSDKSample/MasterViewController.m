//
//  MasterViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 9/9/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SignUpSignInViewController.h"
#import "UserProfileViewController.h"
#import "SurveyViewController.h"
#import "SchedulesTableViewController.h"
#import <BridgeSDK/BridgeSDK.h>

@interface MasterViewController () <UIActionSheetDelegate>

@end

@implementation MasterViewController
            
- (void)awakeFromNib {
  [super awakeFromNib];
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.clearsSelectionOnViewWillAppear = NO;
      self.preferredContentSize = CGSizeMake(320.0, 600.0);
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;

//  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//  self.navigationItem.rightBarButtonItem = addButton;
  self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
//  self.navigationItem.title = [[SBBNetworkManager new] acceptLanguageHeader];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
  NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
  NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
  NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
      
  // If appropriate, configure the new managed object.
  // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
  [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
      
  // Save the context.
  NSError *error = nil;
  if (![context save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
  }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
      DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
      [controller setDetailItem:object];
      controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
      controller.navigationItem.leftItemsSupplementBackButton = YES;
  }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
      NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
      [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
          
      NSError *error = nil;
      if (![context save:&error]) {
          // Replace this implementation with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
          abort();
      }
  }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (IBAction)didTouchMoreBarButtonitem:(id)sender {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do what?"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Sign Up/Sign In", @"Sign Up/Sign In"),
                                NSLocalizedString(@"Sign Out", @"Sign Out"),
                                NSLocalizedString(@"Profile & Consent", @"Profile & Consent"),
                                NSLocalizedString(@"Survey", @"Survey"),
                                NSLocalizedString(@"Upload", @"Upload"),
                                NSLocalizedString(@"Schedule", @"Schedule"),
                                nil];
  [actionSheet showFromBarButtonItem:self.moreBarButtonItem animated:YES];
}

typedef NS_ENUM(NSInteger, _ActionButtons) {
  asCancel = -1,
  asSignUpSignIn,
  asSignOut,
  asProfileConsent,
  asSurvey,
  asUpload,
  asSchedule
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
      SignUpSignInViewController *suvc = [sus instantiateInitialViewController];
      [self.navigationController pushViewController:suvc animated:YES];
    }
      break;
      
    case asSignOut:
    {
      [SBBComponent(SBBAuthManager) signOutWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        UIStoryboard *sus = [UIStoryboard storyboardWithName:@"SignUpSignIn" bundle:nil];
        SignUpSignInViewController *suvc = [sus instantiateInitialViewController];
        [self.navigationController pushViewController:suvc animated:YES];
      }];
    }
      break;
      
    case asProfileConsent:
    {
      UIStoryboard *ups = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
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
      
    default:
      break;
  }
}

@end
