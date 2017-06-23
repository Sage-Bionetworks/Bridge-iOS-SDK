//
//  SBBParticipantManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 11/3/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "SBBParticipantManagerInternal.h"
#import "ModelObjectInternal.h"
#import "SBBObjectManagerInternal.h"
#import "SBBUserSessionInfo.h"
#import "SBBUserManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManagerInternal.h"

#define PARTICIPANT_API V3_API_PREFIX @"/participants/self"

NSString * const kSBBParticipantAPI = PARTICIPANT_API;

NSString * const kSBBParticipantDataSharingScopeStrings[] = {
    @"no_sharing",
    @"sponsors_and_partners",
    @"all_qualified_researchers"
};

@implementation SBBParticipantManager

@synthesize activityManager = _activityManager;

+ (instancetype)defaultComponent
{
    static SBBParticipantManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self instanceWithRegisteredDependencies];
    });
    
    return shared;
}

+ (NSArray<NSString *> *)dataSharingScopeStrings
{
    static NSArray<NSString *> *scopeStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *scopeArray = [NSMutableArray arrayWithCapacity:sizeof(kSBBParticipantDataSharingScopeStrings)];
        for (int i = 0; i < sizeof(kSBBParticipantDataSharingScopeStrings); ++i) {
            scopeArray[i] = kSBBParticipantDataSharingScopeStrings[i];
        }
        scopeStrings = [scopeArray copy];
    });
    
    return scopeStrings;
}

- (id<SBBActivityManagerInternalProtocol>)activityManager
{
    if (!_activityManager) {
        _activityManager = (id<SBBActivityManagerInternalProtocol>)SBBComponent(SBBActivityManager);
    }
    
    return _activityManager;
}

- (void)clearUserInfoFromCache
{
    NSString *participantType = [SBBStudyParticipant entityName];
    
    // remove it from cache. note: we use the Bridge type (which is the same as the CoreData entity name) as the unique key
    // to treat a class as a singleton for caching purposes.
    [self.cacheManager removeFromCacheObjectOfType:participantType withId:participantType];
}

- (NSURLSessionTask *)getParticipantRecordFromBridgeWithCompletion:(SBBParticipantManagerGetRecordCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager get:kSBBParticipantAPI headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        id participant = [self.objectManager objectFromBridgeJSON:responseObject];
        
        if (completion) {
            completion(participant, error);
        }
    }];
}

- (id)mappedCachedParticipant
{
    NSString *participantType = [SBBStudyParticipant entityName];
    SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedSingletonObjectOfType:participantType createIfMissing:NO];
    id participant = [(id<SBBObjectManagerInternalProtocol>)self.objectManager mappedObjectForBridgeObject:cachedParticipant];
    return participant;
}

- (NSURLSessionTask *)getParticipantRecordWithCompletion:(SBBParticipantManagerGetRecordCompletionBlock)completion
{
    if (gSBBUseCache) {
        // fetch from cache
        __block id participant = [self mappedCachedParticipant];
        
        id<SBBAuthManagerInternalProtocol> iAM = (id<SBBAuthManagerInternalProtocol>)self.authManager;
        if ([iAM conformsToProtocol:@protocol(SBBAuthManagerInternalProtocol)] &&
            iAM.isAuthenticated &&
            !participant) {
            // if we're signed in but the participant record is missing from cache, most likely this
            // means we've just upgraded to the version of this framework that supports StudyParticipant
            // records and we need to go fetch it. We could just specifically get the participant record
            // from Bridge as below in the non-caching case, but if in fact we've just upgraded to this
            // version, we also need to make sure the UserSessionInfo is up-to-date, so we'll re-sign-in
            // using the saved credentials.
            return [iAM attemptSignInWithStoredCredentialsWithCompletion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
                if (!error) {
                    participant = [self mappedCachedParticipant];
                }
                
                if (completion) {
                    completion(participant, error);
                }
            }];
        }
        
        if (completion) {
            completion(participant, nil);
        }
        
        return nil;
    } else {
        // fetch from the server
        return [self getParticipantRecordFromBridgeWithCompletion:completion];
    }
}

