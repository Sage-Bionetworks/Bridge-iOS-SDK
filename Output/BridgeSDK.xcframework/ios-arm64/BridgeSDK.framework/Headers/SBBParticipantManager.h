//
//  SBBParticipantManager.h
//  BridgeSDK
//
//    Copyright (c) 2016-2018, Sage Bionetworks
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

#import <BridgeSDK/SBBBridgeAPIManager.h>
@class SBBReportData;
@protocol SBBJSONValue;

/*!
 @typedef SBBParticipantDataSharingScope
 @brief An enumeration of the choices for the scope of sharing collected data.
 @constant SBBParticipantDataSharingScopeNone The study participant has not consented to sharing their data.
 @constant SBBParticipantDataSharingScopeStudy The study participant has consented only to sharing their de-identified data with the sponsors and partners of the current research study.
 @constant SBBParticipantDataSharingScopeAll The study participant has consented to sharing their de-identified data for current and future research, which may or may not involve the same institutions or investigators.
 */
typedef NS_ENUM(NSInteger, SBBParticipantDataSharingScope) {
    SBBParticipantDataSharingScopeNone = 0,
    SBBParticipantDataSharingScopeStudy,
    SBBParticipantDataSharingScopeAll
};

/*!
 Completion block called when retrieving participant record from the cache or API.
 
 @param studyParticipant By default, an SBBStudyParticipant object, unless the StudyParticipant type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBParticipantManagerGetRecordCompletionBlock)(_Nullable id studyParticipant,  NSError * _Nullable error);

/*!
 Completion block called when retrieving a participant report from the cache or API.
 
 @param participantReport An array containing a time series of, by default, SBBReportData objects, unless the ReportData type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBParticipantManagerGetReportCompletionBlock)(NSArray * _Nullable participantReport,  NSError * _Nullable error);

/*!
 Completion block called when retrieving data groups from the API.
 
 @param dataGroups An NSSet containing the string values of the data groups.
 @param error      An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBParticipantManagerGetGroupsCompletionBlock)(NSSet<NSString *> * _Nullable dataGroups, NSError * _Nullable error);

/*!
 Completion block called when making other calls to the participants API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBParticipantManagerCompletionBlock)(_Nullable id responseObject, NSError * _Nullable error);

/*!
 This protocol defines the interface to the SBBParticipantManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBParticipantManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Fetch the StudyParticipant record from cache if caching is turned on, otherwise from the Bridge API. 
 
 Note that if BridgeSDK was initialized with caching, the StudyParticipant record will always exist in the cache
 once the client has signed in for the first time, and since StudyParticipant is client-updatable, the cached copy
 would take priority over whatever Bridge responded with, so with caching turned on, this method will never try to
 retrieve the StudyParticipant from Bridge.
 
 Note also that the UserSessionInfo object received from Bridge on signIn is a superset of StudyParticipant, and
 upon successful signIn, any existing StudyParticipant object is deleted from cache and re-created from the
 UserSessionInfo. If any changes are made to the StudyParticipant on the Bridge server that didn't come from this
 client, the client's sessionToken should be invalidated, forcing the client to sign back in and thus update its
 cached StudyParticipant from the server.

 @param completion An SBBParticipantManagerGetRecordCompletionBlock to be called upon completion.

 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)getParticipantRecordWithCompletion:(nullable SBBParticipantManagerGetRecordCompletionBlock)completion;

/*!
 Update the StudyParticipant record to the Bridge API.

 @param participant A client object representing the StudyParticipant record as it should be updated. If caching is enabled and you want to sync changes you've made to the local (cached) SBBStudyParticipant to Bridge, pass nil for this parameter.
 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.

 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)updateParticipantRecordWithRecord:(nullable id)participant completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Add an external identifier for a participant.

 This is a convenience method that sets the participant record's externalId field and updates it to Bridge.

 @note Mainly intended as a quick replacement for the deprecated SBBUserManager addExternalIdentifier:completion: method. Generally you would have the participant enter their externalId during the onboarding process and include it when calling SBBAuthManager signUpStudyParticipant:withPassword:completion:.

 @param externalID An external identifier to allow this participant to be tracked outside of the Bridge-specific study.
 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.

 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)setExternalIdentifier:(nullable NSString *)externalID completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Change the scope of data sharing for this participant.
 This is a convenience method that sets the participant record's sharingScope field and updates it to Bridge.
 This should only be done in response to an explicit choice on the part of the user to change the sharing scope.

 @note Replaces deprecated SBBUserManager dataSharing:completion: method.

 @param scope The scope of data sharing to set for this participant.

 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.

 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)setSharingScope:(SBBParticipantDataSharingScope)scope completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Fetch the data groups to which this participant belongs from the Bridge API.
 This is a convenience method which fetches the StudyParticipant record (from cache, if available, otherwise from Bridge)
 and passes its dataGroups to the completion handler.
 
 @param completion An SBBParticipantManagerGetGroupsCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)getDataGroupsWithCompletion:(nonnull SBBParticipantManagerGetGroupsCompletionBlock)completion;

/*!
 Update the participant's dataGroups to the Bridge API.
 
 This method writes a StudyParticipant record consisting of just the dataGroups field to the Bridge server.
 You may set the dataGroups directly as part of the StudyParticipant record when signing up for a Bridge account,
 but afterward should always update them via this method or one of the convenience methods that calls it
 (see note below about cached scheduled activities).
 
 @note If using caching, be aware that calling this method (or any of the convenience methods which call it) will remove unexpired, unfinished scheduled activities from the cache. The next call to get scheduled activities will replace them with the correct schedule going forward for the new set of data groups. If you're not using the SDK's built-in caching, you will need to take care of this yourself.
 
 @param dataGroups An NSSet of strings representing the dataGroups as they should be updated.
 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)updateDataGroupsWithGroups:(nonnull NSSet<NSString *> *)dataGroups completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Add the participant to the specified data groups (tags).
 
 @param dataGroups  The data groups to which to add the participant. This is a convenience method which first calls getDataGroupsWithCompletion:, and in its completion handler, adds the specified groups to the returned dataGroups and posts the modified dataGroups back to the Bridge API via updateDataGroupWithGroups:completion:. If there is an error fetching the participant's existing dataGroups, that error will be passed to the completion handler. If an attempt is made to add a participant to one or more data groups that haven't first been defined in the study, the Bridge API will respond with 400 (Bad Request) with an error message detailing the problem in the body of the response.
 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)addToDataGroups:(nonnull NSSet<NSString *> *)dataGroups completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Remove the participant from the specified data groups (tags).
 
 @param dataGroups  The data groups from which to remove the participant. This is a convenience method which first calls getDataGroupsWithCompletion:, and in its completion handler, removes the specified groups from the returned dataGroups and posts the modified dataGroups back to the Bridge API via updateDataGroupWithGroups:completion:. If there is an error fetching the participant's existing dataGroups, that error will be passed to the completion handler. If the fetch succeeds but the participant is not a member of one or more of these data groups, whether because they haven't been added or because they don't exist in the study, this method will complete without updating the participant's dataGroups and without an error.
 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)removeFromDataGroups:(nonnull NSSet<NSString *> *)dataGroups completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Get the specified report data items for the user over the given time span.
 
 With this version of the method, you specify the desired time range with NSDate objects and they are interpreted as millisecond timestamps marking the starting and ending points of the desired span. You should use this method for retrieving ReportData objects from reports that use dateTime timestamps.
 
 @param identifier      The report identifier.
 @param fromTimestamp   The start of the desired date range.
 @param toTimestamp     The end of the desired date range.
 @param completion      An SBBParticipantManagerGetReportCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)getReport:(nonnull NSString *)identifier fromTimestamp:(nonnull NSDate *)fromTimestamp toTimestamp:(nonnull NSDate *)toTimestamp completion:(nonnull SBBParticipantManagerGetReportCompletionBlock)completion;

/*!
 Get the specified report data items for the user over the given date range.
 
 With this version of the method, you specify the desired date range with NSDateComponents objects and they are interpreted as calendar dates marking the first and last dates (inclusive) for which ReportData objects are being requested. You should use this method for retrieving ReportData objects from reports that use localDate datestamps.
 
 @param identifier  The report identifier.
 @param fromDate    The first date to fetch.
 @param toDate      The last date to fetch.
 @param completion  An SBBParticipantManagerGetReportCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)getReport:(nonnull NSString *)identifier fromDate:(nonnull NSDateComponents *)fromDate toDate:(nonnull NSDateComponents *)toDate completion:(nonnull SBBParticipantManagerGetReportCompletionBlock)completion;

/*!
 Save the specified ReportData object to the given report identifier. Any existing ReportData for the specified report with the same date
 
 @note A ReportData Bridge object can have either a full ISO8601 timestamp, represented by the dateTime field, or a date-only "datestamp", represented by the localDate field. The date field of SBBReportData is an NSDate object, which represents the same time as, and serializes to/from JSON by copying, whichever of dateTime or localDate is set. To use the localDate (date-only) datestamp, use setDateComponents: and make sure the hour component of the date components is NSDateComponentUndefined (or nil in Swift). To use the dateTime timestamp, you can either set the date property with an NSDate (Date), or use the date components setter with a defined value for the hours component. Whichever you use, all ReportData records saved to a given report identifier should use the same one.
 @param reportData  An SBBReportData object to be saved.
 @param identifier  The identifier of the report to which this reportData is to be saved.
 @param completion An SBBParticipantManagerCompletionBlock to be called upon completion.
 
 @return An NSURLSessionTask object so you can cancel or suspend/resume the request.
 */
