//
//  SBBBridgeInfo.h
//  BridgeSDK
//
//  Created by Erin Mounts on 1/12/17.
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//

#import <BridgeSDK/SBBBridgeInfoProtocol.h>

@interface SBBBridgeInfo : NSObject <SBBBridgeInfoProtocol>

+ (instancetype)shared;

- (void)setFromBridgeInfo:(id<SBBBridgeInfoProtocol>)info;

@end
