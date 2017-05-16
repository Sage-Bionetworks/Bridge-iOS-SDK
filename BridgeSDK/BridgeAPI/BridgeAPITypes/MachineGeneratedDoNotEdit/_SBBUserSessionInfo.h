//
//  _SBBUserSessionInfo.h
//
//	Copyright (c) 2014-2017 Sage Bionetworks
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
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUserSessionInfo.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBConsentStatus;
@class SBBStudyParticipant;

@protocol _SBBUserSessionInfo

@end

@interface _SBBUserSessionInfo : SBBBridgeObject

@property (nonatomic, strong) NSNumber* authenticated;

@property (nonatomic, assign) BOOL authenticatedValue;

@property (nonatomic, strong) NSNumber* consented;

@property (nonatomic, assign) BOOL consentedValue;

@property (nonatomic, strong) NSNumber* dataSharing;

@property (nonatomic, assign) BOOL dataSharingValue;

@property (nonatomic, strong) NSString* environment;

@property (nonatomic, strong) NSString* sessionToken;

@property (nonatomic, strong) NSNumber* signedMostRecentConsent;

@property (nonatomic, assign) BOOL signedMostRecentConsentValue;

@property (nonatomic, strong, readonly) NSDictionary *consentStatuses;

@property (nonatomic, strong, readwrite) SBBStudyParticipant *studyParticipant;

- (void)addConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: (BOOL) setInverse;
- (void)addConsentStatusesObject:(SBBConsentStatus*)value_;
- (void)removeConsentStatusesObjects;
- (void)removeConsentStatusesObject:(SBBConsentStatus*)value_ settingInverse: (BOOL) setInverse;
- (void)removeConsentStatusesObject:(SBBConsentStatus*)value_;

- (void) setStudyParticipant: (SBBStudyParticipant*) studyParticipant_ settingInverse: (BOOL) setInverse;

@end
