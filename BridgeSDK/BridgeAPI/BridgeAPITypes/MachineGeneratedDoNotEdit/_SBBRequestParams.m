//
//  _SBBRequestParams.m
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
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBRequestParams.m instead.
//

#import "_SBBRequestParams.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBRequestParams()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (RequestParams)

@property (nullable, nonatomic, retain) NSNumber* assignmentFilter;

@property (nullable, nonatomic, retain) NSString* emailFilter;

@property (nullable, nonatomic, retain) NSString* endDate;

@property (nullable, nonatomic, retain) NSString* endTime;

@property (nullable, nonatomic, retain) NSString* idFilter;

@property (nullable, nonatomic, retain) NSNumber* offsetBy;

@property (nullable, nonatomic, retain) NSString* offsetKey;

@property (nullable, nonatomic, retain) NSNumber* pageSize;

@property (nullable, nonatomic, retain) NSString* reportType;

@property (nullable, nonatomic, retain) NSDate* scheduledOnEnd;

@property (nullable, nonatomic, retain) NSDate* scheduledOnStart;

@property (nullable, nonatomic, retain) NSString* startDate;

@property (nullable, nonatomic, retain) NSString* startTime;

@property (nullable, nonatomic, retain) NSNumber* total;

@property (nullable, nonatomic, retain) NSManagedObject *requestParamsForwardCursorPagedResourceList;

@property (nullable, nonatomic, retain) NSManagedObject *requestParamsResourceList;

@end

@implementation _SBBRequestParams

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)assignmentFilterValue
{
	return [self.assignmentFilter boolValue];
}

- (void)setAssignmentFilterValue:(BOOL)value_
{
	self.assignmentFilter = [NSNumber numberWithBool:value_];
}

- (int64_t)offsetByValue
{
	return [self.offsetBy longLongValue];
}

- (void)setOffsetByValue:(int64_t)value_
{
	self.offsetBy = [NSNumber numberWithLongLong:value_];
}

- (int64_t)pageSizeValue
{
	return [self.pageSize longLongValue];
}

- (void)setPageSizeValue:(int64_t)value_
{
	self.pageSize = [NSNumber numberWithLongLong:value_];
}

- (int64_t)totalValue
{
	return [self.total longLongValue];
}

- (void)setTotalValue:(int64_t)value_
{
	self.total = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.assignmentFilter = [dictionary objectForKey:@"assignmentFilter"];

    self.emailFilter = [dictionary objectForKey:@"emailFilter"];

    self.endDate = [dictionary objectForKey:@"endDate"];

    self.endTime = [dictionary objectForKey:@"endTime"];

    self.idFilter = [dictionary objectForKey:@"idFilter"];

    self.offsetBy = [dictionary objectForKey:@"offsetBy"];

    self.offsetKey = [dictionary objectForKey:@"offsetKey"];

    self.pageSize = [dictionary objectForKey:@"pageSize"];

    self.reportType = [dictionary objectForKey:@"reportType"];

    self.scheduledOnEnd = [NSDate dateWithISO8601String:[dictionary objectForKey:@"scheduledOnEnd"]];

    self.scheduledOnStart = [NSDate dateWithISO8601String:[dictionary objectForKey:@"scheduledOnStart"]];

    self.startDate = [dictionary objectForKey:@"startDate"];

    self.startTime = [dictionary objectForKey:@"startTime"];

    self.total = [dictionary objectForKey:@"total"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.assignmentFilter forKey:@"assignmentFilter"];

    [dict setObjectIfNotNil:self.emailFilter forKey:@"emailFilter"];

    [dict setObjectIfNotNil:self.endDate forKey:@"endDate"];

    [dict setObjectIfNotNil:self.endTime forKey:@"endTime"];

    [dict setObjectIfNotNil:self.idFilter forKey:@"idFilter"];

    [dict setObjectIfNotNil:self.offsetBy forKey:@"offsetBy"];

    [dict setObjectIfNotNil:self.offsetKey forKey:@"offsetKey"];

    [dict setObjectIfNotNil:self.pageSize forKey:@"pageSize"];

    [dict setObjectIfNotNil:self.reportType forKey:@"reportType"];

    [dict setObjectIfNotNil:[self.scheduledOnEnd ISO8601String] forKey:@"scheduledOnEnd"];

    [dict setObjectIfNotNil:[self.scheduledOnStart ISO8601String] forKey:@"scheduledOnStart"];

    [dict setObjectIfNotNil:self.startDate forKey:@"startDate"];

    [dict setObjectIfNotNil:self.startTime forKey:@"startTime"];

    [dict setObjectIfNotNil:self.total forKey:@"total"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"RequestParams";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.assignmentFilter = managedObject.assignmentFilter;

        self.emailFilter = managedObject.emailFilter;

        self.endDate = managedObject.endDate;

        self.endTime = managedObject.endTime;

        self.idFilter = managedObject.idFilter;

        self.offsetBy = managedObject.offsetBy;

        self.offsetKey = managedObject.offsetKey;

        self.pageSize = managedObject.pageSize;

        self.reportType = managedObject.reportType;

        self.scheduledOnEnd = managedObject.scheduledOnEnd;

        self.scheduledOnStart = managedObject.scheduledOnStart;

        self.startDate = managedObject.startDate;

        self.startTime = managedObject.startTime;

        self.total = managedObject.total;

    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"RequestParams" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [cacheManager cachedObjectForBridgeObject:self inContext:cacheContext];
    if (managedObject) {
        [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    }

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    managedObject.assignmentFilter = ((id)self.assignmentFilter == [NSNull null]) ? nil : self.assignmentFilter;

    managedObject.emailFilter = ((id)self.emailFilter == [NSNull null]) ? nil : self.emailFilter;

    managedObject.endDate = ((id)self.endDate == [NSNull null]) ? nil : self.endDate;

    managedObject.endTime = ((id)self.endTime == [NSNull null]) ? nil : self.endTime;

    managedObject.idFilter = ((id)self.idFilter == [NSNull null]) ? nil : self.idFilter;

    managedObject.offsetBy = ((id)self.offsetBy == [NSNull null]) ? nil : self.offsetBy;

    managedObject.offsetKey = ((id)self.offsetKey == [NSNull null]) ? nil : self.offsetKey;

    managedObject.pageSize = ((id)self.pageSize == [NSNull null]) ? nil : self.pageSize;

    managedObject.reportType = ((id)self.reportType == [NSNull null]) ? nil : self.reportType;

    managedObject.scheduledOnEnd = ((id)self.scheduledOnEnd == [NSNull null]) ? nil : self.scheduledOnEnd;

    managedObject.scheduledOnStart = ((id)self.scheduledOnStart == [NSNull null]) ? nil : self.scheduledOnStart;

    managedObject.startDate = ((id)self.startDate == [NSNull null]) ? nil : self.startDate;

    managedObject.startTime = ((id)self.startTime == [NSNull null]) ? nil : self.startTime;

    managedObject.total = ((id)self.total == [NSNull null]) ? nil : self.total;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
