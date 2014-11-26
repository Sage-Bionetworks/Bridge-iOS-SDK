//
//  SBBCacheManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBComponent.h"

@protocol SBBCacheManagerProtocol <NSObject>

//

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

@end
