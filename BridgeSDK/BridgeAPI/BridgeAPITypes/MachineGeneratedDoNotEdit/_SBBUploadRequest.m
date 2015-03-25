//
//  SBBUploadRequest.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUploadRequest.h instead.
//

#import "_SBBUploadRequest.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@interface _SBBUploadRequest()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (UploadRequest)

@property (nonatomic, strong) NSNumber* contentLength;

@property (nonatomic, assign) int64_t contentLengthValue;

@property (nonatomic, strong) NSString* contentMd5;

@property (nonatomic, strong) NSString* contentType;

@property (nonatomic, strong) NSString* name;

@end

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

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"UploadRequest" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.contentLength = managedObject.contentLength;

        self.contentMd5 = managedObject.contentMd5;

        self.contentType = managedObject.contentType;

        self.name = managedObject.name;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UploadRequest" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    managedObject.contentLength = self.contentLength;

    managedObject.contentMd5 = self.contentMd5;

    managedObject.contentType = self.contentType;

    managedObject.name = self.name;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
