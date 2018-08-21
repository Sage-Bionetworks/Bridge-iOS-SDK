//
//  SBBReportData.m
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

#import "SBBReportData.h"
#import "NSDate+SBBAdditions.h"
#import "ModelObjectInternal.h"

@interface SBBReportData ()

@property (nonatomic, strong) NSDate *date_;

@end

@implementation SBBReportData

#pragma mark Abstract method overrides

// Custom logic goes here.
- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];
    
    // date (in JSON) should be a copy of either dateTime or localDate, whichever is set (only one will be)
    NSString *dateJSON = self.dateTime ?: self.localDate;
    [dict setObjectIfNotNil:dateJSON forKey:@"date"];
     
    return [dict copy];
}

- (NSDate *)date
{
    if (!self.date_) {
        NSString *dateString = self.dateTime ?: self.localDate;
        self.date_ = [NSDate dateWithISO8601String:dateString];
    }
    
    return self.date_;
}

- (void)setDate:(NSDate *)date
{
    self.date_ = date;
    super.dateTime = date.ISO8601StringUTC;
    super.localDate = nil;
}

- (void)setDateComponents:(NSDateComponents *)dateComponents
{
    static NSCalendar *gregorianCalendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    
    NSDate *date = [gregorianCalendar dateFromComponents:dateComponents];
    
    // if the hour component isn't set, treat it as localDate; if it is, use dateTime instead
    if ([dateComponents valueForComponent:NSCalendarUnitHour] == NSDateComponentUndefined) {
        self.localDate = date.ISO8601DateOnlyString;
    } else {
        self.dateTime = date.ISO8601StringUTC;
    }
}

- (void)setDateTime:(NSString *)dateTime
{
    super.dateTime = dateTime;
    if (dateTime) {
        super.localDate = nil;
        self.date_ = nil;
    }
}

- (void)setLocalDate:(NSString *)localDate
{
    super.localDate = localDate;
    if (localDate) {
        super.dateTime = nil;
        self.date_ = nil;
    }
}

@end
