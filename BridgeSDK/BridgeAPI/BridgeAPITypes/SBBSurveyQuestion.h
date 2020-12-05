//
//  SBBSurveyQuestion.h
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

#import <BridgeSDK/_SBBSurveyQuestion.h>
#import <BridgeSDK/SBBDefines.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * SBBUIHintType NS_STRING_ENUM;

ENUM_EXTERN SBBUIHintType const SBBUIHintTypeBloodPressure;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeCheckbox;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeCombobox;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeDatePicker;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeDateTimePicker;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeHeight;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeList;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeMultilineText;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeNumberfield;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeRadioButton;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeSelect;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeSlider;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeTextfield;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeTimePicker;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeToggle;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeWeight;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeYearMonth;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypeYear;
ENUM_EXTERN SBBUIHintType const SBBUIHintTypePostalCode;

@interface SBBSurveyQuestion : _SBBSurveyQuestion <_SBBSurveyQuestion>

@property (nonatomic, nullable, readonly, strong) SBBUIHintType uiHintValue;

@end

NS_ASSUME_NONNULL_END