- (NSURLSessionTask *)updateParticipantJSONToBridge:(id)json completion:(SBBParticipantManagerCompletionBlock)completion
{
    if (!self.authManager.isAuthenticated) {
        if (completion) {
            completion(nil, nil);
        }
        return nil;
    }
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager post:kSBBParticipantAPI headers:headers parameters:json background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (!error && [responseObject[NSStringFromSelector(@selector(type))] isEqualToString:[SBBUserSessionInfo entityName]]) {
            // successfully updated the participant object to Bridge; now clear it from cache...
            [(id <SBBUserManagerInternalProtocol>)SBBComponent(SBBUserManager) clearUserInfoFromCache];
            [(id <SBBParticipantManagerInternalProtocol>)SBBComponent(SBBParticipantManager) clearUserInfoFromCache];
            
            // ...and re-create it from the UserSessionInfo in the response, and notify the auth delegate
            id sessionInfo = [self.objectManager objectFromBridgeJSON:responseObject];
            [(id<SBBAuthManagerInternalProtocol>)(self.authManager) notifyDelegateOfNewSessionInfo:sessionInfo];
        }
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)updateParticipantRecordWithRecord:(id)participant completion:(SBBParticipantManagerCompletionBlock)completion
{
    id participantJSON = [self.objectManager bridgeJSONFromObject:participant];
    if (gSBBUseCache && self.authManager.isAuthenticated) {
        NSString *participantType = [SBBStudyParticipant entityName];
        SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedSingletonObjectOfType:participantType createIfMissing:NO];
        if (participant) {
            // Double-check that what was passed in was the singleton instance of the SBBStudyParticipant object from
            // in-memory cache, and if it was, update it to CoreData before sending off to Bridge.
            if (participant == cachedParticipant) {
                [participant saveToCoreDataCacheWithObjectManager:self.objectManager];
            }
        } else {
            // nil parameter means sync the cached StudyParticipant object to Bridge
            participantJSON = [self.objectManager bridgeJSONFromObject:cachedParticipant];
        }
    }

    if (!participantJSON) {
        NSLog(@"Unable to create Bridge JSON from %@", participant);
        return nil;
    }

    // update it to Bridge
    return [self updateParticipantJSONToBridge:participantJSON completion:completion];
}

- (NSDictionary *)bridgeJSONForParticipantWithField:(NSString *)fieldName setTo:(id)value
{
    // If it's null, we want to send json null to the endpoint, to clear the value there. The participants
    // endpoint accepts partial JSON and ignores missing values.
    id (^jsonValue)() = ^id(){
        return (value == nil) ? [NSNull null] : [self.objectManager bridgeJSONFromObject:value];
    };
    
    NSDictionary *bridgeJSON = nil;
    NSString *participantType = [SBBStudyParticipant entityName];
    if (gSBBUseCache) {
        // set it on the cached object first
        NSString *participantType = [SBBStudyParticipant entityName];
        SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedSingletonObjectOfType:participantType createIfMissing:NO];
        [cachedParticipant setValue:value forKey:fieldName];
        [cachedParticipant saveToCoreDataCacheWithObjectManager:self.objectManager];
        bridgeJSON = [self.objectManager bridgeJSONFromObject:cachedParticipant];
        if (!value) {
            NSMutableDictionary *mutableBridgeJSON = [bridgeJSON mutableCopy];
            mutableBridgeJSON[fieldName] = jsonValue();
            bridgeJSON = [mutableBridgeJSON copy];
        }
    }
    
    // If something went wrong with the cached participant *or* caching isn't used,
    // then just include the values that are changed.
    if (!bridgeJSON) {
        bridgeJSON = @{fieldName: jsonValue(), @"type": participantType};
    }
    
    return bridgeJSON;
}

