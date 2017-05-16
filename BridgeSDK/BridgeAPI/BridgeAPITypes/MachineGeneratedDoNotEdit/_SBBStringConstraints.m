//
//  _SBBStringConstraints.m
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
// Make changes to SBBStringConstraints.m instead.
//

#import "_SBBStringConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBStringConstraints()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (StringConstraints)

@property (nullable, nonatomic, retain) NSNumber* maxLength;

@property (nullable, nonatomic, retain) NSNumber* minLength;

@property (nullable, nonatomic, retain) NSString* pattern;

@property (nullable, nonatomic, retain) NSString* patternErrorMessage;

@property (nullable, nonatomic, retain) NSString* patternPlaceholder;

@end

@implementation _SBBStringConstraints

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)maxLengthValue
{
	return [self.maxLength longLongValue];
}

- (void)setMaxLengthValue:(int64_t)value_
{
	self.maxLength = [NSNumber numberWithLongLong:value_];
}

- (int64_t)minLengthValue
{
	return [self.minLength longLongValue];
}

- (void)setMinLengthValue:(int64_t)value_
{
	self.minLength = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.maxLength = [dictionary objectForKey:@"maxLength"];

    self.minLength = [dictionary objectForKey:@"minLength"];

    self.pattern = [dictionary objectForKey:@"pattern"];

    self.patternErrorMessage = [dictionary objectForKey:@"patternErrorMessage"];

    self.patternPlaceholder = [dictionary objectForKey:@"patternPlaceholder"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.maxLength forKey:@"maxLength"];

    [dict setObjectIfNotNil:self.minLength forKey:@"minLength"];

    [dict setObjectIfNotNil:self.pattern forKey:@"pattern"];

    [dict setObjectIfNotNil:self.patternErrorMessage forKey:@"patternErrorMessage"];

    [dict setObjectIfNotNil:self.patternPlaceholder forKey:@"patternPlaceholder"];

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
    return @"StringConstraints";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.maxLength = managedObject.maxLength;

        self.minLength = managedObject.minLength;

        self.pattern = managedObject.pattern;

        self.patternErrorMessage = managedObject.patternErrorMessage;

        self.patternPlaceholder = managedObject.patternPlaceholder;

    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringConstraints" inManagedObjectContext:cacheContext];
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

    managedObject.maxLength = ((id)self.maxLength == [NSNull null]) ? nil : self.maxLength;

    managedObject.minLength = ((id)self.minLength == [NSNull null]) ? nil : self.minLength;

    managedObject.pattern = ((id)self.pattern == [NSNull null]) ? nil : self.pattern;

    managedObject.patternErrorMessage = ((id)self.patternErrorMessage == [NSNull null]) ? nil : self.patternErrorMessage;

    managedObject.patternPlaceholder = ((id)self.patternPlaceholder == [NSNull null]) ? nil : self.patternPlaceholder;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
