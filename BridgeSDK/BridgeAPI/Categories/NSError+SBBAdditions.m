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
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeInternetNotConnected
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Internet Not Connected",
                                                                                           @"Error Description: Internet not connected"),
                                              SBB_ORIGINAL_ERROR_KEY: urlError}];
    }
    else if (!isServerReachable) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerNotReachable
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Backend Server Not Reachable",
                                                                                           @"Error Description: Server not reachable"),
                                              SBB_ORIGINAL_ERROR_KEY: urlError}];
    }
    else
    {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeUnknownError
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown Network Error",
                                                                                           @"Error Description: Unknown network error"),
                                              SBB_ORIGINAL_ERROR_KEY: urlError}];
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
    else if (statusCode == 410)
    {
        NSString *localizedDescription = NSLocalizedString(@"Your version of this app is no longer supported. Please visit the app store to update your app.",
                                                           @"Error Description: App requires upgrade");
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeUnsupportedAppVersion
                                   userInfo:@{NSLocalizedDescriptionKey: localizedDescription,
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (statusCode == 412)
    {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerPreconditionNotMet
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Client not consented",
                                                                                           @"Error Description: Client not consented"),
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (NSLocationInRange(statusCode, NSMakeRange(400, 99))) {
        NSString *localizedFormat = NSLocalizedString(@"Client Error: %@. Please contact customer support.",
                                                      @"Error Description: Unknown client app error");
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:statusCode
                                   userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:localizedFormat, @(statusCode)],
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (statusCode == 503) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerUnderMaintenance
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Backend Server Under Maintenance.",
                                                                                           @"Error Description: Backend Server Under Maintenance"),
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (NSLocationInRange(statusCode, NSMakeRange(500, 99))) {
        NSString *localizedFormat = NSLocalizedString(@"Backend Server Error: %@. Please contact customer support.",
                                                      @"Error Description: Unknown server error");
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:statusCode
                                   userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:localizedFormat, @(statusCode)],
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    return retError;
}

+ (NSError *)SBBNoCredentialsError
{
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeNoCredentialsAvailable
                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"No user login credentials available. Please sign in.",
                                                                                 @"Error Description: missing login credentials")}];
}

+ (NSError *)SBBNotAuthenticatedError
{
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerNotAuthenticated
                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Server says: not authenticated. Please authenticate.",
                                                                                 @"Error Description: not authenticated")}];
}

+ (NSError *)generateSBBNotAFileURLErrorForURL:(NSURL *)url
{
  NSString *localizedFormat = NSLocalizedString(@"Not a valid file URL:\n%@", @"Error Description: not a valid url");
  NSString *desc = [NSString stringWithFormat:localizedFormat, url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeNotAFileURL
                         userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBTempFileErrorForURL:(NSURL *)url
{
  NSString *localizedFormat = NSLocalizedString(@"Error copying file at URL to temp file:\n%@", @"Error Description: error copying file");
  NSString *desc = [NSString stringWithFormat:localizedFormat, url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeTempFileError userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBTempFileReadErrorForURL:(NSURL *)url
{
  NSString *localizedFormat = NSLocalizedString(@"Error reading temp file for original file URL:\n%@", @"Error Description: error reading temp file");
  NSString *desc = [NSString stringWithFormat:localizedFormat, url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeTempFileError userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBObjectNotExpectedClassErrorForObject:(id)object expectedClass:(Class)expectedClass
{
  NSString *localizedFormat = NSLocalizedString(@"Object '%1$@' is of class %2$@, expected class %3$@",
                                                @"Error Description: Object is not of expected class. object description=$1, actual class=$2, expected class=$3");
  NSString *desc = [NSString stringWithFormat:localizedFormat, object, NSStringFromClass([object class]), NSStringFromClass(expectedClass)];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeObjectNotExpectedClass userInfo:@{NSLocalizedDescriptionKey: desc}];
}

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handleSBBError
{
    NSLog(@"SBB ERROR GENERATED: %@", self);
}

@end
