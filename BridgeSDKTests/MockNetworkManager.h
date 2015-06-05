//
//  MockNetworkManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBNetworkManager.h"

@interface MockNetworkManager : NSObject <SBBNetworkManagerProtocol>

- (void)setJson:(id)jsonObject andResponseCode:(NSInteger)statusCode forEndpoint:(NSString *)endpoint andMethod:(NSString *)HTTPMethod;

@end
