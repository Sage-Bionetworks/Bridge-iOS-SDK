//
//  SBBUploadManagerInternal.h
//  BridgeSDK
//
//	Copyright (c) 2016, Sage Bionetworks
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

#import "SBBUploadManager.h"

/* CONSTANTS */
extern NSString * const kSBBUploadAPI;
extern NSString * const kSBBUploadCompleteAPIFormat;
extern NSString * const kSBBUploadStatusAPIFormat;

extern NSString * const kUploadFilesKey;
extern NSString * const kUploadRequestsKey;
extern NSString * const kUploadSessionsKey;
extern NSString * const kSBBUploadRetryAfterDelayKey;

extern NSTimeInterval kSBBDelayForRetries;

@class SBBObjectManager;

@protocol SBBUploadManagerInternalProtocol <SBBUploadManagerProtocol>

- (void)setUploadRequestJSON:(id)json forFile:(NSString *)fileURLString;
- (void)setUploadSessionJSON:(id)json forFile:(NSString *)fileURLString;
- (void)retryUploadsAfterDelay;
- (NSURL *)tempUploadDirURL;
- (NSArray<NSURL *> *)filesUnderDirectory:(NSURL *)baseDir;
- (NSURL *)tempFileForUploadFileToBridge:(NSURL *)fileUrl contentType:(NSString *)contentType completion:(SBBUploadManagerCompletionBlock)completion;
- (void)checkAndRetryOrphanedUploads;
- (void)cleanUpTempFile:(NSString *)tempFilePath;

@end

@interface SBBUploadManager () <SBBUploadManagerInternalProtocol, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) SBBObjectManager *cleanObjectManager;
@property (nonatomic, strong) NSMutableDictionary *uploadCompletionHandlers;

@end
