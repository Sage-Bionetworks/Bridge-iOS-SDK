//
//  SBBNetworkManager.m
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "BridgeSDK.h"
#import "SBBNetworkManager.h"
#import "SBBNetworkErrors.h"
#import "NSError+SBBAdditions.h"
#import "Reachability.h"
#import "UIDevice+Hardware.h"

SBBEnvironment gSBBDefaultEnvironment;

const NSInteger kMaxRetryCount = 5;

static SBBNetworkManager * sharedInstance;
NSString * kBackgroundSessionIdentifier = @"org.sagebase.backgroundsession";

/*********************************************************************************/
#pragma mark - APC Retry Object - Keeps track of retry count
/*********************************************************************************/
@interface APCNetworkRetryObject : NSObject

@property (nonatomic) NSInteger retryCount;
@property (nonatomic, copy) SBBNetworkManagerCompletionBlock completionBlock;
@property (nonatomic, copy) void (^retryBlock)(void);

@end

@implementation APCNetworkRetryObject

@end

/*********************************************************************************/
#pragma mark - APC Network Manager
/*********************************************************************************/

@interface SBBNetworkManager ()

@property (nonatomic, strong) Reachability * internetReachability;
@property (nonatomic, strong) Reachability * serverReachability;
@property (nonatomic, strong) NSString * baseURL;
@property (nonatomic, strong) NSURLSession * mainSession; //For data tasks
@property (nonatomic, strong) NSURLSession * backgroundSession; //For upload/download tasks

+ (NSString *)baseURLForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath;

@end

@implementation SBBNetworkManager
@synthesize environment = _environment;

+ (NSString *)baseURLForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)path
{
  static NSString *envFormatStrings[] = {
    @"%@",
    @"%@-staging",
    @"%@-develop",
    @"%@-custom"
  };
  NSString *baseURL = nil;
  
  if ((NSInteger)environment < sizeof(envFormatStrings) / sizeof(NSString *)) {
    NSString *firstComponent = [NSString stringWithFormat:envFormatStrings[environment], prefix];
    baseURL = [NSString stringWithFormat:@"https://%@.%@", firstComponent, path];
  }
  
  return baseURL;
}

+ (instancetype)networkManagerForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath
{
  NSString *baseURL = [self baseURLForEnvironment:environment appURLPrefix:prefix baseURLPath:baseURLPath];
  SBBNetworkManager *networkManager = [[self alloc] initWithBaseURL:baseURL];
  networkManager.environment = environment;
  return networkManager;
}

+ (instancetype)defaultComponent
{
  if (!gSBBAppURLPrefix) {
    return nil;
  }
  
  static SBBNetworkManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    SBBEnvironment environment = gSBBDefaultEnvironment;
    
    NSString *baseURL = [self baseURLForEnvironment:environment appURLPrefix:gSBBAppURLPrefix baseURLPath:@"sagebridge.org"];
    shared = [[self alloc] initWithBaseURL:baseURL];
    shared.environment = environment;
  });
  
  return shared;
}

/*********************************************************************************/
#pragma mark - Initializers & Accessors
/*********************************************************************************/

- (instancetype) initWithBaseURL: (NSString*) baseURL
{
    self = [super init]; //Using [self class] instead of APCNetworkManager to enable subclassing
    if (self) {
        self.baseURL = baseURL;
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        NSURL *url = [NSURL URLWithString:baseURL];
        self.serverReachability = [Reachability reachabilityWithHostName:[url host]]; //Check if only hostname is required
        [self.serverReachability startNotifier]; //Turning on ONLY server reachability notifiers
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
      self.environment = SBBEnvironmentCustom;
    }
    return self;
}

- (NSURLSession *)mainSession
{
    if (!_mainSession) {
        _mainSession = [NSURLSession sharedSession];
    }
    return _mainSession;
}

- (NSURLSession *)backgroundSession
{
    if (!_backgroundSession) {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionIdentifier];
        _backgroundSession = [NSURLSession sessionWithConfiguration:config];
    }
    return _backgroundSession;
}

- (BOOL)isInternetConnected
{
    return (self.internetReachability.currentReachabilityStatus != NotReachable);
}

- (BOOL)isServerReachable
{
    return (self.serverReachability.currentReachabilityStatus != NotReachable);
}

/*********************************************************************************/
#pragma mark - basic HTTP methods
/*********************************************************************************/
- (NSURLSessionDataTask *)get:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"GET" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)put:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"PUT" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)post:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"POST" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)delete:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"DELETE" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

// in case this class is used from C++, because delete is a keyword in that language (see header)
- (NSURLSessionDataTask *)delete_:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self delete:URLString headers:headers parameters:parameters completion:completion];
}


/*********************************************************************************/
#pragma mark - Helper Methods
/*********************************************************************************/
- (NSURLSessionDataTask *) doDataTask: (NSString*) method
                          retryObject: (APCNetworkRetryObject*) retryObject
                            URLString: (NSString*)URLString
                              headers: (NSDictionary *)headers
                           parameters:(NSDictionary *)parameters
                           completion:(SBBNetworkManagerCompletionBlock)completion
{
    APCNetworkRetryObject * localRetryObject;
    __weak APCNetworkRetryObject * weakLocalRetryObject;
    if (!retryObject) {
        localRetryObject = [[APCNetworkRetryObject alloc] init];
        weakLocalRetryObject = localRetryObject;
        localRetryObject.completionBlock = completion;
        localRetryObject.retryBlock = ^ {
            __strong APCNetworkRetryObject * strongLocalRetryObject = weakLocalRetryObject; //To break retain cycle
          [self doDataTask:method retryObject:strongLocalRetryObject URLString:URLString headers:headers parameters:parameters completion:completion];
        };
    }
    else
    {
        localRetryObject = retryObject;
    }
    
  NSMutableURLRequest *request = [self requestWithMethod:method URLString:URLString headers:headers parameters:parameters error:nil];
    NSURLSessionDataTask *task = [self.mainSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError * httpError = [NSError generateSBBErrorForStatusCode:((NSHTTPURLResponse*)response).statusCode data:data];
        NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (error)
        {
            [self handleError:error task:task retryObject:localRetryObject];
        }
        else if (httpError)
        {
            //TODO: Add retry for Server maintenance
            if (completion) {
                completion(task, responseObject, httpError);
            }
        }
        else
        {
            if (completion) {
                completion(task, responseObject, nil);
            }
        }
    }];
  
    [task resume];
 
    return task;
    
}

