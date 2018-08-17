//
//  SBBParticipantManager.m
//  BridgeSDK
//
//    Copyright (c) 2016, Sage Bionetworks
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//        * Redistributions of source code must retain the above copyright
//          notice, this list of conditions and the following disclaimer.
//        * Redistributions in binary form must reproduce the above copyright
//          notice, this list of conditions and the following disclaimer in the
//          documentation and/or other materials provided with the distribution.
//        * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//          contributors may be used to endorse or promote products derived from
//          this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

#import "SBBParticipantManagerInternal.h"
#import "ModelObjectInternal.h"
#import "SBBObjectManagerInternal.h"
#import "SBBUserSessionInfo.h"
#import "SBBUserManagerInternal.h"
#import "SBBComponentManager.h"
#import "SBBAuthManagerInternal.h"
#import "SBBReportData.h"

#define PARTICIPANT_API V3_API_PREFIX @"/participants/self"
#define PARTICIPANT_REPORTS_API3_FORMAT V3_API_PREFIX @"/users/self/%@"
#define PARTICIPANT_REPORTS_API4_FORMAT V4_API_PREFIX @"/users/self/%@"

NSString * const kSBBParticipantAPI = PARTICIPANT_API;
NSString * const kSBBParticipantReportsAPI3Format = PARTICIPANT_REPORTS_API3_FORMAT;
NSString * const kSBBParticipantReportsAPI4Format = PARTICIPANT_REPORTS_API4_FORMAT;

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
            
            // ...and re-create it from the UserSessionInfo in the response, and notify subscribers
            id sessionInfo = [self.objectManager objectFromBridgeJSON:responseObject];
            [(id<SBBAuthManagerInternalProtocol>)(self.authManager) postNewSessionInfo:sessionInfo];
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

- (NSDate *)gregorianDateFromDateComponents:(NSDateComponents *)dateComponents
{
    static NSCalendar *gregorianCalendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    
    return [gregorianCalendar dateFromComponents:dateComponents];

}

- (NSString *)localDateStringFromDateComponents:(NSDateComponents *)dateComponents
{
    NSDate *date = [self gregorianDateFromDateComponents:dateComponents];
    return date.ISO8601DateOnlyString;
}

- (NSString *)listIdentifier
{
    return [SBBReportData entityName];
}

- (NSArray *)mappedObjectsInList:(NSArray *)list
{
    NSMutableArray *mappedList = [list mutableCopy];
    if ([self.objectManager conformsToProtocol:@protocol(SBBObjectManagerInternalProtocol)]) {
        // in case object mapping has been set up
        for (NSInteger i = 0; i < list.count; ++i) {
            mappedList[i] = [((id<SBBObjectManagerInternalProtocol>)self.objectManager) mappedObjectForBridgeObject:list[i]];
        }
    }
    
    return [mappedList copy];
}

- (NSURLSessionTask *)getReport:(NSString *)identifier fromDate:(NSDateComponents *)fromDate toDate:(NSDateComponents *)toDate completion:(SBBParticipantManagerGetReportCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    NSDate *startDate = [self localDateStringFromDateComponents:fromDate];
    NSDate *endDate = [self localDateStringFromDateComponents:toDate];
    NSDictionary *parameters = @{
                                 @"identifier": identifier,
                                 @"startDate": startDate,
                                 @"endDate": endDate
                                 };
    
    return [self.networkManager get:kSBBParticipantReportsAPI3Format headers:headers parameters:parameters background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        NSArray *reportItems = nil;
        if (!error) {
            NSDictionary *objectJSON = responseObject;
            if (gSBBUseCache) {
                // Set an identifier in the JSON so we can find the cached object later--since
                // ResourceList doesn't come with anything by which to distinguish one
                // from another if the items[] list is empty.
                NSMutableDictionary *objectWithListIdentifier = [responseObject mutableCopy];
                
                // -- get the identifier key path we need to set from the cache manager core data entity description
                //    rather than hardcoding it with a string literal
                NSEntityDescription *entityDescription = [SBBResourceList entityForContext:self.cacheManager.cacheIOContext];
                NSString *entityIDKeyPath = entityDescription.userInfo[@"entityIDKeyPath"];
                
                // -- set it in the JSON to this Participant Manager's list identifier
                [objectWithListIdentifier setValue:self.listIdentifier forKeyPath:entityIDKeyPath];
                objectJSON = [objectWithListIdentifier copy];
            }
            SBBResourceList *reportList = [self.objectManager objectFromBridgeJSON:objectJSON];
            reportItems = reportList.items;
        }
        
        // fall back to cache
        if (!reportItems && gSBBUseCache) {
            SBBResourceList *reportList = [self.cacheManager cachedObjectOfType:SBBResourceList.entityName withId:self.listIdentifier createIfMissing:NO];
            
            // filter to the desired localDate range. conveniently, ISO8601 dates (and times) can be compared as strings:
            // https://fits.gsfc.nasa.gov/iso-time.html
            NSString *localDateSelector = NSStringFromSelector(@selector(localDate));
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@ AND %K <= %@",
                                        localDateSelector, startDate,
                                        localDateSelector, endDate];
            reportItems = [reportList.items filteredArrayUsingPredicate:predicate];
            
            // cached items are unmapped so we need to map them before returning
            reportItems = [self mappedObjectsInList:reportItems];
        }
        
        if (completion) {
            completion(reportItems, error);
        }
    }];
}

- (NSURLSessionTask *)getReport:(NSString *)identifier fromTimestamp:(NSDate *)fromTimestamp toTimestamp:(NSDate *)toTimestamp completion:(SBBParticipantManagerGetReportCompletionBlock)completion
{
    
}

- (NSURLSessionTask *)saveReportData:(SBBReportData *)reportData forReport:(NSString *)identifier completion:(SBBParticipantManagerCompletionBlock)completion
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self.authManager addAuthHeaderToHeaders:headers];
    
    NSString *endpoint = [NSString stringWithFormat:kSBBParticipantReportsAPI4Format, identifier];
    NSDictionary *reportDataJSON = [self.objectManager bridgeJSONFromObject:reportData];
    
    return [self.networkManager post:endpoint headers:headers parameters:reportDataJSON background:YES completion:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if (completion) {
            completion(responseObject, error);
        }
    }];
}

- (NSURLSessionTask *)saveReportJSON:(id)reportJSON withDateTime:(NSDate *)dateTime forReport:(NSString *)identifier completion:(SBBParticipantManagerCompletionBlock)completion
{
    SBBReportData *reportData = [SBBReportData new];
    reportData.data = reportJSON;
    reportData.date = dateTime;
    return [self saveReportData:reportData forReport:identifier completion:completion];
}

- (NSURLSessionTask *)saveReportJSON:(id)reportJSON withLocalDate:(NSDateComponents *)dateComponents forReport:(NSString *)identifier completion:(SBBParticipantManagerCompletionBlock)completion
{
    SBBReportData *reportData = [SBBReportData new];
    reportData.data = reportJSON;
    [reportData setDateComponents:dateComponents];
    return [self saveReportData:reportData forReport:identifier completion:completion];
}

@end
