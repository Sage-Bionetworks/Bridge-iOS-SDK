//
//  DetailViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 9/9/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "DetailViewController.h"
#import <BridgeSDK/BridgeSDK.h>

@interface DetailViewController ()

@end

@implementation DetailViewController
            
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
  if (_detailItem != newDetailItem) {
      _detailItem = newDetailItem;
          
      // Update the view.
      [self configureView];
  }
}

- (void)configureView {
  // Update the user interface for the detail item.
  if (self.detailItem) {
      self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
//  } else {
//    self.detailDescriptionLabel.text = [[SBBNetworkManager new] acceptLanguageHeader];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
