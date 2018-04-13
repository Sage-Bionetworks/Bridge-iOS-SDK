//
//  SBBTestAuthKeychainManager.m
//  BridgeSDK
//
//  Copyright (c) 2014-2018 Sage Bionetworks. All rights reserved.
//

#import "SBBTestAuthKeychainManager.h"

@implementation SBBTestAuthKeychainManager

- (instancetype)init
{
    if (self = [super init]) {
        [self clearKeychainStore];
    }
    return self;
}

- (void)clearKeychainStore
{
    _keychain = NSMutableDictionary.dictionary;
}

- (void)setKeysAndValues:(NSDictionary<NSString *,NSString *> *)keysAndValues
{
    NSArray *keys = keysAndValues.allKeys;
    for (NSString *key in keys) {
        NSString *value = keysAndValues[key];
        _keychain[key] = value;
    }
}

- (NSString *)valueForKey:(NSString *)key
{
    return _keychain[key];
}

- (void)removeValuesForKeys:(NSArray<NSString *> *)keys
{
    for (NSString *key in keys) {
        [_keychain removeObjectForKey:key];
    }
}

@end
