//
//  SBBCacheManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

@import CoreData;
@import Foundation;
#import "SBBComponent.h"

@protocol SBBCacheManagerProtocol <NSObject>

- (id)cachedObjectOfType:(NSString *)type withId:(id)objectId;

- (id)cachedObjectFromBridgeJSON:(id)json;

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

+ (instancetype)cacheManagerWithPersistentStoreName:(NSString *)storeName;

@end
