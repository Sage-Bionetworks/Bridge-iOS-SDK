//
//  NSError+SBBAdditions.m
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "SBBNetworkErrors.h"

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

+ (NSError*) generateSBBErrorForHTTPResponse: (NSHTTPURLResponse*) response
{
    //TODO: Get appropriate error strings
    NSError * retError;
    if (response.statusCode == 401) {
        retError = [self SBBNotAuthenticatedError];
    }
    else if (response.statusCode == 412)
    {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBServerPreconditionNotMet userInfo:@{NSLocalizedDescriptionKey: @"Client not consented"}];
    }
    else if (NSLocationInRange(response.statusCode, NSMakeRange(400, 99))) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Client Error. Please contact SOMEBODY"}];
    }
    else if (response.statusCode == 503) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBServerUnderMaintenance userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Under Maintenance."}];
    }
    else if (NSLocationInRange(response.statusCode, NSMakeRange(500, 99))) {
        retError = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Error. Please contact SOMEBODY"}];
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

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handle
{
    NSLog(@"ERROR GENERATED: %@", self);
}

@end
