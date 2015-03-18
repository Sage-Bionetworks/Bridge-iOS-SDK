//
//  SBBUploadManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBUploadManager.h"
#import "NSData+SBBAdditions.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "SBBUploadSession.h"
#import "SBBUploadRequest.h"
#import "NSError+SBBAdditions.h"
#import "SBBErrors.h"

static NSString *kUploadFilesKey = @"SBBUploadFilesKey";
static NSString *kUploadRequestsKey = @"SBBUploadRequestsKey";
static NSString *kUploadSessionsKey = @"SBBUploadSessionsKey";
static NSString *kUploadResponsesKey = @"SBBUploadResponsesKey";

#pragma mark - SBBUploadCompletionWrapper

@interface SBBUploadCompletionWrapper : NSObject

@property (nonatomic, copy) SBBUploadManagerCompletionBlock completion;

- (instancetype)initWithBlock:(SBBUploadManagerCompletionBlock)block;

@end

@implementation SBBUploadCompletionWrapper

- (instancetype)initWithBlock:(SBBUploadManagerCompletionBlock)block
{
  if (self = [super init]) {
    self.completion = block;
  }
  
  return self;
}

@end

#pragma mark - SBBUploadManager

@interface SBBUploadManager () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) SBBObjectManager *cleanObjectManager;

@property (nonatomic, strong) NSMutableDictionary *uploadCompletionHandlers;

@end

@implementation SBBUploadManager
@synthesize uploadDelegate = _uploadDelegate;

+ (instancetype)defaultComponent
{
  static SBBUploadManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
    shared.networkManager.backgroundTransferDelegate = shared;
  });
  
  return shared;
}

- (instancetype)init
{
  if (self = [super init]) {
    self.uploadCompletionHandlers = [NSMutableDictionary dictionary];
  }
  
  return self;
}

- (NSURL *)tempUploadDirURL
{
  NSURL *uploadDir = nil;
  NSString *tempUploadDirName = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SBBUploadManager"];
  NSError *error;
  if ([[NSFileManager defaultManager] createDirectoryAtPath:tempUploadDirName withIntermediateDirectories:YES attributes:nil error:&error]) {
    uploadDir = [NSURL fileURLWithPath:tempUploadDirName];
  } else {
    NSLog(@"Error attempting to create tempUploadDir at path %@:\n%@", tempUploadDirName, error);
  }
  
  return uploadDir;
}

- (NSURL *)tempFileForFileURL:(NSURL *)fileURL
{
  NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSUUID UUID] UUIDString], [fileURL lastPathComponent]];
  NSURL *tempFileURL = [[self tempUploadDirURL] URLByAppendingPathComponent:fileName];
  NSError *error;
  [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:tempFileURL error:&error];
  if (error) {
    NSLog(@"Error copying file %@ to temp file %@:\n%@", [fileURL path], [tempFileURL path], error);
    tempFileURL = nil;
  }
  
  if (tempFileURL) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *filesForTempFiles = [[defaults dictionaryForKey:kUploadFilesKey] mutableCopy];
    [filesForTempFiles setObject:[fileURL path] forKey:[tempFileURL path]];
    [defaults setObject:filesForTempFiles forKey:kUploadFilesKey];
    [defaults synchronize];
  }
  
  return tempFileURL;
}

- (NSString *)fileForTempFile:(NSString *)tempFilePath
{
  NSString *file = nil;
  if (tempFilePath.length) {
    file = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadFilesKey][tempFilePath];
  }
  
  return file;
}

- (void)cleanUpTempFile:(NSString *)tempFilePath
{
  if (tempFilePath.length) {
    // remove it from the upload files map
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *files = [[defaults dictionaryForKey:kUploadFilesKey] mutableCopy];
    [files removeObjectForKey:tempFilePath];
    [defaults setObject:files forKey:kUploadFilesKey];
    [defaults synchronize];
    
    // delete the temp file
    NSURL *tempFile = [NSURL fileURLWithPath:tempFilePath];
    if  (!tempFile) {
      NSLog(@"Could not create NSURL for temp file %@", tempFilePath);
    }
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtURL:tempFile error:&error]) {
      NSLog(@"Failed to remove temp file %@, error:\n%@", tempFilePath, error);
    }
  }
}

