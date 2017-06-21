//
//  SBBCacheManager.h
//  BridgeSDK
//
//	Copyright (c) 2014-2016, Sage Bionetworks
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
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

@import CoreData;
@import Foundation;
#import "SBBComponent.h"
#import "SBBAuthManager.h"
#import "BridgeSDK+Internal.h"

/// Global flag indicating whether to use internal persistent object cache. Should be set before attempting to access Bridge APIs, usually by calling the BridgeSDK setup or setupWithBridgeInfo: class method.
extern  BOOL gSBBUseCache;

@class SBBBridgeObject;
@class ModelObject;

@protocol SBBCacheManagerProtocol <NSObject>

- (SBBBridgeObject *)cachedObjectOfType:(NSString *)type withId:(NSString *)objectId createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedSingletonObjectOfType:(NSString *)type createIfMissing:(BOOL)create;

- (SBBBridgeObject *)cachedObjectFromBridgeJSON:(id)json; // creates if missing

- (SBBBridgeObject *)cachedObjectFromBridgeJSON:(id)json createIfMissing:(BOOL)create;

// use ModelObject as the parameter type because test case classes don't derive from SBBBridgeObject
// (because they're generated from a separate test data model)
- (NSManagedObject *)cachedObjectForBridgeObject:(ModelObject *)bridgeObject inContext:(NSManagedObjectContext *)context;

- (void)removeFromCacheObjectOfType:(NSString *)type withId:(NSString *)objectId;

- (NSManagedObjectContext *)cacheIOContext;

- (void)saveCacheIOContext;

- (NSString *)encryptionKey;

- (BOOL)resetCache;

// must be called in the cacheIOContext private queue
- (NSManagedObject *)managedObjectOfEntity:(NSEntityDescription *)entity withId:(NSString *)objectId atKeyPath:(NSString *)keyPath;

@end

@interface SBBCacheManager : NSObject<SBBComponent, SBBCacheManagerProtocol>

@property (nonatomic, strong) NSString *persistentStoreName;

+ (instancetype)cacheManagerWithDataModelName:(NSString *)modelName bundleId:(NSString *)bundleId storeType:(NSString *)storeType authManager:(id<SBBAuthManagerProtocol>)authManager;

+ (instancetype)inMemoryCacheManagerWithAuthManager:(id<SBBAuthManagerProtocol>)authManager;

@end
