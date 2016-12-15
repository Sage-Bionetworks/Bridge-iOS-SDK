//
//  SBBParticipantManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 11/3/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "SBBParticipantManagerInternal.h"
#import "ModelObjectInternal.h"

#define PARTICIPANT_API GLOBAL_API_PREFIX @"/participants/self"

NSString * const kSBBParticipantAPI = PARTICIPANT_API;

NSString * const kSBBParticipantDataSharingScopeStrings[] = {
    @"no_sharing",
    @"sponsors_and_partners",
    @"all_qualified_researchers"
};

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

- (NSURLSessionTask *)getParticipantRecordWithCompletion:(SBBParticipantManagerGetRecordCompletionBlock)completion
{
    if (gSBBUseCache) {
        // fetch from cache
        NSString *participantType = [SBBStudyParticipant entityName];
        SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedObjectOfType:participantType withId:participantType createIfMissing:NO];
        
        if (completion) {
            completion(cachedParticipant, nil);
        }
        
        return nil;
    } else {
        // fetch from the server
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [self.authManager addAuthHeaderToHeaders:headers];
        return [self.networkManager get:kSBBParticipantAPI headers:headers parameters:nil completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
            id participant = [self.objectManager objectFromBridgeJSON:responseObject];
            
            if (completion) {
                completion(participant, error);
            }
        }];
    }
}

- (NSURLSessionTask *)updateParticipantJSONToBridge:(id)json completion:(SBBParticipantManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    return [self.networkManager post:kSBBParticipantAPI headers:headers parameters:json background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)updateParticipantRecordWithRecord:(id)participant completion:(SBBParticipantManagerCompletionBlock)completion
{
    id participantJSON = [self.objectManager bridgeJSONFromObject:participant];
    if (gSBBUseCache) {
        if (!participant) {
            // sync the cached StudyParticipant object to Bridge
            NSString *participantType = [SBBStudyParticipant entityName];
            SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedObjectOfType:participantType withId:participantType createIfMissing:NO];
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
    id jsonValue = value ?: [NSNull null];
    NSDictionary *bridgeJSON = nil;
    NSString *participantType = [SBBStudyParticipant entityName];
    if (gSBBUseCache) {
        // set it on the cached object first
        NSString *participantType = [SBBStudyParticipant entityName];
        SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedObjectOfType:participantType withId:participantType createIfMissing:NO];
        [cachedParticipant setValue:value forKey:fieldName];
        [cachedParticipant saveToCoreDataCacheWithObjectManager:self.objectManager];
        bridgeJSON = [self.objectManager bridgeJSONFromObject:cachedParticipant];
        if (!value) {
            NSMutableDictionary *mutableBridgeJSON = [bridgeJSON mutableCopy];
            mutableBridgeJSON[fieldName] = jsonValue;
            bridgeJSON = [mutableBridgeJSON copy];
        }
    } else {
        bridgeJSON = @{fieldName: jsonValue, @"type": participantType};
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
        SBBStudyParticipant *cachedParticipant = (SBBStudyParticipant *)[self.cacheManager cachedObjectOfType:participantType withId:participantType createIfMissing:NO];
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
