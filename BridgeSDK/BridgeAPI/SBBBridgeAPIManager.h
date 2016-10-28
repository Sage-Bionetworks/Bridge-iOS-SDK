//
//  SBBBridgeAPIManager.h
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

#import <Foundation/Foundation.h>
#import "SBBComponent.h"

@protocol SBBAuthManagerProtocol;
@protocol SBBNetworkManagerProtocol;
@protocol SBBObjectManagerProtocol;

typedef NS_ENUM(NSUInteger, SBBCachingPolicy) {
    SBBCachingPolicyNoCaching = 0,
    SBBCachingPolicyCheckCacheFirst,
    SBBCachingPolicyFallBackToCached,
    SBBCachingPolicyCachedOnly
};

/*!
 This is the "base protocol" for Bridge API Managers.
 */
@protocol SBBBridgeAPIManagerProtocol <NSObject>

@end

/*!
 This is an abstract base class for SBBComponents that implement parts of the Bridge REST API.
 */
@interface SBBBridgeAPIManager : NSObject<SBBBridgeAPIManagerProtocol>

@property (nonatomic, strong, readonly) id<SBBNetworkManagerProtocol> networkManager;
@property (nonatomic, strong, readonly) id<SBBAuthManagerProtocol> authManager;
@property (nonatomic, strong, readonly) id<SBBObjectManagerProtocol> objectManager;

/*!
 Return an SBBXxxManager component (where SBBXxxManager is a concrete subclass of SBBBridgeAPIManager) configured to use the currently-registered auth manager, network manager, and object manager.
 
 @return An SBBXxxManager injected with the dependencies as currently registered.
 */
+ (instancetype)instanceWithRegisteredDependencies;

/*!
 *  Return an SBBXxxManager component (where SBBXxxManager is a concrete subclass of SBBBridgeAPIManager) configured to use the specified auth manager, network manager, and object manager.
 *
 *  Use this method to build a custom configuration, e.g. for testing.
 *
 *  @param authManager    The auth manager to use for authentication. Must implement the SBBAuthManagerProtocol.
 *  @param networkManager The network manager to use for making REST API requests. Must implement the SBBNetworkManagerProtocol.
 *  @param objectManager  The object manager to use for converting between JSON and client objects. Must implement the SBBObjectManagerProtocol.
 *
 *  @return An SBBXxxManager injected with the specified dependencies.
 */
+ (instancetype)managerWithAuthManager:(id<SBBAuthManagerProtocol>)authManager networkManager:(id<SBBNetworkManagerProtocol>)networkManager objectManager:(id<SBBObjectManagerProtocol>)objectManager;

@end
