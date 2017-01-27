//
//  SBBEncryptor.h
//  BridgeSDK
//
// Copyright (c) 2015-2017 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
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
//

#import <Foundation/Foundation.h>

@interface SBBEncryptor : NSObject

/*!
 *  Encrypt data using CMS. See https://en.wikipedia.org/wiki/Cryptographic_Message_Syntax and https://tools.ietf.org/html/rfc5652 for details.
 *  Uses the .pem file whose name is given in certificateName in the SBBBridgeInfoProtocol object with which the
 *  BridgeSDK was set up initially.
 *
 *  @param url          URL of a file containing data to be encrypted.
 *  @param completion   Completion handler, called with a URL to a temporary file containing the encrypted data, and an error object or nil.
 *
 */
- (void)encryptFileAtURL:(NSURL *)url withCompletion:(void (^)(NSURL *url, NSError *error))completion;

/*!
 *  Clean up the encrypted file and the temporary directory that was created to hold it.
 */
- (void)removeDirectory;

/*!
 *  Gets a list of files awaiting response from the upload system, so we can decide which ones need to be retried.
 */
+ (NSArray<NSString *> *)encryptedFilesAwaitingUploadResponse;

/*!
 *  Delete the given encrypted file and its containing directory. Must only ever be called on files returned
 *  by encryptedFilesAwaitingUploadResponse.
 */
+ (void)cleanUpEncryptedFile:(NSURL *)file;

@end
