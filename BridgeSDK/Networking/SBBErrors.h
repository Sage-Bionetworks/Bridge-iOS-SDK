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

#import <Foundation/Foundation.h>

//Error Codes
#define SBB_ERROR_DOMAIN @"org.sagebase.error_domain"
#define SBB_ORIGINAL_ERROR_KEY @"SBBOriginalErrorKey"

typedef NS_ENUM(NSInteger, SBBErrorCode)
{
    SBBErrorCodeUnknownError = -1,
    SBBErrorCodeInternetNotConnected = -1000,
    SBBErrorCodeServerNotReachable = -1001,
    SBBErrorCodeServerUnderMaintenance = -1002,
    SBBErrorCodeServerNotAuthenticated = -1003,
    SBBErrorCodeServerPreconditionNotMet = -1004,
    SBBErrorCodeNoCredentialsAvailable = -1005,
    SBBErrorCodeUnsupportedAppVersion = -1006,
    
    SBBErrorCodeS3UploadErrorResponse = -1020,
    
    SBBErrorCodeNotAFileURL = -1100,
    SBBErrorCodeObjectNotExpectedClass = -1101,
    SBBErrorCodeTempFileError = -1102,
    SBBErrorCodeTempFileReadError = -1103,
    
    SBBErrorCodeNotAValidSurveyRef = -1200,
    SBBErrorCodeNotAValidJSONObject = -1201
};


typedef NS_ENUM(NSInteger, SBBErrorCodes) /** DEPRECATED */
{
    kSBBUnknownError = -1,
    kSBBInternetNotConnected = -1000,
    kSBBServerNotReachable = -1001,
    kSBBServerUnderMaintenance = -1002,
    kSBBServerNotAuthenticated = -1003,
    kSBBServerPreconditionNotMet = -1004,
    kSBBNoCredentialsAvailable = -1005,
    kSBBUnsupportedAppVersion = -1006,
    
    kSBBS3UploadErrorResponse = -1020,
  
    kSBBNotAFileURL = -1100,
    kSBBObjectNotExpectedClass = -1101,
    kSBBTempFileError = -1102,
    kSBBTempFileReadError = -1103
}
/**
 * This enum is deprecated. Use <SBBErrorCode> instead which is formatted for compliance with Swift 2.0 enums.
 * @deprecated v3.0.6
 */
__attribute__((deprecated("use SBBErrorCode")));


