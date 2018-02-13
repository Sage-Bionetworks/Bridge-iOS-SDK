//
//  SBBSurveyRule.m
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

#import "SBBSurveyRule.h"

/// Used to denote that the rule applies when the user has *all* of the included `dataGroups`
SBBOperatorType const SBBOperatorTypeAll = @"all";

/// Used to denote that the rule applies when the user has *any* of the included `dataGroups`
SBBOperatorType const SBBOperatorTypeAny = @"any";

/// Used in direct navigation when the `skipTo` should always be applied.
SBBOperatorType const SBBOperatorTypeAlways = @"always";

/// Survey rule for checking if the skip identifier should apply if the answer was skipped
/// in which case the result answer value will be `nil`
SBBOperatorType const SBBOperatorTypeSkip = @"de";

/// The answer value is equal to the `matchingAnswer`.
SBBOperatorType const SBBOperatorTypeEqual = @"eq";

/// The answer value is *not* equal to the `matchingAnswer`.
SBBOperatorType const SBBOperatorTypeNotEqual = @"ne";

/// The answer value is less than the `matchingAnswer`.
SBBOperatorType const SBBOperatorTypeLessThan = @"lt";

/// The answer value is greater than the `matchingAnswer`.
SBBOperatorType const SBBOperatorTypeGreaterThan = @"gt";

/// The answer value is less than or equal to the `matchingAnswer`.
SBBOperatorType const SBBOperatorTypeLessThanEqual = @"le";

/// The answer value is greater than or equal to the `matchingAnswer`.
SBBOperatorType const SBBOperatorTypeGreaterThanEqual = @"ge";

@implementation SBBSurveyRule

#pragma mark Abstract method overrides

- (SBBOperatorType) operatorType {
    return self.operator;
}

@end
