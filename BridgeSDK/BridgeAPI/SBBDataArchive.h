// 
//  SBBDataArchive.h
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

NS_ASSUME_NONNULL_BEGIN

@class ORKResult;

@interface SBBDataArchive : NSObject

@property (nonatomic, readonly) NSURL *unencryptedURL;

@property (nonatomic, readonly, nullable) NSDictionary <NSString *, NSPredicate *> *jsonValidationMapping;

- (instancetype)init NS_UNAVAILABLE;

/**
 Designated Initializer
 
 @param     reference           Reference for the archive used as a directory name in temp directory
 
 @return    APCDataArchive      An instance of APCDataArchive
 */
- (instancetype)initWithReference:(NSString *)reference
  jsonValidationMapping:(nullable NSDictionary <NSString *, NSPredicate *> *)jsonValidationMapping NS_DESIGNATED_INITIALIZER;


/**
 Add a json serializable object to the info dictionary
 
 @param     object              JSON serializable object, or object convertible to JSON by SBBObjectManager, to be added to the info dictionary
 
 @param     key                 Key for the json object to be included
 */
- (void)setArchiveInfoObject:(id)object forKey:(NSString*)key;


/**
 Converts a dictionary into json data and inserts into the archive.
 
 @param     dictionary              Dictionary to be inserted into the zip archive.
 
 @param     filename                Filename for the json data to be included without path extension
 
 @param     createdOn               File creation timestamp to use in info.json
 */
- (void)insertDictionaryIntoArchive:(NSDictionary *)dictionary filename:(NSString *)filename createdOn:(NSDate *)createdOn;


/**
 Inserts the data from the file at the url.
 
 @param     url                     URL where the file exists. The original file's creation date will be used as the creation timestamp in info.json
 
 @param     filename                Filename for the json data to be included without path extension (path extension will be preserved from the url).
 */
- (void)insertURLIntoArchive:(NSURL*)url fileName:(NSString *)filename;

/**
 Inserts the data with the filename and path extension
 
 @param     data                    Data to add to archive
 
 @param     filename                Filename for the data to be included (path extension assumed to be json if excluded)
 
 @param     createdOn               File creation timestamp to use in info.json
 */
- (void)insertDataIntoArchive:(NSData *)data filename:(NSString *)filename createdOn:(NSDate *)createdOn;

/**
 Checks if the archive is empty (contains no files).
 
 @return false if the archive contains one or more files, true if not.
 */
- (BOOL)isEmpty;

/**
 Inserts an info.json file into the archive.
 
 @param error will be pointed at an actual NSError object if there was a problem completing the archive, or nil.
 
 @return YES if succeeds, NO if fails.
 */
- (BOOL)completeArchive:(NSError * _Nullable *)error;

/**
 Completes the archive, encrypts it, and uploads it to Bridge, then removes the archive.
 */
- (void)encryptAndUploadArchive;

/**
 Completes each archive, encrypts it, and uploads it to Bridge, then removes the archive.
 
 @param     archives                The data archives to be encrypted and sent
 */
+ (void)encryptAndUploadArchives:(NSArray<SBBDataArchive *> *) archives;

/**
 Guarantees to delete the archive and its working directory container.
 Call this method when you are finished with the archive, for example after encrypting or uploading.
 */
- (void) removeArchive;

#pragma mark deprecated

- (void)insertDictionaryIntoArchive:(NSDictionary *)dictionary filename:(NSString *)filename __attribute__((deprecated("Use insertDictionaryIntoArchive:filename:createdOn: instead.")));

- (void)insertDataIntoArchive :(NSData *)data filename:(NSString *)filename __attribute__((deprecated("Use insertDataIntoArchive:filename:createdOn: instead.")));

@end

NS_ASSUME_NONNULL_END
