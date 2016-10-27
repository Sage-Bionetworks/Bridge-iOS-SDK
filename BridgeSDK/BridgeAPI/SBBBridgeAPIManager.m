//
//  SBBBridgeAPIManager.m
//  BridgeSDK
//
//	Copyright (c) 2014, Sage Bionetworks
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

#import "SBBBridgeAPIManager.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "SBBObjectManagerInternal.h"
#import "SBBBridgeNetworkManager.h"

@interface SBBBridgeAPIManager ()

@property (nonatomic, strong) id<SBBNetworkManagerProtocol> networkManager;
@property (nonatomic, strong) id<SBBAuthManagerProtocol> authManager;
@property (nonatomic, strong) id<SBBObjectManagerProtocol> objectManager;

@end


@implementation SBBBridgeAPIManager

+ (instancetype)instanceWithRegisteredDependencies
{
  return [self managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:SBBComponent(SBBObjectManager)];
}

+ (instancetype)managerWithAuthManager:(id<SBBAuthManagerProtocol>)authManager networkManager:(id<SBBBridgeNetworkManagerProtocol>)networkManager objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  SBBBridgeAPIManager *manager = [[self alloc] init];
  manager.networkManager = networkManager;
  manager.authManager = authManager;
  manager.objectManager = objectManager;
  
  return manager;
}

- (id<SBBCacheManagerProtocol>)cacheManager
{
    id<SBBCacheManagerProtocol> cacheManager = nil;
    if (gSBBUseCache && [self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
        cacheManager = ((id<SBBObjectManagerInternalProtocol>)self.objectManager).cacheManager;
    }
    return cacheManager;
}

@end
