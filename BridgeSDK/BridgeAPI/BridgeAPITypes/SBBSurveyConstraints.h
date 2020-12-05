//
//  SBBSurveyConstraints.h
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

#import <BridgeSDK/_SBBSurveyConstraints.h>
#import <BridgeSDK/SBBDefines.h>

NS_ASSUME_NONNULL_BEGIN


typedef NSString * SBBDataType NS_STRING_ENUM;

ENUM_EXTERN SBBDataType const SBBDataTypeString;
ENUM_EXTERN SBBDataType const SBBDataTypeInteger;
ENUM_EXTERN SBBDataType const SBBDataTypeDecimal;
ENUM_EXTERN SBBDataType const SBBDataTypeBoolean;
ENUM_EXTERN SBBDataType const SBBDataTypeDate;
ENUM_EXTERN SBBDataType const SBBDataTypeTime;
ENUM_EXTERN SBBDataType const SBBDataTypeDateTime;
ENUM_EXTERN SBBDataType const SBBDataTypeDuration;
ENUM_EXTERN SBBDataType const SBBDataTypeBloodPressure;
ENUM_EXTERN SBBDataType const SBBDataTypeHeight;
ENUM_EXTERN SBBDataType const SBBDataTypeWeight;
ENUM_EXTERN SBBDataType const SBBDataTypeYearMonth;
ENUM_EXTERN SBBDataType const SBBDataTypeYear;
ENUM_EXTERN SBBDataType const SBBDataTypePostalCode;


typedef NSString * SBBUnit NS_STRING_ENUM;

// Duration
ENUM_EXTERN SBBUnit const SBBUnitSeconds;
ENUM_EXTERN SBBUnit const SBBUnitMinutes;
ENUM_EXTERN SBBUnit const SBBUnitHours;
ENUM_EXTERN SBBUnit const SBBUnitDays;
ENUM_EXTERN SBBUnit const SBBUnitWeeks;
ENUM_EXTERN SBBUnit const SBBUnitMonths;
ENUM_EXTERN SBBUnit const SBBUnitYears;

// US Customary measures
ENUM_EXTERN SBBUnit const SBBUnitInches;
ENUM_EXTERN SBBUnit const SBBUnitFeet;
ENUM_EXTERN SBBUnit const SBBUnitYards;
ENUM_EXTERN SBBUnit const SBBUnitMiles;
ENUM_EXTERN SBBUnit const SBBUnitOunces;
ENUM_EXTERN SBBUnit const SBBUnitPounds;
ENUM_EXTERN SBBUnit const SBBUnitPints;
ENUM_EXTERN SBBUnit const SBBUnitQuarts;
ENUM_EXTERN SBBUnit const SBBUnitGallons;

// Metric measures
ENUM_EXTERN SBBUnit const SBBUnitCentimeters;
ENUM_EXTERN SBBUnit const SBBUnitMeters;
ENUM_EXTERN SBBUnit const SBBUnitKilometers;
ENUM_EXTERN SBBUnit const SBBUnitGrams;
ENUM_EXTERN SBBUnit const SBBUnitKilgrams;
ENUM_EXTERN SBBUnit const SBBUnitMilliliters;
ENUM_EXTERN SBBUnit const SBBUnitCubicCentimeters;
ENUM_EXTERN SBBUnit const SBBUnitLiters;
ENUM_EXTERN SBBUnit const SBBUnitCubicMeters;

// Pressure measures
ENUM_EXTERN SBBUnit const SBBUnitMillimetersOfMercury; //(mmHg)


@interface SBBSurveyConstraints : _SBBSurveyConstraints <_SBBSurveyConstraints>

@property (nonatomic, readonly, strong) SBBDataType dataTypeValue;

+ (SBBDataType)defaultDataType;

@end

NS_ASSUME_NONNULL_END