- (NSString *)queryStringFromParameters:(NSDictionary *)parameters
{
  if (![parameters isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  
  NSMutableArray *queryParams = [NSMutableArray arrayWithCapacity:parameters.count];
  for (NSString *param in parameters) {
    NSString *qParam = [NSString stringWithFormat:@"%@=%@",
                        [param stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]],
                        [parameters[param] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    [queryParams addObject:qParam];
  }
  
  return [queryParams componentsJoinedByString:@"&"];
}

- (NSString *)userAgentHeader
{
  NSDictionary *localizedInfoDictionary = [[NSBundle mainBundle] localizedInfoDictionary];
  if (!localizedInfoDictionary) {
    localizedInfoDictionary = [[NSBundle mainBundle] infoDictionary];
  }
  NSString *appName = [localizedInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
  NSString *appVersion = [localizedInfoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
  NSString *deviceModel = [[UIDevice currentDevice] platformString];
  NSString *osName = [[UIDevice currentDevice] systemName];
  NSString *osVersion = [[UIDevice currentDevice] systemVersion];
  
  return [NSString stringWithFormat:@"%@/%@ (%@; %@ %@) BridgeSDK/%0.0f", appName, appVersion, deviceModel, osName, osVersion, BridgeSDKVersionNumber];
}

- (NSString *)acceptLanguageHeader
{
  return [NSString stringWithFormat:@"%@", [[NSLocale preferredLanguages] componentsJoinedByString:@", "]];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                   headers:(NSDictionary *)headers
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error
{
  BOOL isGET = [method isEqualToString:@"GET"];
  if (parameters && isGET) {
    NSString *queryString = [self queryStringFromParameters:parameters];
    if (queryString.length) {
      if ([URLString containsString:@"?"]) {
        URLString = [NSString stringWithFormat:@"%@&%@", URLString, queryString];
      } else {
        URLString = [NSString stringWithFormat:@"%@?%@", URLString, queryString];
      }
    }
  }
  
  NSURL *url = [self URLForRelativeorAbsoluteURLString:URLString];
  NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
  mutableRequest.HTTPMethod = method;
  [mutableRequest setValue:[self userAgentHeader] forHTTPHeaderField:@"User-Agent"];
  [mutableRequest setValue:[self acceptLanguageHeader] forHTTPHeaderField:@"Accept-Language"];
  
  if (headers) {
    for (NSString *header in headers.allKeys) {
      [mutableRequest addValue:headers[header] forHTTPHeaderField:header];
    }
  }
    
  if (parameters && !isGET) {
    if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
      NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
      [mutableRequest setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    }
    
    [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:error]];
  }
  
  return mutableRequest;
}

- (NSURL *) URLForRelativeorAbsoluteURLString: (NSString*) URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    if ([url.scheme.lowercaseString hasPrefix:@"http"]) {
        return url;
    }
    else
    {
        NSURL * tempURL =[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseURL]];
        return [NSURL URLWithString:[tempURL absoluteString]];
    }
}

/*********************************************************************************/
#pragma mark - Error Handler
/*********************************************************************************/
- (void)handleError:(NSError*)error task:(NSURLSessionDataTask*) task retryObject: (APCNetworkRetryObject*) retryObject
{
    NSInteger errorCode = error.code;
    NSError * apcError = [NSError generateSBBErrorForNSURLError:error isInternetConnected:self.isInternetConnected isServerReachable:self.isServerReachable];
    
    if (!self.isInternetConnected || !self.isServerReachable) {
        if (retryObject.completionBlock)
        {
            retryObject.completionBlock(task, nil, apcError);
        }
        retryObject.retryBlock = nil;
    }
    
    if ([self checkForTemporaryErrors:errorCode])
    {
        
        if (retryObject && retryObject.retryCount < kMaxRetryCount)
        {
            double delayInSeconds = pow(2.0, retryObject.retryCount + 1); //Exponential backoff
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                retryObject.retryBlock();
                retryObject.retryCount++;
            });
        }
        else
        {
            if (retryObject.completionBlock)
            {
                retryObject.completionBlock(task, nil, apcError);
            }
            retryObject.retryBlock = nil;
        }
    }
}

- (BOOL) checkForTemporaryErrors:(NSInteger) errorCode
{
    return (errorCode == NSURLErrorTimedOut || errorCode == NSURLErrorCannotFindHost || errorCode == NSURLErrorCannotConnectToHost || errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorSecureConnectionFailed);
}


/*********************************************************************************/
#pragma mark - Misc
/*********************************************************************************/
- (void)reachabilityChanged: (NSNotification*) notification
{
    //TODO: Figure out what needs to be done here
}

- (void)dealloc
{
    [self.serverReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self];
}
@end
