//
//  SBBSurveyAnswer.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyAnswer.h instead.
//

#import "_SBBSurveyAnswer.h"
#import "_SBBSurveyAnswerInternal.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "RNEncryptor.h"
#import "RNDecryptor.h"

@interface _SBBSurveyAnswer()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyAnswer)

@property (nonatomic, strong) NSString* answer;

@property (nonatomic, strong) NSDate* answeredOn;

@property (nonatomic, strong) NSArray* answers;

@property (nonatomic, strong) NSData* ciphertext;

@property (nonatomic, strong) NSString* client;

@property (nonatomic, strong) NSNumber* declined;

@property (nonatomic, assign) BOOL declinedValue;

@property (nonatomic, strong) NSString* questionGuid;

@end

/** \ingroup DataModel */

@implementation _SBBSurveyAnswer

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)declinedValue
{
	return [self.declined boolValue];
}

- (void)setDeclinedValue:(BOOL)value_
{
	self.declined = [NSNumber numberWithBool:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.answer = [dictionary objectForKey:@"answer"];

    self.answeredOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"answeredOn"]];

    self.answers = [dictionary objectForKey:@"answers"];

    self.client = [dictionary objectForKey:@"client"];

    self.declined = [dictionary objectForKey:@"declined"];

    self.questionGuid = [dictionary objectForKey:@"questionGuid"];

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.answer forKey:@"answer"];

    [dict setObjectIfNotNil:[self.answeredOn ISO8601String] forKey:@"answeredOn"];

    [dict setObjectIfNotNil:self.answers forKey:@"answers"];

    [dict setObjectIfNotNil:self.client forKey:@"client"];

    [dict setObjectIfNotNil:self.declined forKey:@"declined"];

    [dict setObjectIfNotNil:self.questionGuid forKey:@"questionGuid"];

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
    return [NSEntityDescription entityForName:@"SurveyAnswer" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    NSString *password = cacheManager.encryptionKey;
    if (password) {
        NSData *plaintext = [RNDecryptor decryptData:managedObject.ciphertext withPassword:password error:nil];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:plaintext options:0 error:NULL];
        self = [self initWithDictionaryRepresentation:jsonDict objectManager:objectManager];
    } else {
        self = nil;
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyAnswer" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    NSDictionary *jsonDict = [objectManager bridgeJSONFromObject:self];
    NSError *error;
    NSData *plaintext = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *password = cacheManager.encryptionKey;
    if (password && !error) {
        NSData *ciphertext = [RNEncryptor encryptData:plaintext withSettings:kRNCryptorAES256Settings password:password error:&error];
        if (!error) {
            managedObject.ciphertext = ciphertext;
        }
    }

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
