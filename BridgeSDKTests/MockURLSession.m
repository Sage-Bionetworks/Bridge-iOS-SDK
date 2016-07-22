//
//  MockURLSession.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/29/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import "MockURLSession.h"
#import "NSError+SBBAdditions.h"

@interface MockURLSession ()

@property (nonatomic, strong) NSMutableDictionary *jsonForEndpoints;
@property (nonatomic, strong) NSMutableDictionary *codesForEndpoints;
@property (nonatomic, strong) NSMutableDictionary *URLSForEndpoints;
@property (nonatomic, strong) NSMutableDictionary *errorsForEndpoints;
@property (nonatomic, strong) NSOperationQueue *mockDelegateQueue;

- (NSData *)dataAndResponse:(NSHTTPURLResponse **)response forRequest:(NSURLRequest *)request;
- (NSURL *)downloadFileURLAndError:(NSError **)error forRequest:(NSURLRequest *)request;

@end

#pragma mark - MockHTTPURLResponse

@interface MockHTTPURLResponse : NSHTTPURLResponse

@property (nonatomic, assign) NSInteger mockStatusCode;

@end

@implementation MockHTTPURLResponse

- (NSInteger)statusCode
{
    return _mockStatusCode;
}

@end

#pragma mark - MockDataTask

@interface MockDataTask : NSURLSessionDataTask

@property (nonatomic, weak) MockURLSession *session;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy) void (^completionHandler)(NSData *, NSURLResponse *, NSError *);

@end

@implementation MockDataTask

- (void)resume
{
    NSError *error = nil;
    NSInteger statusCode;
    MockHTTPURLResponse *response;
    NSData *data = [_session dataAndResponse:&response forRequest:_request];
    
    if (_completionHandler) {
        _completionHandler(data, response, error);
    }
}

@end

#pragma mark - MockUploadTask

@interface MockUploadTask : NSURLSessionUploadTask

@property (nonatomic, weak) MockURLSession *session;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) MockHTTPURLResponse *mockResponse;

@end

@implementation MockUploadTask

- (void)resume
{
    NSError *error = nil;
    NSInteger statusCode;
    __unused NSData *data = [_session dataAndResponse:&_mockResponse forRequest:_request];
    
    id<NSURLSessionTaskDelegate> delegate = _session.mockDelegate;
    if (delegate && [delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [delegate URLSession:_session task:self didCompleteWithError:nil];
    }
}

- (NSURLResponse *)response
{
    return _mockResponse;
}

@end

#pragma mark - MockDownloadTask

@interface MockDownloadTask : NSURLSessionDownloadTask

@property (nonatomic, weak) MockURLSession *session;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) MockHTTPURLResponse *mockResponse;

@end

@implementation MockDownloadTask

- (void)resume
{
    NSInteger statusCode;
    __unused NSData *data = [_session dataAndResponse:&_mockResponse forRequest:_request];
    NSError *error;
    NSURL *fileURL = [_session downloadFileURLAndError:&error forRequest:_request];
    
    id<NSURLSessionDownloadTaskDelegate> delegate = _session.mockDelegate;
    if (delegate) {
        if ([delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
            [delegate URLSession:_session task:self didCompleteWithError:nil];
        }
        
        if ([delegate respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)]) {
            [delegate URLSession:_session downloadTask:self didFinishDownloadingToURL:fileURL];
        }
    }
}


@end

#pragma mark MockURLSession

@implementation MockURLSession

- (id)init
{
    if (self = [super init]) {
        _jsonForEndpoints = [NSMutableDictionary dictionary];
        _codesForEndpoints = [NSMutableDictionary dictionary];
        _isBackground = NO;
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

- (NSData *)dataAndResponse:(NSHTTPURLResponse *__autoreleasing *)response forRequest:(NSURLRequest *)request
{
    NSInteger statusCode;
    if ([self headersContainValidAuth:request.allHTTPHeaderFields]) {
        NSString *endpoint = request.URL.path;
        NSString *key = [self keyForEndpoint:endpoint method:request.HTTPMethod];
        json = _jsonForEndpoints[key];
        statusCode = [_codesForEndpoints[key] integerValue];
    } else {
        statusCode = 401;
    }
    
    if (response) {
        *response = [MockHTTPURLResponse new];
        (*response).mockStatusCode = statusCode;
    }
    
    NSData *data = nil;
    if (json) {
        data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    }
    
    return data;
}

- (BOOL)headersContainValidAuth:(NSDictionary *)headers
{
    return ![headers[@"Bridge-Session"] isEqualToString:@"expired"];
}

- (void)setDownloadFileURL:(NSURL *)fileURL andError:(NSError *)error forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod
{
    NSString *key = [self keyForEndpoint:endpoint method:HTTPMethod];
    [_URLSForEndpoints setValue:fileURL forKey:key];
    [_errorsForEndpoints setValue:error forKey:key];
}

- (NSURL *)downloadFileURLAndError:(NSError **)error forRequest:(NSURLRequest *)request
{
    NSString *endpoint = request.URL.path;
    NSString *key = [self keyForEndpoint:endpoint method:request.HTTPMethod];
    if (error) {
        *error = _errorsForEndpoints[key];
    }
    
    return _URLSForEndpoints[key];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    MockDataTask *task = [MockDataTask new];
    task.request = request;
    task.completionHandler = completionHandler;
    task.session = self;
    return task;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL
{
    MockUploadTask *task = [MockUploadTask new];
    task.request = request;
    task.session = self;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
{
    MockDownloadTask *task = [MockDownloadTask new];
    task.request = request;
    task.session = self;
}

- (NSOperationQueue *)delegateQueue
{
    if (!_mockDelegateQueue) {
        _mockDelegateQueue = [NSOperationQueue new];
        _mockDelegateQueue.maxConcurrentOperationCount = 1;
    }
    
    return _mockDelegateQueue;
}

@end
