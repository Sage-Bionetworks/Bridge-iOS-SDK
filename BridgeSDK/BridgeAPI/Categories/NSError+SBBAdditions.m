//
//  NSError+SBBAdditions.m
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

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
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:statusCode userInfo:@{NSLocalizedDescriptionKey: @"Client Error. Please contact SOMEBODY",  SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (statusCode == 503) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBServerUnderMaintenance userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Under Maintenance.", SBB_ORIGINAL_ERROR_KEY: foundationObject}];
    }
    else if (NSLocationInRange(statusCode, NSMakeRange(500, 99))) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:statusCode userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Error. Please contact SOMEBODY", SBB_ORIGINAL_ERROR_KEY: foundationObject}];
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
