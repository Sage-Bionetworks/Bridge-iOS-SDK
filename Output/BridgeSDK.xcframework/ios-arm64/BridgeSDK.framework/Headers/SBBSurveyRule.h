//
//  SBBSurveyRule.h
//
//	Copyright (c) 2014, Sage Bionetworks
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

#import <BridgeSDK/_SBBSurveyRule.h>
#import <BridgeSDK/SBBDefines.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * SBBOperatorType NS_STRING_ENUM;

/// Used to denote that the rule applies when the user has *all* of the included `dataGroups`
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeAll; // ALL

/// Used to denote that the rule applies when the user has *any* of the included `dataGroups`
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeAny; // ANY

/// Used in direct navigation when the `skipTo` should always be applied.
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeAlways; // ALWAYS

/// Survey rule for checking if the skip identifier should apply if the answer was skipped
/// in which case the result answer value will be `nil`
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeSkip; //DE

/// The answer value is equal to the `matchingAnswer`.
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeEqual; //EQ

/// The answer value is *not* equal to the `matchingAnswer`.
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeNotEqual; //NE

/// The answer value is less than the `matchingAnswer`.
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeLessThan; //LT

/// The answer value is greater than the `matchingAnswer`.
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeGreaterThan; //GT

/// The answer value is less than or equal to the `matchingAnswer`.
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeLessThanEqual; //LE

/// The answer value is greater than or equal to the `matchingAnswer`.
ENUM_EXTERN SBBOperatorType const SBBOperatorTypeGreaterThanEqual; //GE

@interface SBBSurveyRule : _SBBSurveyRule <_SBBSurveyRule>

@property (nonatomic, readonly, strong) SBBOperatorType operatorType;

@end

NS_ASSUME_NONNULL_END
