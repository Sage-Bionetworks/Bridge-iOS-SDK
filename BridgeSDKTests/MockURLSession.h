//
//  MockURLSession.h
//  BridgeSDK
//
//  Created by Erin Mounts on 5/29/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MockURLSession : NSURLSession

@property (nonatomic, weak) id<NSURLSessionDelegate> mockDelegate;

@property (nonatomic, strong) NSMutableDictionary *jsonForEndpoints;
@property (nonatomic, strong) NSMutableDictionary *codesForEndpoints;
@property (nonatomic, strong) NSMutableDictionary *URLSForEndpoints;
@property (nonatomic, strong) NSMutableDictionary *errorsForEndpoints;

- (void)setJson:(id)jsonObject andResponseCode:(NSInteger)statusCode forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod;
- (void)setDownloadFileURL:(NSURL *)fileURL andError:(NSError *)error forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod;
- (void)doSyncInDelegateQueue:(dispatch_block_t)block;

@end
