//
//  _SBBAbstractStudyParticipant.h
//
//	Copyright (c) 2014-2018 Sage Bionetworks
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
// Make changes to SBBAbstractStudyParticipant.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

#import "SBBStudyParticipantCustomAttributes.h"

NS_ASSUME_NONNULL_BEGIN

@class SBBPhone;

@protocol _SBBAbstractStudyParticipant

@end

@interface _SBBAbstractStudyParticipant : SBBBridgeObject

@property (nullable, nonatomic, strong) SBBStudyParticipantCustomAttributes* attributes;

@property (nullable, nonatomic, strong) id<SBBJSONValue> clientData;

@property (nullable, nonatomic, strong, readonly) NSDate* createdOn;

@property (nullable, nonatomic, strong) NSSet<NSString *>* dataGroups;

@property (nullable, nonatomic, strong) NSString* email;

@property (nullable, nonatomic, strong) NSNumber* emailVerified;

@property (nonatomic, assign) BOOL emailVerifiedValue;

@property (nullable, nonatomic, strong) NSString* externalId;

@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, NSString *>* externalIds;

@property (nullable, nonatomic, strong) NSString* firstName;

@property (nullable, nonatomic, strong, readonly) NSString* id;

@property (nullable, nonatomic, strong) NSArray<NSString *>* languages;

@property (nullable, nonatomic, strong) NSString* lastName;

@property (nullable, nonatomic, strong) NSNumber* notifyByEmail;

@property (nonatomic, assign) BOOL notifyByEmailValue;

@property (nullable, nonatomic, strong) NSNumber* phoneVerified;

@property (nonatomic, assign) BOOL phoneVerifiedValue;

@property (nullable, nonatomic, strong) NSArray<NSString *>* roles;

@property (nullable, nonatomic, strong) NSString* sharingScope;

@property (nullable, nonatomic, strong) NSString* status;

@property (nullable, nonatomic, strong) NSArray<NSString *>* substudyIds;

@property (nullable, nonatomic, strong, readwrite) SBBPhone *phone;

- (void) setPhone: (SBBPhone* _Nullable) phone_ settingInverse: (BOOL) setInverse;

@end
NS_ASSUME_NONNULL_END
