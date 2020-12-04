//
//  SBBUploadManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
//
//	Copyright (c) 2014, Sage Bionetworks
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

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"

typedef void (^SBBUploadManagerCompletionBlock)(NSError *error);

@class SBBUploadManager;

/*!
 This protocol defines the interface to the upload manager delegate.
 */
@protocol SBBUploadManagerDelegate <NSObject>
@required
/*!
 Required delegate method that gets called when a background file upload task finishes, successfully or otherwise.
 
 @param manager The upload manager instance making the call.
 @param file    The path to the file whose upload task finished or failed.
 @param error   If the upload task failed, this will describe the cause.
 */
- (void)uploadManager:(SBBUploadManager *)manager uploadOfFile:(NSString *)file completedWithError:(NSError *)error;

@optional
/*!
 Optional delegate method available only in debug builds.
 Called when a background file upload task finishes, successfully or otherwise in debug builds.
 Provides a URL that can be called for more information about the post-upload status of the data.
 
 @param manager The upload manager instance making the call.
 @param file    The path to the file whose upload task finished or failed.
 @param url     The url to call to get more information about the post-upload status of the data.
 */
- (void)uploadManager:(SBBUploadManager *)manager uploadOfFile:(NSString *)file completedWithVerificationURL:(NSURL *)url;

@end

/*!
 *  This protocol defines the interface to the SBBUploadManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBUploadManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Set this property to set an upload delegate to be notified when a background upload completes (or fails), even if
 it happens after the app has been relaunched. Note that if the user swipes the app out of the app switcher screen,
 all current uploads will have been canceled anyway and the uploadDelegate won't get called.
 
 To ensure that your delegate gets called, you should set this property in your AppDelegate's
 application:didFinishLaunchingWithOptions: and application:handleEventsForBackgroundURLSession:completionHandler: methods.
 */
@property (nonatomic, weak) id<SBBUploadManagerDelegate> uploadDelegate;

/*!
 Upload a file to the Bridge server on behalf of the authenticated user, via the NSURLSessionUploadTask so it can proceed
 even if the app is suspended or killed. Requesting the pre-signed URL for the upload from the Bridge API happens in a
 background download task so that the whole process can be initiated regardless of current network connectivity, and will
 proceed as and when possible.
 
 The file is copied to a temporary file with a unique name in the temporary directory, and the copy is uploaded, so the
 original can be safely deleted any time after making this call (though you may want to wait and do it in the
 uploadManager:uploadOfFile:completedWithError: method, in case the upload fails so you can try again). The temporary copy
 is deleted upon successful or unsuccessful completion of the upload attempt.
 
 @param fileUrl     The file to upload.
 @param contentType The MIME type of the file (defaults to "application/octet-stream" if nil).
 @param completion  A completion block to be called when the upload finishes (or fails). Note that this will never be called if the app has to be relaunched to respond to the background session delegate events; blocks cannot be persisted across app launches. If you need to be sure to get the call upon completion (successful or otherwise), set an uploadDelegate.
 
 @see uploadDelegate
 */
- (void)uploadFileToBridge:(NSURL *)fileUrl contentType:(NSString *)contentType completion:(SBBUploadManagerCompletionBlock)completion;

/*!
 This is a convenience method that determines the appropriate content-type based on the file extension and calls through to
 uploadFileToBridge:contentType:completion:.
 
 @see uploadFileToBridge:contentType:completion:
 */
- (void)uploadFileToBridge:(NSURL *)fileUrl completion:(SBBUploadManagerCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge file upload API.
 */
@interface SBBUploadManager : SBBBridgeAPIManager<SBBComponent, SBBUploadManagerProtocol>

@end
