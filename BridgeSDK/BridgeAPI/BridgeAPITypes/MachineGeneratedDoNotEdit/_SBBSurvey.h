//
//  _SBBSurvey.h
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
// Make changes to SBBSurvey.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@class SBBSurveyElement;

@protocol _SBBSurvey

@end

@interface _SBBSurvey : SBBBridgeObject

@property (nonatomic, strong) NSString* copyrightNotice;

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* modifiedOn;

@property (nonatomic, strong) NSString* moduleId;

@property (nonatomic, strong) NSNumber* moduleVersion;

@property (nonatomic, assign) int64_t moduleVersionValue;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSNumber* published;

@property (nonatomic, assign) BOOL publishedValue;

@property (nonatomic, strong) NSNumber* schemaRevision;

@property (nonatomic, assign) double schemaRevisionValue;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) double versionValue;

@property (nonatomic, strong, readonly) NSArray *elements;

- (void)addElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse;
- (void)addElementsObject:(SBBSurveyElement*)value_;
- (void)removeElementsObjects;
- (void)removeElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse;
- (void)removeElementsObject:(SBBSurveyElement*)value_;

- (void)insertObject:(SBBSurveyElement*)value inElementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx;
- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeElementsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value;
- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)values;

@end
