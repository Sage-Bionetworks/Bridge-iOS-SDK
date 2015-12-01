//
//  NSBundle+SSBAdditions.m
//  BridgeSDK
//
//  Created by Shannon Young on 11/23/15.
//  Copyright © 2015 Sage Bionetworks. All rights reserved.
//

#import "NSBundle+SBBAdditions.h"

@implementation NSBundle (SBBAdditions)

- (NSURL * _Nonnull)appStoreLinkURL
{
    // See https://developer.apple.com/library/ios/qa/qa1633/_index.html
    // To create an App Store Short Link, apply the following rules to your company or app name:
    
    // Convert all characters to lower-case
    __block NSString *appName = self.infoDictionary[(NSString*)kCFBundleNameKey];
    
    void (^replace)(NSString*, NSString*) = ^ (NSString * regexChars, NSString *replacement) {
        NSError *error = nil;
        NSString *pattern = [NSString stringWithFormat:@"[%@]+",regexChars];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        appName = [regex stringByReplacingMatchesInString:appName options:0 range:NSMakeRange(0, [appName length]) withTemplate:replacement];
    };
    
    // Convert all characters to lower-case
    appName = [appName lowercaseString];

    // Remove all whitespace
    replace(@"\\s", @"");
    
    // Remove all copyright (©), trademark (™) and registered mark (®) symbols
    replace(@"©™®", @"");
    
    // Remove most punctuation !¡"#$%'()*+,\-./:;<=>¿?@[\]^_`{|}~
    replace(@"!¡#%'’,.:;<=>¿@_`{}~\"\\|\\$\\[\\]\\^\\?\\/\\-\\(\\)\\*\\+\\\\", @"");

    // Replace ampersands ("&") with "and"
    replace(@"&", @"and");
    
    // Replace accented and other "decorated" characters (ü, å, etc.) with their elemental character (u, a, etc.)
    replace(@"âàåãä", @"a");
    replace(@"ç", @"c");
    replace(@"éêèë", @"e");
    replace(@"óôòõö", @"o");
    replace(@"š", @"s");
    replace(@"ß", @"b");
    replace(@"úûùü", @"u");
    replace(@"ýÿ", @"y");
    replace(@"ž", @"z");
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://appstore.com/%@", appName]];
}

@end
