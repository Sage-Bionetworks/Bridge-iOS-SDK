//
//  SBBSurveyQuestionOption.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestionOption.h instead.
//

#import "_SBBSurveyQuestionOption.h"
#import "NSDate+SBBAdditions.h"

#import "SBBImage.h"

@interface _SBBSurveyQuestionOption()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyQuestionOption

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

        self.detail = [dictionary objectForKey:@"detail"];

        self.label = [dictionary objectForKey:@"label"];

        self.value = [dictionary objectForKey:@"value"];

            NSDictionary *imageDict = [dictionary objectForKey:@"image"];
		if(imageDict != nil)
		{
			SBBImage *imageObj = [objectManager objectFromBridgeJSON:imageDict];
			self.image = imageObj;

		}
	}

	return self;
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.detail forKey:@"detail"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.value forKey:@"value"];

	[dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.image] forKey:@"image"];

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.image awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Direct access

- (void) setImage: (SBBImage*) image_ settingInverse: (BOOL) setInverse
{
    if (image_ == nil) {
        [_image setSurveyQuestionOption: nil settingInverse: NO];
    }

    _image = image_;

    if (setInverse == YES) {
        [_image setSurveyQuestionOption: (SBBSurveyQuestionOption*)self settingInverse: NO];
    }
}

- (void) setImage: (SBBImage*) image_
{
    [self setImage: image_ settingInverse: YES];
}

- (SBBImage*) image
{
    return _image;
}

@synthesize image = _image;

@end
