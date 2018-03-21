//
//  SBBStudyManager.m
//  BridgeSDK
//
//    Copyright © 2018, Sage Bionetworks
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//        * Redistributions of source code must retain the above copyright
//          notice, this list of conditions and the following disclaimer.
//        * Redistributions in binary form must reproduce the above copyright
//          notice, this list of conditions and the following disclaimer in the
//          documentation and/or other materials provided with the distribution.
//        * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//          contributors may be used to endorse or promote products derived from
//          this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBStudyManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBObjectManager.h"
#import "SBBAuthManager.h"
#import "SBBBridgeInfo.h"
#import "BridgeSDK+Internal.h"

#define STUDY_API_FORMAT V3_API_PREFIX @"/studies/%@/appconfig"
NSString * const kSBBStudyAPIFormat =                          STUDY_API_FORMAT;

@implementation SBBStudyManager

+ (instancetype)defaultComponent
{
    static SBBStudyManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSURLSessionTask *)getAppConfigWithCompletion:(SBBStudyManagerGetCompletionBlock)completion
{
    NSString *studyId = SBBBridgeInfo.shared.studyIdentifier;
    if (!studyId.length) {
        // BridgeSDK has not yet been set up--do nothing
#if DEBUG
        NSLog(@"Attempting to get app config when BridgeSDK hasn't been set up and we don't know the study identifier yet.");
#endif
        if (completion) {
            completion(nil, nil);
        }
        return nil;
    }
    
    NSString *endpoint = [NSString stringWithFormat:kSBBStudyAPIFormat, studyId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager get:endpoint headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        id appConfig = [self.objectManager objectFromBridgeJSON:responseObject];
        
        if (completion) {
            completion(appConfig, error);
        }
    }];
}

@end
