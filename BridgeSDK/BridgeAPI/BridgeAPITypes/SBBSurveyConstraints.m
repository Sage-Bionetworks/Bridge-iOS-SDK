//
//  SBBSurveyConstraints.m
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

#import "SBBSurveyConstraints.h"

SBBDataType const SBBDataTypeString = @"string";
SBBDataType const SBBDataTypeInteger = @"integer";
SBBDataType const SBBDataTypeDecimal = @"decimal";
SBBDataType const SBBDataTypeBoolean = @"boolean";
SBBDataType const SBBDataTypeDate = @"date";
SBBDataType const SBBDataTypeTime = @"time";
SBBDataType const SBBDataTypeDateTime = @"datetime";
SBBDataType const SBBDataTypeDuration = @"duration";
SBBDataType const SBBDataTypeBloodPressure = @"bloodpressure";
SBBDataType const SBBDataTypeHeight = @"height";
SBBDataType const SBBDataTypeWeight = @"weight";
SBBDataType const SBBDataTypeYearMonth = @"yearmonth";
SBBDataType const SBBDataTypeYear = @"year";
SBBDataType const SBBDataTypePostalCode = @"postalcode";

// Duration
SBBUnit const SBBUnitSeconds = @"seconds";
SBBUnit const SBBUnitMinutes = @"minutes";
SBBUnit const SBBUnitHours = @"hours";
SBBUnit const SBBUnitDays = @"days";
SBBUnit const SBBUnitWeeks = @"weeks";
SBBUnit const SBBUnitMonths = @"months";
SBBUnit const SBBUnitYears = @"years";

// US Customary measures
SBBUnit const SBBUnitInches = @"inches";
SBBUnit const SBBUnitFeet = @"feet";
SBBUnit const SBBUnitYards = @"yards";
SBBUnit const SBBUnitMiles = @"miles";
SBBUnit const SBBUnitOunces = @"ounces";
SBBUnit const SBBUnitPounds = @"pounds";
SBBUnit const SBBUnitPints = @"pints";
SBBUnit const SBBUnitQuarts = @"quarts";
SBBUnit const SBBUnitGallons = @"gallons";

// Metric measures
SBBUnit const SBBUnitCentimeters = @"centimeters";
SBBUnit const SBBUnitMeters = @"meters";
SBBUnit const SBBUnitKilometers = @"kilometers";
SBBUnit const SBBUnitGrams = @"grams";
SBBUnit const SBBUnitKilgrams = @"kilograms";
SBBUnit const SBBUnitMilliliters = @"milliliters";
SBBUnit const SBBUnitCubicCentimeters = @"cubic_centimeters";
SBBUnit const SBBUnitLiters = @"liters";
SBBUnit const SBBUnitCubicMeters = @"cubic_meters";

// Pressure measures
SBBUnit const SBBUnitMillimetersOfMercury = @"millimeters_mercury"; //(mmHg)

@implementation SBBSurveyConstraints

#pragma mark Abstract method overrides

+ (SBBDataType)defaultDataType {
    return SBBDataTypeString;
}

- (SBBDataType)dataTypeValue {
    return [self.dataType lowercaseString] ? : [[self class] defaultDataType];
}

@end
