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

@class SBBBridgeObject;

@protocol SBBCacheManagerProtocol <NSObject>

- (SBBBridgeObject *)cachedObjectOfType:(NSString *)type withId:(id)objectId;

- (SBBBridgeObject *)cachedObjectFromBridgeJSON:(id)json;

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

+ (instancetype)cacheManagerWithPersistentStoreName:(NSString *)storeName;

@end
