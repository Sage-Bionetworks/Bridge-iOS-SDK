//
//  _SBBSurveyResponse.h
//
//	Copyright (c) 2014-2016 Sage Bionetworks
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
// Make changes to SBBSurveyResponse.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBSurveyAnswer;
@class SBBSurvey;

@protocol _SBBSurveyResponse

@end

@interface _SBBSurveyResponse : SBBBridgeObject

@property (nonatomic, strong) NSDate* completedOn;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* startedOn;

@property (nonatomic, strong) NSString* status;

@property (nonatomic, strong, readonly) NSArray *answers;

@property (nonatomic, strong, readwrite) SBBSurvey *survey;

- (void)addAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: (BOOL) setInverse;
- (void)addAnswersObject:(SBBSurveyAnswer*)value_;
- (void)removeAnswersObjects;
- (void)removeAnswersObject:(SBBSurveyAnswer*)value_ settingInverse: (BOOL) setInverse;
- (void)removeAnswersObject:(SBBSurveyAnswer*)value_;

- (void)insertObject:(SBBSurveyAnswer*)value inAnswersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx;
- (void)insertAnswers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(SBBSurveyAnswer*)value;
- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)values;

- (void) setSurvey: (SBBSurvey*) survey_ settingInverse: (BOOL) setInverse;

@end
