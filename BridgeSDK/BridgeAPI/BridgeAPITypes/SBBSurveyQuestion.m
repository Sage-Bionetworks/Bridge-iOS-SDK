//
//  SBBSurveyQuestion.m
//	
//  $Id$
//

#import "SBBSurveyQuestion.h"

@implementation SBBSurveyQuestion

#pragma mark Abstract method overrides


- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
    if((self = [super initWithDictionaryRepresentation:dictionary]))
    {
        self.detail = [dictionary objectForKey:@"detail"];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
    
    [dict setObjectIfNotNil:self.detail forKey:@"detail"];
    
    return dict;
}

@end
