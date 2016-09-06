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
#import "BridgeSDK.h"

@implementation NSError (SBBAdditions)

/*********************************************************************************/
#pragma mark - Error Generators
/*********************************************************************************/
+ (NSError *) generateSBBErrorForNSURLError:(NSError *)urlError isInternetConnected:(BOOL)internetConnected isServerReachable:(BOOL)isServerReachable
{
    NSError * retError;
    if (!internetConnected) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeInternetNotConnected
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringWithDefaultValue(@"SBB_ERROR_NO_INTERNET", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Internet Not Connected",
                                                                                           @"Error Description: Internet not connected"),
                                              SBB_ORIGINAL_ERROR_KEY: urlError}];
    }
    else if (!isServerReachable) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerNotReachable
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringWithDefaultValue(@"SBB_ERROR_INTERNET_UNREACHABLE", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Backend Server Not Reachable",
                                                                                           @"Error Description: Server not reachable"),
                                              SBB_ORIGINAL_ERROR_KEY: urlError}];
    }
    else
    {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeUnknownError
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringWithDefaultValue(@"SBB_ERROR_UNKNOWN_NETWORK_ERROR", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Unknown Network Error",
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
        retError = [self SBBUnsupportedAppVersionErrorWithObject:foundationObject];
    }
    else if (statusCode == 412)
    {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerPreconditionNotMet
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringWithDefaultValue(@"SBB_ERROR_ACCOUNT_NOT_CONSENTED", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Not consented",
                                                                                           @"Error Description: Account holder has not consented to the study"),
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (NSLocationInRange(statusCode, NSMakeRange(400, 99))) {
        NSString *localizedFormat = NSLocalizedStringWithDefaultValue(@"SBB_ERROR_4XX_CONTACT_SUPPORT", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Client Error: %@. Please contact customer support.",
                                                      @"Error Description: Unknown client app error");
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:statusCode
                                   userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:localizedFormat, @(statusCode)],
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (statusCode == 503) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerUnderMaintenance
                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringWithDefaultValue(@"SBB_ERROR_SERVER_MAINTENANCE", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Backend Server Under Maintenance.",
                                                                                           @"Error Description: Backend Server Under Maintenance"),
                                              SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (NSLocationInRange(statusCode, NSMakeRange(500, 99))) {
        NSString *localizedFormat = NSLocalizedStringWithDefaultValue(@"SBB_ERROR_SERVER_ERROR", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Backend Server Error: %@. Please contact customer support.",
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
                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringWithDefaultValue(@"SBB_ERROR_NO_CREDENTIALS", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"No user login credentials available. Please sign in.",
                                                                                 @"Error Description: missing login credentials")}];
}

+ (NSError *)SBBNotAuthenticatedError
{
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeServerNotAuthenticated
                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringWithDefaultValue(@"SBB_ERROR_NOT_AUTHENTICATED", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Server says: not authenticated. Please authenticate.",
                                                                                 @"Error Description: not authenticated")}];
}

+ (NSError *)SBBUnsupportedAppVersionError
{
    return [self SBBUnsupportedAppVersionErrorWithObject:nil];
}

+ (NSError *)SBBUnsupportedAppVersionErrorWithObject:(id _Nullable)foundationObject
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *appName = [[[NSBundle mainBundle] localizedInfoDictionary]
                         objectForKey:@"CFBundleDisplayName"] ?:
    [mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = NSBundle.mainBundle.appVersion;
    NSString *appVersion = [NSString stringWithFormat: @"version %@.%@", version, build];
    
    NSString *localizedFormat = NSLocalizedStringWithDefaultValue(@"SBB_ERROR_UNSUPPORTED_APP_VERSION", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Version %1$@ of %2$@ is no longer supported. Please visit the app store to update your app.", @"Error Description: App {version} of {app name} requires upgrade");
    
    userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:localizedFormat, appVersion, appName];
    if (foundationObject != nil) {
        userInfo[SBB_ORIGINAL_ERROR_KEY] = foundationObject;
    }
    
    return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeUnsupportedAppVersion userInfo:userInfo];
}

+ (NSError *)generateSBBNotAFileURLErrorForURL:(NSURL *)url
{
  NSString *localizedFormat = NSLocalizedStringWithDefaultValue(@"SBB_ERROR_INVALID_FILE_URL", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Not a valid file URL:\n%@", @"Error Description: not a valid url");
  NSString *desc = [NSString stringWithFormat:localizedFormat, url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeNotAFileURL
                         userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBTempFileErrorForURL:(NSURL *)url
{
  NSString *localizedFormat = NSLocalizedStringWithDefaultValue(@"SBB_ERROR_COPYING_FILE", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Error copying file at URL to temp file:\n%@", @"Error Description: error copying file");
  NSString *desc = [NSString stringWithFormat:localizedFormat, url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeTempFileError userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBTempFileReadErrorForURL:(NSURL *)url
{
  NSString *localizedFormat = NSLocalizedStringWithDefaultValue(@"SBB_ERROR_READING_TEMP_FILE", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Error reading temp file for original file URL:\n%@", @"Error Description: error reading temp file");
  NSString *desc = [NSString stringWithFormat:localizedFormat, url];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeTempFileError userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (NSError *)generateSBBObjectNotExpectedClassErrorForObject:(id)object expectedClass:(Class)expectedClass
{
  NSString *localizedFormat = NSLocalizedStringWithDefaultValue(@"SBB_ERROR_UNEXPECTED_CLASS", @"BridgeSDK", [NSBundle bundleForClass:[BridgeSDK class]], @"Object '%1$@' is of class %2$@, expected class %3$@",
                                                @"Error Description: Object is not of expected class. object description=$1, actual class=$2, expected class=$3");
  NSString *desc = [NSString stringWithFormat:localizedFormat, object, NSStringFromClass([object class]), NSStringFromClass(expectedClass)];
  return [NSError errorWithDomain:SBB_ERROR_DOMAIN code:SBBErrorCodeObjectNotExpectedClass userInfo:@{NSLocalizedDescriptionKey: desc}];
}


/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handleSBBError
{
#if DEBUG
    NSLog(@"SBB ERROR GENERATED: %@", self);
#endif
}

@end
