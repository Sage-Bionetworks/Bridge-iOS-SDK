//
//  SBBComponentManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/16/14.
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

#import "SBBComponentManager.h"
#import "SBBComponent.h"
#import "SBBBridgeInfo.h"

#pragma mark ComponentWrapper

@interface ComponentWrapper : NSObject

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) id component;

- (id)initForKey:(NSString *)key;

// Don't call dispatchSyncToCMQueue directly or indirectly from within the block!
- (void)dispatchSyncToQueue:(dispatch_block_t)block;

@end

@implementation ComponentWrapper

- (id)initForKey:(NSString *)key
{
  if (self = [super init]) {
    NSString *qName = [NSString stringWithFormat:@"org.sagebase.%@CMQueue", key];
    _queue = dispatch_queue_create([qName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
  }
  
  return self;
}

- (void)dispatchSyncToQueue:(dispatch_block_t)block
{
  dispatch_sync(_queue, block);
}

@end

@implementation SBBComponentManager

static NSMutableDictionary *gComponents = nil;

dispatch_queue_t CMQueue() {
  static dispatch_queue_t q;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    q = dispatch_queue_create("org.sagebase.ComponentManagerQueue", DISPATCH_QUEUE_SERIAL);
  });
  
  return q;
}

void dispatchSyncToCMQueue(void(^dispatchBlock)()) {
  dispatch_sync(CMQueue(), dispatchBlock);
}

+ (NSMutableDictionary *)freshComponentsRegistry
{
  NSMutableDictionary *components = [NSMutableDictionary dictionary];
  // register any iOS singleton classes used by the SDK as components.
  // note this assumes this method is only ever called from within CMQueue.
  
  // e.g.:
  // [self registerComponentThisQueue:[UIDevice currentDevice] forClass:[UIDevice class] inComponents:components];
  return components;
}

+ (NSMutableDictionary *)components
{
  // do not call except from within CMQueue
  if (!gComponents) {
    gComponents = [self freshComponentsRegistry];
  }
  
  return gComponents;
}

+ (id)registerComponentThisQueue:(id)component forClass:(Class)componentClass inComponents:(NSMutableDictionary *)components
{
  NSString *key = NSStringFromClass(componentClass);
  ComponentWrapper *oldCWrapper = [components valueForKey:key];
  if (!oldCWrapper) {
    oldCWrapper = [[ComponentWrapper alloc] initForKey:key];
    [components setValue:oldCWrapper forKey:key];
  }
  id oldComponent = oldCWrapper.component;
  oldCWrapper.component = component;
  
  return oldComponent;
}

+ (id)registerComponentThisQueue:(id)componentInstance forClass:(Class)componentClass
{
  return [self registerComponentThisQueue:componentInstance forClass:componentClass inComponents:[self components]];
}

+ (id)registerComponent:(id)componentInstance forClass:(Class)componentClass
{
  __block id oldComponent = nil;
  dispatchSyncToCMQueue(^{
    oldComponent = [self registerComponentThisQueue:componentInstance forClass:componentClass];
  });
  
  return oldComponent;
}

+ (id)component:(Class)componentClass
{
    // Until the study has been set up, don't allow access to any BridgeSDK components
    // or cause any defaults to be created and registered.
    if (![SBBBridgeInfo shared].studyIdentifier) {
        return nil;
    }
    
  __block ComponentWrapper *cWrapper = nil;
  __block id component = nil;
  __block Class localClass = componentClass;
  
  dispatchSyncToCMQueue(^{
    cWrapper = [[self components] valueForKey:NSStringFromClass(localClass)];
    if (!cWrapper) {
      [self registerComponentThisQueue:nil forClass:localClass];
      cWrapper = [[self components] valueForKey:NSStringFromClass(localClass)];
    }
  });
  
  if (cWrapper) {
    [cWrapper dispatchSyncToQueue:^{
      component = cWrapper.component;
      if (!component) {
        // by default, if there wasn't one already, get the shared instance for the given class and register it under its own class
        if ([localClass conformsToProtocol:@protocol(SBBComponent)]) {
          component = [(id<SBBComponent>)localClass defaultComponent];
          [self registerComponentThisQueue:component forClass:localClass];
        }
      }
    }];
  }
  
  return component;
}

+ (void)reset
{
  dispatchSyncToCMQueue(^{
    gComponents = nil;
  });
}

@end
