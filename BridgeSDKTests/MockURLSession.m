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

@property (nonatomic, strong) NSOperationQueue *mockDelegateQueue;
@property (nonatomic, strong) NSMutableArray *mockTasks;

- (NSData *)dataAndResponse:(NSHTTPURLResponse **)response forRequest:(NSURLRequest *)request;
- (NSURL *)downloadFileURLAndError:(NSError **)error forRequest:(NSURLRequest *)request;
- (void)addMockTask:(NSURLSessionTask *)task;
- (void)removeMockTask:(NSURLSessionTask *)task;

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
    MockHTTPURLResponse *response;
    NSData *data = [_session dataAndResponse:&response forRequest:_request];
    
    if (_completionHandler) {
        _completionHandler(data, response, error);
    }
    
    [_session removeMockTask:self];
}

@end

#pragma mark - MockUploadTask

@interface MockUploadTask : NSURLSessionUploadTask

@property (nonatomic, weak) MockURLSession *session;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) MockHTTPURLResponse *mockResponse;

@end

@implementation MockUploadTask

@synthesize taskDescription;
@synthesize taskIdentifier;

- (void)resume
{
    [_session.delegateQueue addOperationWithBlock:^{
        MockHTTPURLResponse *response;
        __unused NSData *data = [_session dataAndResponse:&response forRequest:_request];
        _mockResponse = response;
        
        id<NSURLSessionTaskDelegate> delegate = (id<NSURLSessionTaskDelegate>)_session.delegate;
        if (delegate && [delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
            [delegate URLSession:_session task:self didCompleteWithError:nil];
        }
        [_session removeMockTask:self];
    }];
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

@synthesize taskDescription;
@synthesize taskIdentifier;

- (void)resume
{
    [_session.delegateQueue addOperationWithBlock:^{
        MockHTTPURLResponse *response;
        __unused NSData *data = [_session dataAndResponse:&response forRequest:_request];
        _mockResponse = response;
        NSError *error;
        NSURL *fileURL = [_session downloadFileURLAndError:&error forRequest:_request];
        
        id<NSURLSessionDownloadDelegate> delegate = (id<NSURLSessionDownloadDelegate>)_session.delegate;
        if (delegate) {
            if ([delegate respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)]) {
                [delegate URLSession:_session downloadTask:self didFinishDownloadingToURL:fileURL];
            }

            if ([delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
                [delegate URLSession:_session task:self didCompleteWithError:nil];
            }
        }
        [_session removeMockTask:self];
    }];
}

- (NSURLResponse *)response
{
    return _mockResponse;
}

@end

#pragma mark MockURLSession

@implementation MockURLSession

- (id)init
{
    if (self = [super init]) {
        _jsonForEndpoints = [NSMutableDictionary dictionary];
        _codesForEndpoints = [NSMutableDictionary dictionary];
        _URLSForEndpoints = [NSMutableDictionary dictionary];
        _errorsForEndpoints = [NSMutableDictionary dictionary];
        _mockTasks = [NSMutableArray array];
    }
    
    return self;
}

- (NSString *)keyForEndpoint:(NSString *)endpoint method:(NSString *)HTTPMethod
{
    return [HTTPMethod stringByAppendingString:endpoint];
}

- (NSMutableArray *)responsesForKey:(NSString *)key
{
    NSMutableArray *responses = _jsonForEndpoints[key];
    if (!responses) {
        responses = [NSMutableArray array];
        _jsonForEndpoints[key] = responses;
    }
    
    return responses;
}

- (NSMutableArray *)codesForKey:(NSString *)key
{
    NSMutableArray *codes = _codesForEndpoints[key];
    if (!codes) {
        codes = [NSMutableArray array];
        _codesForEndpoints[key] = codes;
    }
    
    return codes;
}

- (void)setJson:(id)jsonObject andResponseCode:(NSInteger)statusCode forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod
{
    NSString *key = [self keyForEndpoint:endpoint method:HTTPMethod];
    NSMutableArray *responses = [self responsesForKey:key];
    NSMutableArray *codes = [self codesForKey:key];
    
    [responses addObject:jsonObject ?: [NSNull null]];
    [codes addObject:@(statusCode)];
}

- (id)pullNextResponseForKey:(NSString *)key
{
    NSMutableArray *responses = [self responsesForKey:key];
    id response = [responses firstObject];
    if (responses.count) {
        [responses removeObjectAtIndex:0];
    }
    
    if (response == [NSNull null]) {
        response = nil;
    }
    
    return response;
}

- (NSInteger)pullNextCodeForKey:(NSString *)key
{
    NSMutableArray *codes = [self codesForKey:key];
    NSNumber *code = [codes firstObject];
    if (codes.count) {
        [codes removeObjectAtIndex:0];
    }
    
    return code.integerValue;
}

- (NSData *)dataAndResponse:(NSHTTPURLResponse *__autoreleasing *)response forRequest:(NSURLRequest *)request
{
    NSInteger statusCode;
    id json;
    if ([self headersContainValidAuth:request.allHTTPHeaderFields]) {
        NSString *endpoint = request.URL.path;
        NSString *key = [self keyForEndpoint:endpoint method:request.HTTPMethod];
        json = [self pullNextResponseForKey:key];
        statusCode = [self pullNextCodeForKey:key];
    } else {
        statusCode = 401;
    }
    
    if (response) {
        MockHTTPURLResponse *mockResponse = [MockHTTPURLResponse new];
        mockResponse.mockStatusCode = statusCode;
        *response = mockResponse;
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

- (NSMutableArray *)fileURLsForKey:(NSString *)key
{
    NSMutableArray *fileURLs = _URLSForEndpoints[key];
    if (!fileURLs) {
        fileURLs = [NSMutableArray array];
        _URLSForEndpoints[key] = fileURLs;
    }
    
    return fileURLs;
}

- (NSMutableArray *)errorsForKey:(NSString *)key
{
    NSMutableArray *errors = _errorsForEndpoints[key];
    if (!errors) {
        errors = [NSMutableArray array];
        _errorsForEndpoints[key] = errors;
    }
    
    return errors;
}

- (void)setDownloadFileURL:(NSURL *)fileURL andError:(NSError *)error forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod
{
    NSString *key = [self keyForEndpoint:endpoint method:HTTPMethod];
    NSMutableArray *fileURLs = [self fileURLsForKey:key];
    NSMutableArray *errors = [self errorsForKey:key];
    
    [fileURLs addObject:fileURL ?: [NSNull null]];
    [errors addObject:error ?: [NSNull null]];
}

- (NSURL *)pullNextFileURLForKey:(NSString *)key
{
    NSMutableArray *fileURLs = [self fileURLsForKey:key];
    id fileURL = [fileURLs firstObject];
    if (fileURLs.count) {
        [fileURLs removeObjectAtIndex:0];
    }
    
    if (fileURL == [NSNull null]) {
        fileURL = nil;
    }
    
    return fileURL;
}

- (NSError *)pullNextErrorForKey:(NSString *)key
{
    NSMutableArray *errors = [self errorsForKey:key];
    id error = [errors firstObject];
    if (errors.count) {
        [errors removeObjectAtIndex:0];
    }
    
    if (error == [NSNull null]) {
        error = nil;
    }
    
    return error;
}

- (NSURL *)downloadFileURLAndError:(NSError **)error forRequest:(NSURLRequest *)request
{
    NSString *endpoint = request.URL.path;
    NSString *key = [self keyForEndpoint:endpoint method:request.HTTPMethod];
    if (error) {
        *error = [self pullNextErrorForKey:key];
    }
    
    return [self pullNextFileURLForKey:key];
}

- (void)doSyncInDelegateQueue:(dispatch_block_t)block
{
    if ([NSOperationQueue currentQueue] == self.delegateQueue) {
        // already there--just do it
        block();
    } else {
        // toss it in the background session delegate queue and wait for it to finish
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:block];
        [self.delegateQueue addOperations:@[op] waitUntilFinished:YES];
    }

}

- (void)addMockTask:(NSURLSessionTask *)task
{
    [self doSyncInDelegateQueue:^{
        [_mockTasks addObject:task];
    }];
}

- (void)removeMockTask:(NSURLSessionTask *)task
{
    [self doSyncInDelegateQueue:^{
        [_mockTasks removeObject:task];
    }];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    MockDataTask *task = [MockDataTask new];
    [self addMockTask:task];
    task.request = request;
    task.completionHandler = completionHandler;
    task.session = self;
    return task;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL
{
    MockUploadTask *task = [MockUploadTask new];
    [self addMockTask:task];
    task.request = request;
    task.session = self;
    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
{
    MockDownloadTask *task = [MockDownloadTask new];
    [self addMockTask:task];
    task.request = request;
    task.session = self;
    return task;
}

- (void)getAllTasksWithCompletionHandler:(void (^)(NSArray<__kindof NSURLSessionTask *> * _Nonnull))completionHandler
{
    [self.delegateQueue addOperationWithBlock:^{
        completionHandler(_mockTasks);
    }];
}

- (id<NSURLSessionDelegate>)delegate
{
    return _mockDelegate;
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
