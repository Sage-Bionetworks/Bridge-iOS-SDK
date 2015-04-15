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

#import "SBBErrors.h"

@implementation NSError (SBBAdditions)

/*********************************************************************************/
#pragma mark - Error Generators
/*********************************************************************************/
+ (NSError *) generateSBBErrorForNSURLError:(NSError *)urlError isInternetConnected:(BOOL)internetConnected isServerReachable:(BOOL)isServerReachable
{
    NSError * retError;
    if (!internetConnected) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBInternetNotConnected userInfo:@{NSLocalizedDescriptionKey: @"Internet Not Connected", SBB_ORIGINAL_ERROR_KEY: urlError}];
    }
    else if (!isServerReachable) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBServerNotReachable userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Not Reachable",SBB_ORIGINAL_ERROR_KEY: urlError}];
    }
    else
    {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBUnknownError userInfo:@{NSLocalizedDescriptionKey: @"Unknown Network Error",SBB_ORIGINAL_ERROR_KEY: urlError}];
    }
    return retError;
}

+ (NSError*) generateSBBErrorForStatusCode:(NSInteger)statusCode
{
    return [self generateSBBErrorForStatusCode:statusCode data:nil];
}

+ (NSError*) generateSBBErrorForStatusCode:(NSInteger)statusCode data: (id) data
{
    //TODO: Get appropriate error strings
    NSError * retError;
    NSError * localError;
    id foundationObject;
    if (data) {
        if ([data isKindOfClass:[NSData class]]) {
            foundationObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&localError];
        }
        else if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]])
        {
            foundationObject = data;
        }
    }
    foundationObject = foundationObject ? : @{@"message" : [NSString stringWithFormat:@"Server Error Code: %@", @(statusCode)]};
    if (statusCode == 401) {
        retError = [self SBBNotAuthenticatedError];
    }
    else if (statusCode == 412)
    {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBServerPreconditionNotMet userInfo:@{NSLocalizedDescriptionKey: @"Client not consented", SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (NSLocationInRange(statusCode, NSMakeRange(400, 99))) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:statusCode userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Client Error: %@. Please contact customer support.", @(statusCode)],  SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (statusCode == 503) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBServerUnderMaintenance userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Under Maintenance.", SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (NSLocationInRange(statusCode, NSMakeRange(500, 99))) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:statusCode userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Backend Server Error: %@. Please contact customer support.", @(statusCode)], SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    return retError;
}

+ (NSError *)SBBNoCredentialsError
{
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBNoCredentialsAvailable userInfo:@{NSLocalizedDescriptionKey: @"No user login credentials available. Please sign in."}];
}

+ (NSError *)SBBNotAuthenticatedError
{
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBServerNotAuthenticated userInfo:@{NSLocalizedDescriptionKey: @"Server says: not authenticated. Please authenticate."}];
}

+ (NSError *)generateSBBNotAFileURLErrorForURL:(NSURL *)url
{
  NSString *desc = [NSString stringWithFormat:@"Not a valid file URL:\n%@", url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBNotAFileURL userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBTempFileErrorForURL:(NSURL *)url
{
  NSString *desc = [NSString stringWithFormat:@"Error copying file at URL to temp file:\n%@", url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBTempFileError userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBTempFileReadErrorForURL:(NSURL *)url
{
  NSString *desc = [NSString stringWithFormat:@"Error reading temp file for original file URL:\n%@", url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBTempFileError userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBObjectNotExpectedClassErrorForObject:(id)object expectedClass:(Class)expectedClass
{
  NSString *desc = [NSString stringWithFormat:@"Object '%@' is of class %@, expected class %@", object, NSStringFromClass([object class]), NSStringFromClass(expectedClass)];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBObjectNotExpectedClass userInfo:@{NSLocalizedDescriptionKey: desc}];
}

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handleSBBError
{
    NSLog(@"SBB ERROR GENERATED: %@", self);
}

@end
