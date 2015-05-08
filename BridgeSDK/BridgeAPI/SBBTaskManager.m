//
//  SBBTaskManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 5/5/15.
//
//	Copyright (c) 2015, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBTaskManager.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "SBBBridgeObjects.h"
#import "NSDate+SBBAdditions.h"

@implementation SBBTaskManager

+ (instancetype)defaultComponent
{
    static SBBTaskManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (NSURLSessionDataTask *)getTasksUntil:(NSDate *)until withCompletion:(SBBTaskManagerGetCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager get:@"/api/v1/tasks" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        SBBResourceList *tasks = [self.objectManager objectFromBridgeJSON:responseObject];
        if (completion) {
            completion(tasks, error);
        }
    }];
}

- (NSURLSessionDataTask *)startTask:(SBBTask *)task asOf:(NSDate *)startDate withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion
{
    task.startedOn = startDate;
    return [self updateTasks:@[task] withCompletion:completion];
}

- (NSURLSessionDataTask *)finishTask:(SBBTask *)task asOf:(NSDate *)finishDate withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion
{
    task.finishedOn = finishDate;
    return [self updateTasks:@[task] withCompletion:completion];
}

- (NSURLSessionDataTask *)deleteTask:(SBBTask *)task withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion
{
    return [self finishTask:task asOf:[NSDate date] withCompletion:completion];
}

- (NSURLSessionDataTask *)updateTasks:(NSArray *)tasks withCompletion:(SBBTaskManagerUpdateCompletionBlock)completion
{
    id jsonTasks = [self.objectManager bridgeJSONFromObject:tasks];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager post:@"/api/v1/tasks" headers:headers parameters:jsonTasks completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
#if DEBUG
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"Update tasks HTTP response code: %ld", (long)httpResponse.statusCode);
#endif
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

@end
