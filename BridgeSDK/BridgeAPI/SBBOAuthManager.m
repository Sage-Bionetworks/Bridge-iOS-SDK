//
//  SBBOAuthManager.m
//  BridgeSDK
//
//	Copyright (c) 2017, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBOAuthManager.h"
#import "SBBAuthManager.h"

#define OAUTH_API V3_API_PREFIX @"/oauth"
#define OAUTH_VENDOR_API_FORMAT OAUTH_API @"/%@"

@implementation SBBOAuthManager

+ (instancetype)defaultComponent
{
    static SBBOAuthManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSURLSessionTask *)getAccessTokenForVendor:(NSString *)vendorId authCode:(NSString *)authCode completion:(id)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSString *endpoint = [NSString stringWithFormat:OAUTH_VENDOR_API_FORMAT, vendorId];
    NSDictionary *parameters = nil;
    if (authCode.length > 0) {
        parameters = @{ "authToken": authCode };
    }
    return [self.networkManager post:endpoint headers:headers parameters:parameters completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {        
        id oauth = [self.objectManager objectFromBridgeJSON:responseObject];
        if (completion) {
            completion(oauth, error);
        }
    }];
}

@end
