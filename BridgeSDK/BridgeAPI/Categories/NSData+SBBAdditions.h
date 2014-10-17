//
//  NSData+SBBAdditions.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/10/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SBBAdditions)

- (NSData *)gzipDeflate;

- (NSString*)contentMD5;

@end
