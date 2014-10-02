//
//  SBBComponentManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/16/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBComponentManager.h"
#import "SBBComponent.h"

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
  __block ComponentWrapper *cWrapper = nil;
  __block id component = nil;
  
  dispatchSyncToCMQueue(^{
    cWrapper = [[self components] valueForKey:NSStringFromClass(componentClass)];
    if (!cWrapper) {
      [self registerComponentThisQueue:nil forClass:componentClass];
      cWrapper = [[self components] valueForKey:NSStringFromClass(componentClass)];
    }
  });
  
  if (cWrapper) {
    [cWrapper dispatchSyncToQueue:^{
      component = cWrapper.component;
      if (!component) {
        // by default, if there wasn't one already, get the shared instance for the given class and register it under its own class
        if ([componentClass conformsToProtocol:@protocol(SBBComponent)]) {
          component = [(id<SBBComponent>)componentClass defaultComponent];
          [self registerComponentThisQueue:component forClass:componentClass];
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
