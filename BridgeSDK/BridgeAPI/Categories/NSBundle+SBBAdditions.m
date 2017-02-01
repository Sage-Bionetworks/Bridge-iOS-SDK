//
//  NSBundle+SSBAdditions.m
//  BridgeSDK
//
// Copyright (c) 2015, Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NSBundle+SBBAdditions.h"

const NSString *kPrivacyPolicyUrlStringKey = @"PrivacyPolicyUrlString";

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

- (NSURL * _Nonnull)privacyPolicyURL {
    return [NSURL URLWithString:self.infoDictionary[kPrivacyPolicyUrlStringKey]];
}

- (NSString *)appName {
    return [self objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
}

- (NSString *)appVersion {
    return [self objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

@end