- (SBBUploadManagerCompletionBlock)completionBlockForFile:(NSString *)file
{
  SBBUploadCompletionWrapper *wrapper = [_uploadCompletionHandlers objectForKey:file];
  return wrapper.completion;
}

- (void)setCompletionBlock:(SBBUploadManagerCompletionBlock)completion forFile:(NSString *)file
{
  if (!completion) {
    [self removeCompletionBlockForFile:file];
    return;
  }
  SBBUploadCompletionWrapper *wrapper = [[SBBUploadCompletionWrapper alloc] initWithBlock:completion];
  [_uploadCompletionHandlers setObject:wrapper forKey:file];
}

- (void)removeCompletionBlockForFile:(NSString *)file
{
  [_uploadCompletionHandlers removeObjectForKey:file];
}

- (void)setUploadRequestJSON:(id)json forFile:(NSString *)fileURLString
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSMutableDictionary *uploadRequests = [[defaults dictionaryForKey:kUploadRequestsKey] mutableCopy];
  if (!uploadRequests) {
    uploadRequests = [NSMutableDictionary dictionary];
  }
  if (json) {
    [uploadRequests setObject:json forKey:fileURLString];
  } else {
    [uploadRequests removeObjectForKey:fileURLString];
  }
  [defaults setObject:uploadRequests forKey:kUploadRequestsKey];
  [defaults synchronize];
}

- (SBBUploadRequest *)uploadRequestForFile:(NSString *)fileURLString
{
  SBBUploadRequest *uploadRequest = nil;
  id json = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadRequestsKey][fileURLString];
  if (json) {
    uploadRequest = [_cleanObjectManager objectFromBridgeJSON:json];
  }
  
  return uploadRequest;
}

- (void)setUploadSessionJSON:(id)json forFile:(NSString *)fileURLString
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSMutableDictionary *uploadSessions = [[defaults dictionaryForKey:kUploadSessionsKey] mutableCopy];
  if (!uploadSessions) {
    uploadSessions = [NSMutableDictionary dictionary];
  }
  if (json) {
    [uploadSessions setObject:json forKey:fileURLString];
  } else {
    [uploadSessions removeObjectForKey:fileURLString];
  }
  [defaults setObject:uploadSessions forKey:kUploadSessionsKey];
  [defaults synchronize];
}

- (SBBUploadSession *)uploadSessionForFile:(NSString *)fileURLString
{
  SBBUploadSession *uploadSession = nil;
  id json = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadSessionsKey][fileURLString];
  if (json) {
    uploadSession = [_cleanObjectManager objectFromBridgeJSON:json];
  }
  
  return uploadSession;
}

- (void)setUploadResponseContainerForFile:(NSString *)fileURLString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableData *responseContainer = [NSMutableData data];
    NSMutableDictionary *uploadResponses = [[defaults dictionaryForKey:kUploadResponsesKey] mutableCopy];
    if (!uploadResponses) {
        uploadResponses = [NSMutableDictionary dictionary];
    }
    
    [uploadResponses setObject:responseContainer forKey:fileURLString];
    [defaults setObject:uploadResponses forKey:fileURLString];
    [defaults synchronize];
}

- (void)removeUploadResponseContainerForFile:(NSString *)fileURLString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *uploadResponses = [[defaults dictionaryForKey:kUploadResponsesKey] mutableCopy];
    [uploadResponses removeObjectForKey:fileURLString];
    [defaults setObject:uploadResponses forKey:fileURLString];
    [defaults synchronize];
}

- (NSData *)responseDataForFile:(NSString *)fileURLString
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadResponsesKey][fileURLString];
}

- (void)appendData:(NSData *)data toResponseForFile:(NSString *)fileURLString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *uploadResponses = [[defaults dictionaryForKey:kUploadResponsesKey] mutableCopy];
    NSMutableData *container = [uploadResponses[fileURLString] mutableCopy];
    
    if (container) {
        [container appendData:data];
        [defaults setObject:uploadResponses forKey:fileURLString];
        [defaults synchronize];
    }
}

