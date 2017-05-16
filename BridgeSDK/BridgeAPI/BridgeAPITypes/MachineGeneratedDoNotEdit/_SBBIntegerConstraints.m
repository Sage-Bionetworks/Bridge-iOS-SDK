//
//  _SBBIntegerConstraints.m
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
// Make changes to SBBIntegerConstraints.m instead.
//

#import "_SBBIntegerConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBIntegerConstraints()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (IntegerConstraints)

@property (nullable, nonatomic, retain) NSNumber* maxValue;

@property (nullable, nonatomic, retain) NSNumber* minValue;

@property (nullable, nonatomic, retain) NSNumber* step;

@property (nullable, nonatomic, retain) NSString* unit;

@end

@implementation _SBBIntegerConstraints

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)maxValueValue
{
	return [self.maxValue longLongValue];
}

- (void)setMaxValueValue:(int64_t)value_
{
	self.maxValue = [NSNumber numberWithLongLong:value_];
}

- (int64_t)minValueValue
{
	return [self.minValue longLongValue];
}

- (void)setMinValueValue:(int64_t)value_
{
	self.minValue = [NSNumber numberWithLongLong:value_];
}

- (int64_t)stepValue
{
	return [self.step longLongValue];
}

- (void)setStepValue:(int64_t)value_
{
	self.step = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.maxValue = [dictionary objectForKey:@"maxValue"];

    self.minValue = [dictionary objectForKey:@"minValue"];

    self.step = [dictionary objectForKey:@"step"];

    self.unit = [dictionary objectForKey:@"unit"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.maxValue forKey:@"maxValue"];

    [dict setObjectIfNotNil:self.minValue forKey:@"minValue"];

    [dict setObjectIfNotNil:self.step forKey:@"step"];

    [dict setObjectIfNotNil:self.unit forKey:@"unit"];

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
    return @"IntegerConstraints";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.maxValue = managedObject.maxValue;

        self.minValue = managedObject.minValue;

        self.step = managedObject.step;

        self.unit = managedObject.unit;

    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"IntegerConstraints" inManagedObjectContext:cacheContext];
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

    managedObject.maxValue = ((id)self.maxValue == [NSNull null]) ? nil : self.maxValue;

    managedObject.minValue = ((id)self.minValue == [NSNull null]) ? nil : self.minValue;

    managedObject.step = ((id)self.step == [NSNull null]) ? nil : self.step;

    managedObject.unit = ((id)self.unit == [NSNull null]) ? nil : self.unit;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
