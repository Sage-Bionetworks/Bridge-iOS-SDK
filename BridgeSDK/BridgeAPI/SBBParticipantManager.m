//
//  SBBParticipantManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 11/3/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "SBBParticipantManagerInternal.h"
#import "ModelObjectInternal.h"

@implementation SBBParticipantManager

+ (instancetype)defaultComponent
{
    static SBBParticipantManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

- (void)clearUserInfoFromCache
{
    NSString *participantType = [SBBStudyParticipant entityName];
    
    // remove it from cache. note: we use the Bridge type (which is the same as the CoreData entity name) as the unique key
    // to treat a class as a singleton for caching purposes.
    [self.cacheManager removeFromCacheObjectOfType:participantType withId:participantType];
}

@end
