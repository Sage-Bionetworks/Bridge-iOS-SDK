//
//  SBBBridgeObject.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeObject.h"

@interface SBBBridgeObject ()

@end

@implementation SBBBridgeObject

- (id)init
{
  if (self = [super init]) {
    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"SBB"]) {
      // set default type string
      self.type = [className substringFromIndex:3];
    }
  }
  
  return self;
}

@end
