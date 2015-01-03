//
//  SBBSurveyConstraints.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyConstraints.h instead.
//

#import "_SBBSurveyConstraints.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyRule.h"

@interface _SBBSurveyConstraints()
@property (nonatomic, strong, readwrite) NSArray *rules;

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (SurveyConstraints)

@property (nonatomic, strong) NSString* dataType;

@property (nonatomic, strong, readonly) NSArray *rules;

- (void)addRulesObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addRulesObject:(NSManagedObject *)value_;
- (void)removeRulesObjects;
- (void)removeRulesObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeRulesObject:(NSManagedObject *)value_;

- (void)insertObject:(NSManagedObject *)value inRulesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRulesAtIndex:(NSUInteger)idx;
- (void)insertRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRulesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)values;

@end

/** \ingroup DataModel */

@implementation _SBBSurveyConstraints

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.dataType = [dictionary objectForKey:@"dataType"];

    for(id objectRepresentationForDict in [dictionary objectForKey:@"rules"])
    {
        SBBSurveyRule *rulesObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addRulesObject:rulesObj];
    }
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.dataType forKey:@"dataType"];

    if([self.rules count] > 0)
	{

		NSMutableArray *rulesRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.rules count]];
		for(SBBSurveyRule *obj in self.rules)
		{
			[rulesRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:rulesRepresentationsForDictionary forKey:@"rules"];

	}

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBSurveyRule *rulesObj in self.rules)
	{
		[rulesObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"SurveyConstraints" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.dataType = managedObject.dataType;

		for(NSManagedObject *rulesManagedObj in managedObject.rules)
		{
            SBBSurveyRule *rulesObj = [[SBBSurveyRule alloc] initWithManagedObject:rulesManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(rulesObj != nil)
            {
                [self addRulesObject:rulesObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyConstraints" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.dataType = self.dataType;

    if([self.rules count] > 0) {
        [managedObject removeRulesObjects];
		for(SBBSurveyRule *obj in self.rules) {
            NSManagedObject *relMo = [obj saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            [managedObject addRulesObject:relMo];
		}
	}

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse
{
    if(self.rules == nil)
	{

		self.rules = [NSMutableArray array];

	}

	[(NSMutableArray *)self.rules addObject:value_];

}
- (void)addRulesObject:(SBBSurveyRule*)value_
{
    [self addRulesObject:(SBBSurveyRule*)value_ settingInverse: YES];
}

- (void)removeRulesObjects
{

	self.rules = [NSMutableArray array];

}

- (void)removeRulesObject:(SBBSurveyRule*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.rules removeObject:value_];
}

- (void)removeRulesObject:(SBBSurveyRule*)value_
{
    [self removeRulesObject:(SBBSurveyRule*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyRule*)value inRulesAtIndex:(NSUInteger)idx {
    [self insertObject:value inRulesAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyRule*)value inRulesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules insertObject:value atIndex:idx];

}

- (void)removeObjectFromRulesAtIndex:(NSUInteger)idx {
    [self removeObjectFromRulesAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromRulesAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyRule *object = [self.rules objectAtIndex:idx];
    [self removeRulesObject:object settingInverse:YES];
}

- (void)insertRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertRules:value atIndexes:indexes settingInverse:YES];
}

- (void)insertRules:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.rules insertObjects:value atIndexes:indexes];

}

- (void)removeRulesAtIndexes:(NSIndexSet *)indexes {
    [self removeRulesAtIndexes:indexes settingInverse:YES];
}

- (void)removeRulesAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value {
    [self replaceObjectInRulesAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInRulesAtIndex:(NSUInteger)idx withObject:(SBBSurveyRule*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)value {
    [self replaceRulesAtIndexes:indexes withRules:value settingInverse:YES];
}

- (void)replaceRulesAtIndexes:(NSIndexSet *)indexes withRules:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.rules replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
