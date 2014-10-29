//
//  MockNetworkManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "MockNetworkManager.h"
#import "NSError+SBBAdditions.h"

@interface MockNetworkManager ()

@property (nonatomic, strong) NSMutableDictionary *jsonForEndpoints;
@property (nonatomic, strong) NSMutableDictionary *codesForEndpoints;

@end

@implementation MockNetworkManager
@synthesize environment = _environment;
@synthesize backgroundTransferDelegate = _backgroundTransferDelegate;

- (id)init
{
  if (self = [super init]) {
    _jsonForEndpoints = [NSMutableDictionary dictionary];
    _codesForEndpoints = [NSMutableDictionary dictionary];
  }
  
  return self;
}

- (NSString *)keyForEndpoint:(NSString *)endpoint method:(NSString *)HTTPMethod
{
  return [HTTPMethod stringByAppendingString:endpoint];
}

- (void)setJson:(id)jsonObject andResponseCode:(NSInteger)statusCode forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod
{
  NSString *key = [self keyForEndpoint:endpoint method:HTTPMethod];
  [_jsonForEndpoints setValue:jsonObject forKey:key]; // jsonObject can be nil
  _codesForEndpoints[key] = [NSNumber numberWithInteger:statusCode];
}

- (BOOL)headersContainValidAuth:(NSDictionary *)headers
{
  return YES;
}

- (NSURLSessionDataTask *)dataTaskFor:(NSString *)URLString
                               method:(NSString *)method
                              headers:(NSDictionary *)headers //NSDictionary or Array of NSDictionary
                           parameters:(NSDictionary *)parameters
                           completion:(SBBNetworkManagerCompletionBlock)completion
{
  id json = nil;
  NSError *error = nil;
  if ([self headersContainValidAuth:headers]) {
    NSURL *url = [NSURL URLWithString:URLString];
    NSString *endpoint = [url path];
    NSString *key = [self keyForEndpoint:endpoint method:method];
    json = _jsonForEndpoints[key];
    NSInteger statusCode = [_codesForEndpoints[key] integerValue];
    error = [NSError generateSBBErrorForStatusCode:statusCode];
//    if (parameters) {
//      NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
//      NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//      NSLog(@"%@", JSONString);
//    }
  } else {
    error = [NSError generateSBBErrorForStatusCode:401];
  }
  
  if (completion) {
    completion(nil, json, error);
  }
  return nil;
}

- (NSURLSessionDataTask* )get:(NSString *)URLString
                      headers:(NSDictionary *)headers //NSDictionary or Array of NSDictionary
                   parameters:(id)parameters
                   completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self dataTaskFor:URLString method:@"GET" headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask* )post:(NSString *)URLString
                       headers:(NSDictionary *)headers
                    parameters:(id)parameters
                    completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self dataTaskFor:URLString method:@"POST" headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask* )put:(NSString *)URLString
                      headers:(NSDictionary *)headers
                   parameters:(id)parameters
                   completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self dataTaskFor:URLString method:@"PUT" headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)delete:(NSString *)URLString
                         headers:(NSDictionary *)headers
                      parameters:(id)parameters
                      completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self dataTaskFor:URLString method:@"DELETE" headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionUploadTask *)uploadFile:(NSURL *)fileUrl httpHeaders:(NSDictionary *)headers toUrl:(NSString *)urlString taskDescription:(NSString *)description completion:(SBBNetworkManagerTaskCompletionBlock)completion
{
  if (completion) {
    completion(nil, nil, nil);
  }
  return nil;
}

- (NSURLSessionDownloadTask *)downloadFileFromURLString:(NSString *)urlString method:(NSString *)httpMethod httpHeaders:(NSDictionary *)headers parameters:(NSDictionary *)parameters taskDescription:(NSString *)description downloadCompletion:(SBBNetworkManagerDownloadCompletionBlock)downloadCompletion taskCompletion:(SBBNetworkManagerTaskCompletionBlock)taskCompletion
{
  return nil;
}

- (void)restoreBackgroundSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
}

@end
