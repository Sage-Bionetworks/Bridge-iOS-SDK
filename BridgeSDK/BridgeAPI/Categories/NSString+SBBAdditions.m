//
//  NSString+SBBAdditions.m
//  BridgeSDK
//
//  Created by Erin Mounts on 8/19/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "NSString+SBBAdditions.h"
#import "SBBBridgeInfo.h"

@implementation NSString (SBBAdditions)

- (NSString *)baseDirectory
{
    static NSString *baseDirectory;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *appGroupIdentifier = SBBBridgeInfo.shared.appGroupIdentifier;
        if (appGroupIdentifier.length > 0) {
            NSURL *baseDirURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupIdentifier];
            // normalize the path--i.e. /private/var-->/var (see docs for URLByResolvingSymlinksInPath, which removes /private as a special case
            // even though /var is actually a symlink to /private/var in this case)
            baseDirectory = [baseDirURL URLByResolvingSymlinksInPath].path;
        } else {
            baseDirectory = NSHomeDirectory();
        }
    });
    
    return baseDirectory;
}

- (NSRegularExpression *)sandboxRegex
{
    static NSRegularExpression *regex = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *sandboxPath = self.baseDirectory;
        
        // simulator and device have the app uuid in a different location in the path,
        // and it might change in the future, so:
        NSRegularExpression *findUUIDRegex = [NSRegularExpression regularExpressionWithPattern:UUID_REGEX_PATTERN options:0 error:nil];
        NSArray<NSTextCheckingResult *> *UUIDmatches = [findUUIDRegex matchesInString:sandboxPath options:0 range:NSMakeRange(0, sandboxPath.length)];
        NSRange rangeOfLastUUID = [UUIDmatches lastObject].range;
        NSString *beforeUUID = [sandboxPath substringToIndex:rangeOfLastUUID.location];
        NSString *afterUUID = [sandboxPath substringFromIndex:rangeOfLastUUID.location + rangeOfLastUUID.length];
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
    // normalize the path--i.e. /private/var-->/var (see docs for URLByResolvingSymlinksInPath, which removes /private as a special case
    // even though /var is actually a symlink to /private/var in this case)
    NSString *normalizedSelf = [[NSURL fileURLWithPath:self] URLByResolvingSymlinksInPath].path;
    NSRange range = [[self sandboxRegex] rangeOfFirstMatchInString:normalizedSelf options:0 range:NSMakeRange(0, normalizedSelf.length)];
    NSString *sandboxRelativePath = [normalizedSelf substringFromIndex:range.length]; // if it doesn't match the sandbox regex, this will give back normalizedSelf
    
    return sandboxRelativePath;
}

- (NSString *)fullyQualifiedPath
{
    // normalize the path--i.e. /private/var-->/var (see docs for URLByResolvingSymlinksInPath, which removes /private as a special case
    // even though /var is actually a symlink to /private/var in this case)
    NSString *normalizedSelf = [[NSURL fileURLWithPath:self] URLByResolvingSymlinksInPath].path;
    
    // first see if it's already a full path
    NSRange range = [[self sandboxRegex] rangeOfFirstMatchInString:normalizedSelf options:0 range:NSMakeRange(0, normalizedSelf.length)];
    if (range.location != NSNotFound) {
        return normalizedSelf;
    }
    return [self.baseDirectory stringByAppendingPathComponent:self];
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
