//
//  _SBBRequestParams.h
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
// Make changes to SBBRequestParams.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@protocol _SBBRequestParams

@end

@interface _SBBRequestParams : SBBBridgeObject

@property (nonatomic, strong) NSNumber* assignmentFilter;

@property (nonatomic, assign) BOOL assignmentFilterValue;

@property (nonatomic, strong) NSString* emailFilter;

@property (nonatomic, strong) NSString* endDate;

@property (nonatomic, strong) NSString* endTime;

@property (nonatomic, strong) NSString* idFilter;

@property (nonatomic, strong) NSNumber* offsetBy;

@property (nonatomic, assign) int64_t offsetByValue;

@property (nonatomic, strong) NSString* offsetKey;

@property (nonatomic, strong) NSNumber* pageSize;

@property (nonatomic, assign) int64_t pageSizeValue;

@property (nonatomic, strong) NSString* reportType;

@property (nonatomic, strong) NSDate* scheduledOnEnd;

@property (nonatomic, strong) NSDate* scheduledOnStart;

@property (nonatomic, strong) NSString* startDate;

@property (nonatomic, strong) NSString* startTime;

@property (nonatomic, strong) NSNumber* total;

@property (nonatomic, assign) int64_t totalValue;

@end
