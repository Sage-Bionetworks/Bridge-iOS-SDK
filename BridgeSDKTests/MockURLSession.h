//
//  MockURLSession.h
//  BridgeSDK
//
//  Created by Erin Mounts on 5/29/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MockURLSession : NSURLSession

- (void)setJson:(id)jsonObject andResponseCode:(NSInteger)statusCode forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod;

@end
