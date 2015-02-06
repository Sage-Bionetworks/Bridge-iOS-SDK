//
//  SBBSurveyInfoScreen.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyInfoScreen.h instead.
//

#import "_SBBSurveyInfoScreen.h"
#import "NSDate+SBBAdditions.h"

#import "SBBImage.h"

@interface _SBBSurveyInfoScreen()

@end

/** \ingroup DataModel */

@implementation _SBBSurveyInfoScreen

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

        self.prompt = [dictionary objectForKey:@"prompt"];

        self.promptDetail = [dictionary objectForKey:@"promptDetail"];

        self.title = [dictionary objectForKey:@"title"];

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

    [dict setObjectIfNotNil:self.prompt forKey:@"prompt"];

    [dict setObjectIfNotNil:self.promptDetail forKey:@"promptDetail"];

    [dict setObjectIfNotNil:self.title forKey:@"title"];

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
        [_image setSurveyInfoScreen: nil settingInverse: NO];
    }

    _image = image_;

    if (setInverse == YES) {
        [_image setSurveyInfoScreen: (SBBSurveyInfoScreen*)self settingInverse: NO];
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
