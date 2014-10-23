//
//  DetailViewController.h
//  BridgeSDKSample
//
//  Created by Erin Mounts on 9/9/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