- (void)uploadFileToBridge:(NSURL *)fileUrl contentType:(NSString *)contentType completion:(SBBUploadManagerCompletionBlock)completion
{
  if (![fileUrl isFileURL] || ![[NSFileManager defaultManager] isReadableFileAtPath:[fileUrl path]]) {
    NSLog(@"Attempting to upload an URL that's not a readable file URL:\n%@", fileUrl);
    if (completion) {
      completion([NSError generateSBBNotAFileURLErrorForURL:fileUrl]);
    }
    if (_uploadDelegate) {
      [_uploadDelegate uploadManager:self uploadOfFile:[fileUrl absoluteString] completedWithError:[NSError generateSBBNotAFileURLErrorForURL:fileUrl]];
    }
    return;
  }
  
  // make a temp copy with a unique name
  NSURL *tempFileURL = [self tempFileForFileURL:fileUrl];
  [self setCompletionBlock:completion forFile:[tempFileURL path]];
  
  if (!_cleanObjectManager) {
    _cleanObjectManager = [SBBObjectManager objectManager];
  }
  
  // default to generic binary file if type not specified
  if (!contentType) {
    contentType = @"application/octet-stream";
  }
  
  NSString *name = [fileUrl lastPathComponent];
  NSData *fileData = [NSData dataWithContentsOfURL:tempFileURL];
  SBBUploadRequest *uploadRequest = [SBBUploadRequest new];
  uploadRequest.name = name;
  uploadRequest.contentLengthValue = fileData.length;
  uploadRequest.contentType = contentType;
  uploadRequest.contentMd5 = [fileData contentMD5];
  // don't use the shared SBBObjectManager--we want to use only SDK default objects for types
  NSDictionary *uploadRequestJSON = [_cleanObjectManager bridgeJSONFromObject:uploadRequest];
  [self setUploadRequestJSON:uploadRequestJSON forFile:[tempFileURL path]];
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  [self.networkManager downloadFileFromURLString:@"/api/v1/upload" method:@"POST" httpHeaders:headers parameters:uploadRequestJSON taskDescription:[tempFileURL path] downloadCompletion:nil taskCompletion:nil];
}

#pragma mark - Delegate methods

