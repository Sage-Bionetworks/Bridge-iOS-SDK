//
//  _SBBUploadRequest.m
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
// Make changes to SBBUploadRequest.m instead.
//

#import "_SBBUploadRequest.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBUploadRequest()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (UploadRequest)

@property (nullable, nonatomic, retain) NSNumber* contentLength;

@property (nullable, nonatomic, retain) NSString* contentMd5;

@property (nullable, nonatomic, retain) NSString* contentType;

@property (nullable, nonatomic, retain) NSString* name;

@end

@implementation _SBBUploadRequest

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (int64_t)contentLengthValue
{
	return [self.contentLength longLongValue];
}

- (void)setContentLengthValue:(int64_t)value_
{
	self.contentLength = [NSNumber numberWithLongLong:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.contentLength = [dictionary objectForKey:@"contentLength"];

    self.contentMd5 = [dictionary objectForKey:@"contentMd5"];

    self.contentType = [dictionary objectForKey:@"contentType"];

    self.name = [dictionary objectForKey:@"name"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.contentLength forKey:@"contentLength"];

    [dict setObjectIfNotNil:self.contentMd5 forKey:@"contentMd5"];

    [dict setObjectIfNotNil:self.contentType forKey:@"contentType"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

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
    return @"UploadRequest";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.contentLength = managedObject.contentLength;

        self.contentMd5 = managedObject.contentMd5;

        self.contentType = managedObject.contentType;

        self.name = managedObject.name;

    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UploadRequest" inManagedObjectContext:cacheContext];
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

    managedObject.contentLength = ((id)self.contentLength == [NSNull null]) ? nil : self.contentLength;

    managedObject.contentMd5 = ((id)self.contentMd5 == [NSNull null]) ? nil : self.contentMd5;

    managedObject.contentType = ((id)self.contentType == [NSNull null]) ? nil : self.contentType;

    managedObject.name = ((id)self.name == [NSNull null]) ? nil : self.name;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
