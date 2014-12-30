//
//  SBBActivity.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBActivity.h instead.
//

#import "_SBBActivity.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBGuidCreatedOnVersionHolder.h"

@interface _SBBActivity()

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (Activity)

@property (nonatomic, strong) NSString* activityType;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* ref;

@property (nonatomic, strong, readwrite) NSManagedObject *survey;

- (void) setSurvey: (NSManagedObject *) survey_ settingInverse: (BOOL) setInverse;

@end

/** \ingroup DataModel */

@implementation _SBBActivity

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  if((self = [super initWithDictionaryRepresentation:dictionary objectManager:objectManager]))
	{

        self.activityType = [dictionary objectForKey:@"activityType"];

        self.label = [dictionary objectForKey:@"label"];

        self.ref = [dictionary objectForKey:@"ref"];

            NSDictionary *surveyDict = [dictionary objectForKey:@"survey"];
		if(surveyDict != nil)
		{
			SBBGuidCreatedOnVersionHolder *surveyObj = [objectManager objectFromBridgeJSON:surveyDict];
			self.survey = surveyObj;

		}
	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.ref forKey:@"ref"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.survey] forKey:@"survey"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.survey awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

#pragma mark Direct access

- (void) setSurvey: (SBBGuidCreatedOnVersionHolder*) survey_ settingInverse: (BOOL) setInverse
{

    _survey = survey_;

}

- (void) setSurvey: (SBBGuidCreatedOnVersionHolder*) survey_
{
    [self setSurvey: survey_ settingInverse: YES];
}

- (SBBGuidCreatedOnVersionHolder*) survey
{
    return _survey;
}

@synthesize survey = _survey;

@end
