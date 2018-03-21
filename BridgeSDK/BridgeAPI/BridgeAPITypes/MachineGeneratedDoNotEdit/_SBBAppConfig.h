//
//  _SBBAppConfig.h
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
// Make changes to SBBAppConfig.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

#import "SBBJSONValue.h"

NS_ASSUME_NONNULL_BEGIN

@class SBBSchemaReference;
@class SBBSurveyReference;

@protocol _SBBAppConfig

@end

@interface _SBBAppConfig : SBBBridgeObject

@property (nullable, nonatomic, strong) id<SBBJSONValue> clientData;

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSString* guid;

@property (nullable, nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSDate* modifiedOn;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) int64_t versionValue;

@property (nullable, nonatomic, strong, readonly) NSArray *schemaReferences;

@property (nullable, nonatomic, strong, readonly) NSArray *surveyReferences;

- (void)addSchemaReferencesObject:(SBBSchemaReference*)value_ settingInverse: (BOOL) setInverse;
- (void)addSchemaReferencesObject:(SBBSchemaReference*)value_;
- (void)removeSchemaReferencesObjects;
- (void)removeSchemaReferencesObject:(SBBSchemaReference*)value_ settingInverse: (BOOL) setInverse;
- (void)removeSchemaReferencesObject:(SBBSchemaReference*)value_;

- (void)addSurveyReferencesObject:(SBBSurveyReference*)value_ settingInverse: (BOOL) setInverse;
- (void)addSurveyReferencesObject:(SBBSurveyReference*)value_;
- (void)removeSurveyReferencesObjects;
- (void)removeSurveyReferencesObject:(SBBSurveyReference*)value_ settingInverse: (BOOL) setInverse;
- (void)removeSurveyReferencesObject:(SBBSurveyReference*)value_;

@end
NS_ASSUME_NONNULL_END
