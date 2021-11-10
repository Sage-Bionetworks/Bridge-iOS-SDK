//
//  NSString+SBBAdditions.h
//  BridgeSDK
//
//  Created by Erin Mounts on 8/19/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UUID_REGEX_PATTERN @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"

@interface NSString (SBBAdditions)

- (NSString *)sandboxRelativePath;
- (NSString *)fullyQualifiedPath;
- (BOOL)isEquivalentToPath:(NSString *)path;

@end
