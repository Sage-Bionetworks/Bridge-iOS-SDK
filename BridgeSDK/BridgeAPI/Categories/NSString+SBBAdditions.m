//
//  NSString+SBBAdditions.m
//  BridgeSDK
//
//  Created by Erin Mounts on 8/19/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "NSString+SBBAdditions.h"

@implementation NSString (SBBAdditions)


- (NSRegularExpression *)sandboxRegex
{
    static NSRegularExpression *regex = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *sandboxPath = NSHomeDirectory();
        
        // simulator and device have the app uuid in a different location in the path,
        // and it might change in the future, so:
        NSRegularExpression *findUUIDRegex = [NSRegularExpression regularExpressionWithPattern:UUID_REGEX_PATTERN options:0 error:nil];
        NSRange rangeOfUUID = [findUUIDRegex rangeOfFirstMatchInString:sandboxPath options:0 range:NSMakeRange(0, sandboxPath.length)];
        NSString *beforeUUID = [sandboxPath substringToIndex:rangeOfUUID.location];
        NSString *afterUUID = [sandboxPath substringFromIndex:rangeOfUUID.location + rangeOfUUID.length];
        NSString *regexPattern = @"^";
        NSString *quotedFormat = @"\\Q%@\\E";
        if (beforeUUID.length) {
            regexPattern = [regexPattern stringByAppendingFormat:quotedFormat, beforeUUID];
        }
        regexPattern = [regexPattern stringByAppendingString:UUID_REGEX_PATTERN];
        if (afterUUID.length) {
            regexPattern = [regexPattern stringByAppendingFormat:quotedFormat, afterUUID];
        }
        regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:nil];
    });
    
    return regex;
}

- (NSString *)sandboxRelativePath
{
    NSRange range = [[self sandboxRegex] rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    NSString *sandboxRelativePath = [self substringFromIndex:range.length]; // if it doesn't match the sandbox regex, this will give back self
    
    return sandboxRelativePath;
}

- (NSString *)fullyQualifiedPath
{
    // first see if it's already a full path
    NSRange range = [[self sandboxRegex] rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    if (range.location != NSNotFound) {
        return self;
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:self];
}

- (BOOL)isEquivalentToPath:(NSString *)path
{
    // strip off the "sandbox" prefix to the paths before comparing, because the UUID part changes from one run to the next.
    // note that this will match a path where we've already stripped of the sandbox part to an equivalent one where we haven't.
    NSString *relevantPath1 = [self sandboxRelativePath]; // if it doesn't match the sandbox regex, this will give back self
    NSString *relevantPath2 = [path sandboxRelativePath]; // if it doesn't match the sandbox regex, this will give back path
    
    return [relevantPath1 isEqualToString:relevantPath2];
}

@end
