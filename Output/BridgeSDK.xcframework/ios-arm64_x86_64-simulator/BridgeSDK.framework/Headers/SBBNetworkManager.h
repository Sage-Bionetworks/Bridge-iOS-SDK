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
#import <UIKit/UIKit.h>
#import <BridgeSDK/SBBComponent.h>

/*!
 Session identifier for the Bridge SDK's background session.
 */
extern NSString * kBackgroundSessionIdentifier;

/*!
 *  Typedef for SBBNetworkManager data and download methods' completion block.
 *
 *  @param task           The NSURLSessionTask.
 *  @param responseObject The JSON object from the response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerCompletionBlock)(NSURLSessionTask *task, id responseObject, NSError *error);

/*!
 *  Typedef for SBBNetworkManager task completion block.
 *
 *  @param task           The NSURLSessionTask.
 *  @param response       The HTTP response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerTaskCompletionBlock)(NSURLSessionTask *task, NSHTTPURLResponse *response, NSError *error);

/*!
 Typedef for SBBNetworkManager background download completion block.
 
 @param file The temporary file to which the downloaded data was saved. The completion block must either open this file for reading or copy it locally before returning.
 */
typedef void (^SBBNetworkManagerDownloadCompletionBlock)(NSURL *file);

/*!
 * @typedef SBBEnvironment
 * @brief An enumeration of the available server environments.
 * @constant SBBEnvironmentProd The production environment.
 * @constant SBBEnvironmentStaging The staging environment, used for testing before releasing to production.
 * @constant SBBEnvironmentDev The development environment, for Sage Bionetworks internal use only.
 * @constant SBBEnvironmentCustom A custom environment for testing purposes.
 */
typedef NS_ENUM(NSInteger, SBBEnvironment) {
    SBBEnvironmentProd,
    SBBEnvironmentStaging,
    SBBEnvironmentDev,
    SBBEnvironmentCustom
};

/*!
 This protocol defines the interface to the SBBNetworkManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBNetworkManagerProtocol <NSObject>

@property (nonatomic) SBBEnvironment environment;

@property (nonatomic, weak) id<NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> backgroundTransferDelegate;

/*!
 This property tells the network manager whether it should send cookies with its requests.
 
 For network managers communicating with Bridge servers, this should be set to NO. Otherwise defaults to YES.
 */
@property (nonatomic, assign) BOOL sendCookies;

#pragma mark - Basic HTTP Methods

/*!
 *  Perform an HTTP GET with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the query portion of the request.
 *  @param background A BOOL flag indicating whether the request should be performed as a background download.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)get:(NSString *)URLString
                  headers:(NSDictionary *)headers
               parameters:(id)parameters
               background:(BOOL)background
               completion:(SBBNetworkManagerCompletionBlock)completion;

/**
 This is a convenience method that assumes a default value of NO for background.
 */
- (NSURLSessionTask *)get:(NSString *)URLString
                  headers:(NSDictionary *)headers
               parameters:(id)parameters
               completion:(SBBNetworkManagerCompletionBlock)completion;

/*!
 *  Perform an HTTP POST with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the request body as JSON. May be nil.
 *  @param background A BOOL flag indicating whether the request should be performed as a background download.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)post:(NSString *)URLString
                   headers:(NSDictionary *)headers
                parameters:(id)parameters
                background:(BOOL)background
                completion:(SBBNetworkManagerCompletionBlock)completion;

/**
 This is a convenience method that assumes a default value of NO for background.
 */
- (NSURLSessionTask *)post:(NSString *)URLString
                   headers:(NSDictionary *)headers
                parameters:(id)parameters
                completion:(SBBNetworkManagerCompletionBlock)completion;

/*!
 *  Perform an HTTP PUT with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the request body as JSON. May be nil.
 *  @param background A BOOL flag indicating whether the request should be performed as a background download.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)put:(NSString *)URLString
                  headers:(NSDictionary *)headers
               parameters:(id)parameters
               background:(BOOL)background
               completion:(SBBNetworkManagerCompletionBlock)completion;

/**
 This is a convenience method that assumes a default value of NO for background.
 */
- (NSURLSessionTask *)put:(NSString *)URLString
                  headers:(NSDictionary *)headers
               parameters:(id)parameters
               completion:(SBBNetworkManagerCompletionBlock)completion;

#ifdef __cplusplus
// delete is a C++ keyword
- (NSURLSessionTask *)delete_:(NSString *)URLString
                      headers:(NSDictionary *)headers
                   parameters:(id)parameters
                   background:(BOOL)background
                   completion:(SBBNetworkManagerCompletionBlock)completion;

- (NSURLSessionTask *)delete_:(NSString *)URLString
                      headers:(NSDictionary *)headers
                   parameters:(id)parameters
                   completion:(SBBNetworkManagerCompletionBlock)completion;