- (void)completeUploadOfFile:(NSString *)file withError:(NSError *)error
{
  SBBUploadManagerCompletionBlock completion = [self completionBlockForFile:file];
  if (completion) {
    [self removeCompletionBlockForFile:file];
    completion(error);
  }
  if (_uploadDelegate) {
    NSString *originalFile = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUploadFilesKey][file];
    [_uploadDelegate uploadManager:self uploadOfFile:originalFile completedWithError:error];
  }
  [self cleanUpTempFile:file];
  [self setUploadRequestJSON:nil forFile:file];
  [self setUploadSessionJSON:nil forFile:file];
  [self removeUploadResponseContainerForFile:file];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
  NSLog(@"Session became invalid! Error:\n%@", error);
  
  // handle completion (failure) for all outstanding uploads
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *files = [defaults dictionaryForKey:kUploadFilesKey];
  for (NSString *file in files.allKeys) {
    [self completeUploadOfFile:file withError:error];
  }
  
  // clear everything out
  [_uploadCompletionHandlers removeAllObjects];
  [defaults removeObjectForKey:kUploadRequestsKey];
  [defaults removeObjectForKey:kUploadSessionsKey];
  [defaults removeObjectForKey:kUploadFilesKey];
  [defaults removeObjectForKey:kUploadResponsesKey];
  
  NSError *fileError;
  [[NSFileManager defaultManager] removeItemAtURL:[self tempUploadDirURL] error:&fileError];
  if (fileError) {
    NSLog(@"Error removing temp upload file directory:\n%@", fileError);
  }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
  NSError *error;
  NSData *jsonData = [NSData dataWithContentsOfURL:location options:0 error:&error];
  if (error) {
    NSLog(@"Error reading downloaded UploadSession file into an NSData object:\n%@", error);
    [self completeUploadOfFile:downloadTask.taskDescription withError:error];
    return;
  }
  
  id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  if (error) {
    [self completeUploadOfFile:downloadTask.taskDescription withError:error];
    NSLog(@"Error deserializing downloaded UploadSession data into objects:\n%@", error);
    return;
  }
  
  SBBUploadSession *uploadSession = [_cleanObjectManager objectFromBridgeJSON:jsonObject];
  SBBUploadRequest *uploadRequest = [self uploadRequestForFile:downloadTask.taskDescription];
  [self setUploadRequestJSON:nil forFile:downloadTask.taskDescription];
  if ([uploadSession isKindOfClass:[SBBUploadSession class]]) {
    [self setUploadSessionJSON:jsonObject forFile:downloadTask.taskDescription];
    NSDictionary *uploadHeaders =
    @{
      @"Content-Length": [uploadRequest.contentLength stringValue],
      @"Content-Type": uploadRequest.contentType,
      @"Content-MD5": uploadRequest.contentMd5
      };
    NSURL *fileUrl = [NSURL fileURLWithPath:downloadTask.taskDescription];
    NSURLSessionUploadTask *task = [self.networkManager uploadFile:fileUrl httpHeaders:uploadHeaders toUrl:uploadSession.url taskDescription:downloadTask.taskDescription startImmediately:NO completion:nil];
    [self setUploadResponseContainerForFile:downloadTask.taskDescription];
    [task resume];
  } else {
    NSError *error = [NSError generateSBBObjectNotExpectedClassErrorForObject:uploadSession expectedClass:[SBBUploadSession class]];
    [self completeUploadOfFile:downloadTask.taskDescription withError:error];
  }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self appendData:data toResponseForFile:dataTask.taskDescription];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
  if ([task isKindOfClass:[NSURLSessionUploadTask class]]) {
    NSURLSessionUploadTask *uploadTask = (NSURLSessionUploadTask *)task;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)uploadTask.response;
    NSInteger httpStatusCode = httpResponse.statusCode;
     
    // client-side networking issue
    if (error) {
      [self completeUploadOfFile:uploadTask.taskDescription withError:error];
      return;
    }
    
    // server didn't like the request, or otherwise hiccupped
    if (httpStatusCode >= 300) {
        // iOS handles redirects automatically so only e.g. 307 resource not changed etc. from the 300 range should end up here
        // (along with all 4xx and 5xx of course)
        NSData *responseData = [self responseDataForFile:task.taskDescription];
        NSDictionary *responseHeaders = httpResponse.allHeaderFields;
        NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];
        id originalResponse = responseData;
        if ([contentType containsString:@"application/xml"]) {
            // thanks Amazon, I am NOT parsing XML if it's all the same to you
            originalResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        }
        if (!originalResponse) {
            originalResponse = @"";
        }
        NSString *description = [NSString stringWithFormat:@"Background file upload to S3 failed with HTTP status %ld", (long)httpStatusCode];
        NSError *s3Error = [NSError errorWithDomain:SBB_ERROR_DOMAIN code:kSBBS3UploadErrorResponse userInfo:@{NSLocalizedDescriptionKey: description, SBB_ORIGINAL_ERROR_KEY:originalResponse}];
        [self completeUploadOfFile:uploadTask.taskDescription withError:s3Error];
        return;
    }
    
    // tell the API we done did it
    SBBUploadSession *uploadSession = [self uploadSessionForFile:uploadTask.taskDescription];
    [self setUploadSessionJSON:nil forFile:uploadTask.taskDescription];
    NSString *ref = [NSString stringWithFormat:@"/api/v1/upload/%@/complete", uploadSession.id];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    [self.networkManager post:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
      [self completeUploadOfFile:uploadTask.taskDescription withError:error];
    }];
  } else if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
    if (!error && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
      error = [NSError generateSBBErrorForStatusCode:httpResponse.statusCode];
    }
    
    if (error) {
      [self completeUploadOfFile:task.taskDescription withError:error];
    }
  }
}

@end
