//
//  SBBSurvey.m
//	
//  $Id$
//

#import "SBBSurvey.h"

@implementation SBBSurvey

#pragma mark Abstract method overrides

// Custom logic goes here.


- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary
{
    if((self = [super initWithDictionaryRepresentation:dictionary]))
    {
        self.questions = [dictionary objectForKey:@"questions"];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
    
    [dict setObjectIfNotNil:self.questions forKey:@"questions"];
    
    return dict;
}


@end
