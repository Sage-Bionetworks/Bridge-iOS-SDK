//
//  SBBUploadRequest.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUploadRequest.h instead.
//

#import "_SBBUploadRequest.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBUploadRequest()

@end

/** \ingroup DataModel */

@implementation _SBBUploadRequest

- (instancetype)init
{
	if((self = [super init]))
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

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.contentLength = [dictionary objectForKey:@"contentLength"];

        self.contentMd5 = [dictionary objectForKey:@"contentMd5"];

        self.contentType = [dictionary objectForKey:@"contentType"];

        self.name = [dictionary objectForKey:@"name"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.contentLength forKey:@"contentLength"];

    [dict setObjectIfNotNil:self.contentMd5 forKey:@"contentMd5"];

    [dict setObjectIfNotNil:self.contentType forKey:@"contentType"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

@end