#else
/*!
 *  Perform an HTTP DELETE with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @note Since delete is a C++ keyword, when calling this method from Objective-C++ you must use the selector delete_:headers:parameters:background:completion: instead of delete:headers:parameters:background:completion:.
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the request body as JSON. Usually for a DELETE this will be nil.
 *  @param background A BOOL flag indicating whether the request should be performed as a background download.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)delete:(NSString *)URLString
                     headers:(NSDictionary *)headers
                  parameters:(id)parameters
                  background:(BOOL)background
                  completion:(SBBNetworkManagerCompletionBlock)completion;

/**
 This is a convenience method that assumes a default value of NO for background.
 
 @note Since delete is a C++ keyword, when calling this method from Objective-C++ you must use the selector delete_:headers:parameters:completion: instead of delete:headers:parameters:completion:.
 */
- (NSURLSessionTask *)delete:(NSString *)URLString
                     headers:(NSDictionary *)headers
                  parameters:(id)parameters
                  completion:(SBBNetworkManagerCompletionBlock)completion;
#endif

/*!
 Perform a background upload of a file to a given URL with provided HTTP headers.
 
 @param fileUrl     The URL of the file to be uploaded.
 @param headers     An NSDictionary containing the HTTP headers as key-value pairs.
 @param urlString   The URL (as a string) to which to upload the file.
 @param description A string to associate with this task.
 @param completion  SBBNetworkManagerTaskCompletionBlock to be called upon completion of the upload.
 
 @return The NSURLSessionUploadTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionUploadTask *)uploadFile:(NSURL *)fileUrl httpHeaders:(NSDictionary *)headers toUrl:(NSString *)urlString taskDescription:(NSString *)description completion:(SBBNetworkManagerTaskCompletionBlock)completion;

/*!
 Perform a background download of a file from a given URL with provided method, headers, and parameters.
 
 @param urlString          The URL from which to download the file. If relative, the base URL will be prepended.
 @param httpMethod         The HTTP method to use for the request (e.g., GET, POST).
 @param headers            HTTP headers for the request. To these will be added User-Agent, Accept-Language, and (if not specified) Content-Type will be set to application/json.
 @param parameters         Query parameters for a GET, or body parameters for a POST.
 @param description        A string to associate with this task.
 @param downloadCompletion SBBNetworkManagerDownloadCompletionBlock to be called upon successful download, with the URL of the file to which the downloaded data was saved.
 @param taskCompletion     SBBNetworkManagerTaskCompletionBlock to be called upon unsuccessful completion.
 
 @return The NSURLSessionDownloadTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDownloadTask *)downloadFileFromURLString:(NSString *)urlString method:(NSString *)httpMethod httpHeaders:(NSDictionary *)headers parameters:(NSDictionary *)parameters taskDescription:(NSString *)description downloadCompletion:(SBBNetworkManagerDownloadCompletionBlock)downloadCompletion taskCompletion:(SBBNetworkManagerTaskCompletionBlock)taskCompletion;

/*!
 This method should be called from your app delegate's
 application:handleEventsForBackgroundURLSession:completionHandler: method when the identifier passed in there matches
 kBackgroundSessionIdentifier.
 
 If you are setting up and registering your own custom NetworkManager instance rather than using one of the BridgeSDK's
 +setupWithAppPrefix: methods, you will also need to call this from your app delegate's
 application:didFinishLaunchingWithOptions: method with kBackgroundSessionIdentifier as the identifier, and nil for the
 completion handler.
 
 @param identifier        The session identifier, as passed in to your app delegate's
 application:handleEventsForBackgroundURLSession:completionHandler: method.
 @param completionHandler The completion handler, as passed in to your app delegate's
 application:handleEventsForBackgroundURLSession:completionHandler: method.
 */
- (void)restoreBackgroundSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

@end


/*!
 This class handles HTTP networking with the Bridge REST API.
 */
@interface SBBNetworkManager : NSObject<SBBComponent, SBBNetworkManagerProtocol>

+ (instancetype)networkManagerForEnvironment:(SBBEnvironment)environment study:(NSString *)study baseURLPath:(NSString *)baseURLPath;

#pragma mark - Init & Accessor Methods

/*!
 If you want to use SBBNetworkManager's features to access a different REST API, you can create an instance
 using this initializer, with the scheme and host part of that API's URL as the baseURL.
 
 @param baseURL The scheme and host part of a third-party REST API, e.g. https://webapi.somecompany.com . The urlString parameter of the put, get, etc. methods could then either be the fully-qualified URL of the endpoint you are accessing, or just the path part.
 
 @return An initialized SBBNetworkManager instance with the given baseURL.
 */
- (instancetype) initWithBaseURL: (NSString*) baseURL;

- (BOOL) isInternetConnected;
- (BOOL) isServerReachable;
@end