- (NSURLSessionTask *)setExternalIdentifier:(NSString *)externalID completion:(SBBParticipantManagerCompletionBlock)completion
{
    NSDictionary *bridgeJSON = [self bridgeJSONForParticipantWithField:NSStringFromSelector(@selector(externalId)) setTo:externalID];
    
    // update it to Bridge
    return [self updateParticipantJSONToBridge:bridgeJSON completion:completion];
}

- (NSURLSessionTask *)setSharingScope:(SBBParticipantDataSharingScope)scope completion:(SBBParticipantManagerCompletionBlock)completion
{
    NSDictionary *bridgeJSON = [self bridgeJSONForParticipantWithField:NSStringFromSelector(@selector(sharingScope)) setTo:kSBBParticipantDataSharingScopeStrings[scope]];
    
    // update it to Bridge
    return [self updateParticipantJSONToBridge:bridgeJSON completion:completion];
}

- (NSURLSessionTask *)getDataGroupsWithCompletion:(SBBParticipantManagerGetGroupsCompletionBlock)completion
{
    NSSet<NSString *> *dataGroups = nil;
    if (gSBBUseCache) {
        // get the data groups from the cached StudyParticipant
        NSString *participantType = [SBBStudyParticipant entityName];
        SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedSingletonObjectOfType:participantType createIfMissing:NO];
        dataGroups = cachedParticipant.dataGroups;
        completion(dataGroups, nil);
    } else {
        // fetch the StudyParticipant from Bridge 
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [self.authManager addAuthHeaderToHeaders:headers];
        return [self.networkManager get:kSBBParticipantAPI headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            // use a fresh object manager so we know there are no mappings going on
            SBBStudyParticipant *participant = [[SBBObjectManager objectManager] objectFromBridgeJSON:responseObject];
            if (![participant isKindOfClass:[SBBStudyParticipant class]]) {
                participant = nil;
            }
            completion(participant.dataGroups, error);
        }];
    }
    
    return nil;
}

- (NSURLSessionTask *)updateDataGroupsWithGroups:(NSSet<NSString *> *)dataGroups completion:(SBBParticipantManagerCompletionBlock)completion
{
    NSDictionary *bridgeJSON = [self bridgeJSONForParticipantWithField:NSStringFromSelector(@selector(dataGroups)) setTo:dataGroups];
    
    // update it to Bridge
    return [self updateParticipantJSONToBridge:bridgeJSON completion:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            // updating data groups generally invalidates your schedule so we need to flush the cache
            if ([self.activityManager respondsToSelector:@selector(flushUncompletedActivities)]) {
                [self.activityManager flushUncompletedActivities];
            }
        }
        
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)addToDataGroups:(NSSet<NSString *> *)dataGroups completion:(SBBParticipantManagerCompletionBlock)completion
{
    return [self getDataGroupsWithCompletion:^(NSSet<NSString *> * _Nullable oldGroups, NSError * _Nullable error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        if ([dataGroups isSubsetOfSet:oldGroups]) {
            // we're already in all the groups being added, so short-circuit out of here
            if (completion) {
                completion(nil, nil);
            }
            return;
        }
        
        NSSet<NSString *> *newGroups = [oldGroups setByAddingObjectsFromSet:dataGroups];
        [self updateDataGroupsWithGroups:newGroups completion:completion];
    }];
}

- (NSURLSessionTask *)removeFromDataGroups:(NSSet<NSString *> *)dataGroups completion:(SBBParticipantManagerCompletionBlock)completion
{
    return [self getDataGroupsWithCompletion:^(NSSet<NSString *> * _Nullable oldGroups, NSError * _Nullable error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        if (![oldGroups intersectsSet:dataGroups]) {
            // we're not in any of the groups being removed, so short-circuit out of here
            if (completion) {
                completion(nil, nil);
            }
            return;
        }
        
        // remove the groups from the set and update to Bridge
        NSMutableSet<NSString *> *removeSet = [oldGroups mutableCopy];
        [removeSet minusSet:dataGroups];
        NSSet<NSString *> *newGroups = [removeSet copy];
        [self updateDataGroupsWithGroups:newGroups completion:completion];
    }];
}

@end
