//
//  _SBBMultiValueConstraints.h
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
// Make changes to SBBMultiValueConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyConstraints.h"

@class SBBSurveyQuestionOption;

@protocol _SBBMultiValueConstraints

@end

@interface _SBBMultiValueConstraints : SBBSurveyConstraints

@property (nonatomic, strong) NSNumber* allowMultiple;

@property (nonatomic, assign) BOOL allowMultipleValue;

@property (nonatomic, strong) NSNumber* allowOther;

@property (nonatomic, assign) BOOL allowOtherValue;

@property (nonatomic, strong, readonly) NSArray *enumeration;

- (void)addEnumerationObject:(SBBSurveyQuestionOption*)value_ settingInverse: (BOOL) setInverse;
- (void)addEnumerationObject:(SBBSurveyQuestionOption*)value_;
- (void)removeEnumerationObjects;
- (void)removeEnumerationObject:(SBBSurveyQuestionOption*)value_ settingInverse: (BOOL) setInverse;
- (void)removeEnumerationObject:(SBBSurveyQuestionOption*)value_;

- (void)insertObject:(SBBSurveyQuestionOption*)value inEnumerationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEnumerationAtIndex:(NSUInteger)idx;
- (void)insertEnumeration:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEnumerationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEnumerationAtIndex:(NSUInteger)idx withObject:(SBBSurveyQuestionOption*)value;
- (void)replaceEnumerationAtIndexes:(NSIndexSet *)indexes withEnumeration:(NSArray *)values;

@end
