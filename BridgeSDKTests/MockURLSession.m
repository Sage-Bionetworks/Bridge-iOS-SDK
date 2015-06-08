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

- (NSString *)keyForEndpoint:(NSString *)endpoint method:(NSString *)HTTPMethod;

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

- (BOOL)headersContainValidAuth:(NSDictionary *)headers
{
    return ![headers[@"Bridge-Session"] isEqualToString:@"expired"];
}

- (void)resume
{
    id json = nil;
    NSError *error = nil;
    NSInteger statusCode = 200;
    if ([self headersContainValidAuth:_request.allHTTPHeaderFields]) {
        NSString *endpoint = _request.URL.path;
        NSString *key = [_session keyForEndpoint:endpoint method:_request.HTTPMethod];
        json = _session.jsonForEndpoints[key];
        statusCode = [_session.codesForEndpoints[key] integerValue];
    } else {
        statusCode = 401;
    }
    
    MockHTTPURLResponse *response = [MockHTTPURLResponse new];
    response.mockStatusCode = statusCode;
    
    NSData *data = [NSData data];
    if (json) {
        data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    }
    
    if (_completionHandler) {
        _completionHandler(data, response, error);
    }
}

@end

#pragma mark - MockUploadTask

@interface MockUploadTask : NSURLSessionUploadTask

@property (nonatomic, weak) MockURLSession *session;

@end

@implementation MockUploadTask

- (void)resume
{
    
}

@end

#pragma mark - MockDownloadTask

@interface MockDownloadTask : NSURLSessionDownloadTask

@property (nonatomic, weak) MockURLSession *session;

@end

@implementation MockDownloadTask

- (void)resume
{
    
}

@end

#pragma mark MockURLSession

@implementation MockURLSession

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

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    MockDataTask *task = [MockDataTask new];
    task.request = request;
    task.completionHandler = completionHandler;
    task.session = self;
    return task;
}

@end
