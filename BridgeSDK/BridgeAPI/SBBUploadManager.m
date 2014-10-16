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

@implementation SBBUploadManager

+ (instancetype)defaultComponent
{
  static SBBUploadManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (void)uploadFileToBridge:(NSURL *)fileUrl contentType:(NSString *)contentType completion:(SBBUploadManagerCompletionBlock)completion
{
  if (![fileUrl isFileURL]) {
    NSLog(@"Attempting to upload an URL that's not a file URL:\n%@", fileUrl);
    if (completion) {
      completion([NSError generateSBBNotAFileURLErrorForURL:fileUrl]);
    }
    return;
  }
  
  // default to generic binary file if type not specified
  if (!contentType) {
    contentType = @"application/octet-stream";
  }
  
  NSString *name = [fileUrl lastPathComponent];
  NSString *path = [fileUrl path];
  NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
  SBBUploadRequest *uploadRequest = [SBBUploadRequest new];
  uploadRequest.name = name;
  uploadRequest.contentLengthValue = fileData.length;
  uploadRequest.contentType = contentType;
  uploadRequest.contentMd5 = [fileData contentMD5];
  // don't use the shared SBBObjectManager--we want to use only SDK default objects for types
  SBBObjectManager *oMan = [SBBObjectManager objectManager];
  NSDictionary *uploadRequestJSON = [oMan bridgeJSONFromObject:uploadRequest];
  
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  [self.networkManager post:@"/api/v1/upload" headers:headers parameters:uploadRequestJSON completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error uploading file %@:\n%@", path, error);
      if (completion) {
        completion(error);
      }
      return;
    }
    SBBUploadSession *uploadSession = [oMan objectFromBridgeJSON:responseObject];
    if ([uploadSession isKindOfClass:[SBBUploadSession class]]) {
      NSDictionary *uploadHeaders =
      @{
        @"Content-Length": uploadRequest.contentLength,
        @"Content-Type": uploadRequest.contentType,
        @"Content-MD5": uploadRequest.contentMd5
        };
      [self.networkManager uploadFile:fileUrl httpHeaders:uploadHeaders toUrl:uploadSession.url completion:^(NSURLSessionUploadTask *task, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
          if (completion) {
            completion(error);
          }
          return;
        }
        
        // tell the API we done did it
        NSString *ref = [NSString stringWithFormat:@"/api/v1/upload/%@/complete", uploadSession.id];
        [self.networkManager post:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
          if (completion) {
            completion(error);
          }
        }];
      }];
    }
  }];
}

@end
