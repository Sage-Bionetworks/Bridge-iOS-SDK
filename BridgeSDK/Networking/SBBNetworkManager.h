//
//  SBBNetworkManager.h
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Typedef for SBBNetworkManager methods' success block.
 *
 *  @param task           The NSURLSessionDataTask just successfully completed.
 *  @param responseObject The JSON object from the response.
 */
typedef void (^SBBNetworkManagerSuccessBlock)(NSURLSessionDataTask *task, id responseObject);

/**
 *  Typedef for SBBNetworkManager methods' failure block.
 *
 *  @param task  The NSURLSessionDataTask that failed to complete.
 *  @param error The error that caused the failure.
 */
typedef void (^SBBNetworkManagerFailureBlock)(NSURLSessionDataTask *task, NSError *error);

/**
 *  Typedef for SBBNetworkManager methods' completion block.
 *
 *  @param task           The NSURLSessionDataTask.
 *  @param responseObject The JSON object from the response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerCompletionBlock)(NSURLSessionDataTask *task, id responseObject, NSError *error);


@interface SBBNetworkManager : NSObject

#pragma mark - Init & Accessor Methods

- (instancetype) initWithBaseURL: (NSString*) baseURL;

- (BOOL) isInternetConnected;
- (BOOL) isServerReachable;

#pragma mark - Basic HTTP Methods

- (NSURLSessionDataTask* )get:(NSString *)URLString
                   parameters:(id)parameters //NSDictionary or Array of NSDictionary
//                      success:(SBBNetworkManagerSuccessBlock)success
//                      failure:(SBBNetworkManagerFailureBlock)failure;
                   completion:(SBBNetworkManagerCompletionBlock)completion;

- (NSURLSessionDataTask* )post:(NSString *)URLString
                   parameters:(id)parameters
//                      success:(SBBNetworkManagerSuccessBlock)success
//                      failure:(SBBNetworkManagerFailureBlock)failure;
                    completion:(SBBNetworkManagerCompletionBlock)completion;

@end