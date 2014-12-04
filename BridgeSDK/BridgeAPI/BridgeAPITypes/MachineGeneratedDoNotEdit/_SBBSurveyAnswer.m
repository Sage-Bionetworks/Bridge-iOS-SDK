//
//  SBBSurveyAnswer.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyAnswer.h instead.
//

#import "_SBBSurveyAnswer.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "RNEncryptor.h"
#import "RNDecryptor.h"

#import "SBBSurveyResponse.h"

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

@property (nonatomic, strong, readwrite) SBBSurveyResponse *surveyResponse;

- (void) setSurveyResponse: (SBBSurveyResponse*) surveyResponse_ settingInverse: (BOOL) setInverse;

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

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.answer = [dictionary objectForKey:@"answer"];

        self.answeredOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"answeredOn"]];

        self.answers = [dictionary objectForKey:@"answers"];

        self.ciphertext = [dictionary objectForKey:@"ciphertext"];

        self.client = [dictionary objectForKey:@"client"];

        self.declined = [dictionary objectForKey:@"declined"];

        self.questionGuid = [dictionary objectForKey:@"questionGuid"];

	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.answer forKey:@"answer"];

    [dict setObjectIfNotNil:[self.answeredOn ISO8601String] forKey:@"answeredOn"];

    [dict setObjectIfNotNil:self.answers forKey:@"answers"];

    [dict setObjectIfNotNil:self.ciphertext forKey:@"ciphertext"];

    [dict setObjectIfNotNil:self.client forKey:@"client"];

    [dict setObjectIfNotNil:self.declined forKey:@"declined"];

    [dict setObjectIfNotNil:self.questionGuid forKey:@"questionGuid"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.surveyResponse awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{

    // TODO: fetch password from auth manager
    NSData *plaintext = [RNDecryptor decryptData:managedObject.ciphertext withPassword:aPassword error:nil];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:plaintext options:0 error:NULL];
    return [self initWithDictionaryRepresentation:jsonDict objectManager:[SBBObjectManager objectManager]];

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    // TODO: Get or create cacheContext MOC for core data cache.
    __block NSManagedObject *managedObject = nil;

    managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyAnswer" inManagedObjectContext:cacheContext];

    NSDictionary *jsonDict = [objectManager bridgeJSONFromObject:self];
    NSError *error;
    NSData *plaintext = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
    // TODO: fetch password from auth manager
    NSData *ciphertext = [RNEncryptor encryptData:plaintext withSettings:kRNCryptorAES256Settings password:aPassword error:nil];
    managedObject.ciphertext = ciphertext;

    // TODO: Save changes to cacheContext.

    return managedObject;
}

#pragma mark Direct access

- (void) setSurveyResponse: (SBBSurveyResponse*) surveyResponse_ settingInverse: (BOOL) setInverse
{
    if (surveyResponse_ == nil) {
        [_surveyResponse removeAnswersObject: (SBBSurveyAnswer*)self settingInverse: NO];
    }

    _surveyResponse = surveyResponse_;

    if (setInverse == YES) {
        [_surveyResponse addAnswersObject: (SBBSurveyAnswer*)self settingInverse: NO];
    }
}

- (void) setSurveyResponse: (SBBSurveyResponse*) surveyResponse_
{
    [self setSurveyResponse: surveyResponse_ settingInverse: YES];
}

- (SBBSurveyResponse*) surveyResponse
{
    return _surveyResponse;
}

@synthesize surveyResponse = _surveyResponse;

@end
