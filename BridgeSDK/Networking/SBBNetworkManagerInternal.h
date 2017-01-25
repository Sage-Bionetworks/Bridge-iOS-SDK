/*
 Copyright (c) 2015, Sage Bionetworks. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SBBNetworkManager.h"

extern NSString *kAPIPrefix;

#pragma mark - Retry Object - Keeps track of retry count

@interface SBBNetworkRetryObject : NSObject

@property (nonatomic) NSInteger retryCount;
@property (nonatomic, copy) SBBNetworkManagerCompletionBlock completionBlock;
@property (nonatomic, copy) void (^retryBlock)(void);

@end

#pragma mark - SBBNetworkManager Bridge category

@interface SBBNetworkManager (Bridge)

@property (nonatomic, strong) NSURLSession * mainSession; //For data tasks
@property (nonatomic, strong) NSURLSession * backgroundSession; //For upload/download tasks

+ (NSString *)baseURLForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath;

- (instancetype)initWithBaseURL:(NSString*)baseURL bridgeStudy:(NSString*)bridgeStudy;

- (void)handleHTTPError:(NSError *)error task:(NSURLSessionTask *)task response:(id)responseObject retryObject:(SBBNetworkRetryObject *)retryObject;
- (NSDictionary *)headersPreparedForRetry:(NSDictionary *)headers;

- (NSURL *) URLForRelativeorAbsoluteURLString: (NSString*) URLString;

- (NSURLSessionTask *) doDataTask:(NSString*) method
                        URLString:(NSString*)URLString
                          headers:(NSDictionary *)headers
                       parameters:(NSDictionary *)parameters
                       background:(BOOL)background
                       completion:(SBBNetworkManagerCompletionBlock)completion;

// so these can be replaced in mock classes for testing
- (void)performBlockOnBackgroundDelegateQueue:(void (^)(void))block;
- (void)performBlockSyncOnBackgroundDelegateQueue:(void (^)(void))block;

@end
