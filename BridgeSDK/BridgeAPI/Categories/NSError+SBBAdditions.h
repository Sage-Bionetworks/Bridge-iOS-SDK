//
//  NSError+SBBAdditions.h
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (SBBAdditions)

/*********************************************************************************/
#pragma mark - Error Generators
/*********************************************************************************/
+ (NSError*) generateSBBErrorForNSURLError:(NSError *)urlError isInternetConnected:(BOOL)internetConnected isServerReachable:(BOOL)isServerReachable;
+ (NSError*) generateSBBErrorForStatusCode:(NSInteger)statusCode data: (NSData*) data;
+ (NSError*) SBBNoCredentialsError;
+ (NSError*) SBBNotAuthenticatedError;

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/
- (void) handle;

@end