- (nullable NSURLSessionTask *)saveReportData:(nonnull SBBReportData *)reportData forReport:(nonnull NSString *)identifier completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Save the specified report JSON data to the given report identifier with the specified dateTime timestamp.
 
 This is a convenience method that builds an SBBReportData object and calls through to saveReportData:forReport:completion:.
 */
- (nullable NSURLSessionTask *)saveReportJSON:(nonnull id<SBBJSONValue>)reportJSON withDateTime:(nonnull NSDate *)dateTime forReport:(nonnull NSString *)identifier completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Save the specified report JSON data to the given report identifier with the specified localDate (date-only) datestamp. Any date components smaller than a day (hour, minute, etc.) will be ignored.
 
 This is a convenience method that builds an SBBReportData object and calls through to saveReportData:forReport:completion:.
 */

- (nullable NSURLSessionTask *)saveReportJSON:(nonnull id<SBBJSONValue>)reportJSON withLocalDate:(nonnull NSDateComponents *)dateComponents forReport:(nonnull NSString *)identifier completion:(nullable SBBParticipantManagerCompletionBlock)completion;

/*!
 Get the latest cached report data from the given report.
 
 @param identifier The identifier for the report to be searched.
 @param error A pointer to an NSError reference, which this method will fill in if there's an error processing the fetch request. Optional (as always).
 @return The SBBReportData object from the given report identifier with the most recent date.
 */
- (nullable SBBReportData *)getLatestCachedDataForReport:(nonnull NSString *)identifier error:(NSError * _Nullable * _Nullable)error;

@end

/*!
 This class handles communication with the Bridge Participants API, and with the client-facing participant reports
 endpoints (which for historical reasons still use the otherwise mostly-deprecated Users API).
 */
@interface SBBParticipantManager : SBBBridgeAPIManager<SBBComponent, SBBParticipantManagerProtocol>


/*!
 * Returns an array for mapping SBBParticipantDataSharingScope enum values to their Bridge string equivalents.
 */
+ (nonnull NSArray<NSString *> *)dataSharingScopeStrings;

@end
