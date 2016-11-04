//
//  SBBParticipantManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 11/3/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIManager.h"

/*!
 * @typedef SBBParticipantDataSharingScope
 * @brief An enumeration of the choices for the scope of sharing collected data.
 * @constant SBBParticipantDataSharingScopeNone The study participant has not consented to sharing their data.
 * @constant SBBParticipantDataSharingScopeStudy The study participant has consented only to sharing their de-identified data with the sponsors and partners of the current research study.
 * @constant SBBParticipantDataSharingScopeAll The study participant has consented to sharing their de-identified data for current and future research, which may or may not involve the same institutions or investigators.
 */
typedef NS_ENUM(NSInteger, SBBParticipantDataSharingScope) {
    SBBParticipantDataSharingScopeNone = 0,
    SBBParticipantDataSharingScopeStudy,
    SBBParticipantDataSharingScopeAll
};

/*!
 Completion block called when retrieving participant record from the API.
 
 @param studyParticipant By default, an SBBStudyParticipant object, unless the StudyParticipant type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBParticipantManagerGetRecordCompletionBlock)(id studyParticipant, NSError *error);

/*!
 Completion block called when retrieving data groups from the API.
 
 @param dataGroups By default, an SBBDataGroups object, unless the DataGroups type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error      An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBParticipantManagerGetGroupsCompletionBlock)(id dataGroups, NSError *error);

/*!
 Completion block called when making other calls to the participants API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBParticipantManagerCompletionBlock)(id responseObject, NSError *error);

@protocol SBBParticipantManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 *  Fetch the StudyParticipant record from the Bridge API.
 *
 *  @param completion An SBBParticipantManagerGetRecordCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)getParticipantRecordWithCompletion:(SBBParticipantManagerGetRecordCompletionBlock)completion;

/*!
 *  Update the StudyParticipant record to the Bridge API.
 *
 *  @param participant A client object representing the StudyParticipant record as it should be updated.
 *  @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)updateParticipantRecordWithRecord:(id)participant completion:(SBBParticipantManagerCompletionBlock)completion;

/*!
 *  Add an external identifier for a participant.
 *
 *  This is a convenience method that sets the participant record's externalId field and updates it to Bridge.
 *
 *  @note Mainly intended as a quick replacement for the deprecated SBBUserManager addExternalIdentifier:completion: method. Generally you would have the participant enter their externalId during the onboarding process and include it when calling SBBAuthManager signUpStudyParticipant:withPassword:completion:.
 *
 *  @param externalID An external identifier to allow this participant to be tracked outside of the Bridge-specific study.
 *  @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)setExternalIdentifier:(NSString *)externalID completion:(SBBParticipantManagerCompletionBlock)completion;

/*!
 *  Change the scope of data sharing for this user.
 *  This is a convenience method that sets the participant record's sharingScope field and updates it to Bridge.
 *  This should only be done in response to an explicit choice on the part of the user to change the sharing scope.
 *
 *  @note Replaces deprecated SBBUserManager dataSharing:completion: method.
 *
 *  @param scope The scope of data sharing to set for this user.
 *
 *  @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)setSharingScope:(SBBParticipantDataSharingScope)scope completion:(SBBParticipantManagerCompletionBlock)completion;

/*!
 Fetch the data groups to which this user belongs from the Bridge API.
 This is a convenience method which fetches the StudyParticipant record (from cache, if available)
 and passes its dataGroups to the completion handler.
 
 @param completion An SBBParticipantManagerGetGroupsCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)getDataGroupsWithCompletion:(SBBParticipantManagerGetGroupsCompletionBlock)completion;

/*!
 Update the user's dataGroups to the Bridge API.
 
 This method writes a StudyParticipant record consisting of just the dataGroups field to the Bridge server.
 You may set the dataGroups directly as part of the StudyParticipant record when signing up for a Bridge account,
 but afterward should always update them via this method or one of the convenience methods that calls it
 (see note below about cached scheduled activities).
 
 @note If using caching, be aware that calling this method (or any of the convenience methods which call it) will remove unexpired, unfinished scheduled activities from the cache. The next call to get scheduled activities will replace them with the correct schedule going forward for the new set of data groups. If you're not using the SDK's built-in caching, you will need to take care of this yourself.
 
 @param dataGroups A client object representing the dataGroups as they should be updated.
 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionTask *)updateDataGroupsWithGroups:(id)dataGroups completion:(SBBParticipantManagerCompletionBlock)completion;

/*!
 Add the user to the specified data groups (tags).
 
 @param dataGroups  The data groups to which to add the user. This is a convenience method which first calls getDataGroupsWithCompletion:, and in its completion handler, adds the specified groups to the returned dataGroups and posts the modified dataGroups back to the Bridge API via updateDataGroupWithGroups:completion:. If there is an error fetching the user's existing dataGroups, that error will be passed to the completion handler. If an attempt is made to add a user to one or more data groups that haven't first been defined in the study, the Bridge API will respond with 400 (Bad Request) with an error message detailing the problem in the body of the response.
 @param completion An SBBUserManagerCompletionBlock to be called upon completion.
 */
- (void)addToDataGroups:(NSArray<NSString *> *)dataGroups completion:(SBBParticipantManagerCompletionBlock)completion;

/*!
 Remove the user from the specified data groups (tags).
 
 @param dataGroups  The data groups from which to remove the user. This is a convenience method which first calls getDataGroupsWithCompletion:, and in its completion handler, removes the specified groups from the returned dataGroups and posts the modified dataGroups back to the Bridge API via updateDataGroupWithGroups:completion:. If there is an error fetching the user's existing dataGroups, that error will be passed to the completion handler. If the fetch succeeds but the user is not a member of one or more of these data groups, whether because they haven't been added or because they don't exist in the study, this method will complete without updating the user's dataGroups and without an error.
 @param completion An SBBUserManagerCompletionBlock to be called upon completion.
 */
- (void)removeFromDataGroups:(NSArray<NSString *> *)dataGroups completion:(SBBParticipantManagerCompletionBlock)completion;

@end

@interface SBBParticipantManager : SBBBridgeAPIManager<SBBComponent, SBBParticipantManagerProtocol>

@end
