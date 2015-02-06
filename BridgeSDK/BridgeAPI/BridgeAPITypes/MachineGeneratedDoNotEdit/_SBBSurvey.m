//
//  SBBSurvey.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurvey.h instead.
//

#import "_SBBSurvey.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyElement.h"

@interface _SBBSurvey()
@property (nonatomic, strong, readwrite) NSArray *elements;

@end

/*! xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
 */
@interface NSManagedObject (Survey)

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* modifiedOn;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSNumber* published;

@property (nonatomic, assign) BOOL publishedValue;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) double versionValue;

@property (nonatomic, strong, readonly) NSArray *elements;

- (void)addElementsObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)addElementsObject:(NSManagedObject *)value_;
- (void)removeElementsObjects;
- (void)removeElementsObject:(NSManagedObject *)value_ settingInverse: (BOOL) setInverse;
- (void)removeElementsObject:(NSManagedObject *)value_;

- (void)insertObject:(NSManagedObject *)value inElementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx;
- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeElementsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)values;

@end

/** \ingroup DataModel */

@implementation _SBBSurvey

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

- (BOOL)publishedValue
{
	return [self.published boolValue];
}

- (void)setPublishedValue:(BOOL)value_
{
	self.published = [NSNumber numberWithBool:value_];
}

- (double)versionValue
{
	return [self.version doubleValue];
}

- (void)setVersionValue:(double)value_
{
	self.version = [NSNumber numberWithDouble:value_];
}

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.createdOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"createdOn"]];

    self.guid = [dictionary objectForKey:@"guid"];

    self.identifier = [dictionary objectForKey:@"identifier"];

    self.modifiedOn = [NSDate dateWithISO8601String:[dictionary objectForKey:@"modifiedOn"]];

    self.name = [dictionary objectForKey:@"name"];

    self.published = [dictionary objectForKey:@"published"];

    self.version = [dictionary objectForKey:@"version"];

    for(id objectRepresentationForDict in [dictionary objectForKey:@"elements"])
    {
        SBBSurveyElement *elementsObj = [objectManager objectFromBridgeJSON:objectRepresentationForDict];

        [self addElementsObject:elementsObj];
    }
}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:[self.createdOn ISO8601String] forKey:@"createdOn"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.identifier forKey:@"identifier"];

    [dict setObjectIfNotNil:[self.modifiedOn ISO8601String] forKey:@"modifiedOn"];

    [dict setObjectIfNotNil:self.name forKey:@"name"];

    [dict setObjectIfNotNil:self.published forKey:@"published"];

    [dict setObjectIfNotNil:self.version forKey:@"version"];

    if([self.elements count] > 0)
	{

		NSMutableArray *elementsRepresentationsForDictionary = [NSMutableArray arrayWithCapacity:[self.elements count]];
		for(SBBSurveyElement *obj in self.elements)
		{
			[elementsRepresentationsForDictionary addObject:[objectManager bridgeJSONFromObject:obj]];
		}
		[dict setObjectIfNotNil:elementsRepresentationsForDictionary forKey:@"elements"];

	}

	return dict;
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	for(SBBSurveyElement *elementsObj in self.elements)
	{
		[elementsObj awakeFromDictionaryRepresentationInit];
	}

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

- (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:@"Survey" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.createdOn = managedObject.createdOn;

        self.guid = managedObject.guid;

        self.identifier = managedObject.identifier;

        self.modifiedOn = managedObject.modifiedOn;

        self.name = managedObject.name;

        self.published = managedObject.published;

        self.version = managedObject.version;

		for(NSManagedObject *elementsManagedObj in managedObject.elements)
		{
            SBBSurveyElement *elementsObj = [[SBBSurveyElement alloc] initWithManagedObject:elementsManagedObj objectManager:objectManager cacheManager:cacheManager];
            if(elementsObj != nil)
            {
                [self addElementsObject:elementsObj];
            }
		}
    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Survey" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.createdOn = self.createdOn;

    managedObject.guid = self.guid;

    managedObject.identifier = self.identifier;

    managedObject.modifiedOn = self.modifiedOn;

    managedObject.name = self.name;

    managedObject.published = self.published;

    managedObject.version = self.version;

    if([self.elements count] > 0) {
        [managedObject removeElementsObjects];
		for(SBBSurveyElement *obj in self.elements) {
            NSManagedObject *relMo = [obj saveToContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];
            [managedObject addElementsObject:relMo];
		}
	}

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void)addElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse
{
    if(self.elements == nil)
	{

		self.elements = [NSMutableArray array];

	}

	[(NSMutableArray *)self.elements addObject:value_];

}
- (void)addElementsObject:(SBBSurveyElement*)value_
{
    [self addElementsObject:(SBBSurveyElement*)value_ settingInverse: YES];
}

- (void)removeElementsObjects
{

	self.elements = [NSMutableArray array];

}

- (void)removeElementsObject:(SBBSurveyElement*)value_ settingInverse: (BOOL) setInverse
{

    [(NSMutableArray *)self.elements removeObject:value_];
}

- (void)removeElementsObject:(SBBSurveyElement*)value_
{
    [self removeElementsObject:(SBBSurveyElement*)value_ settingInverse: YES];
}

- (void)insertObject:(SBBSurveyElement*)value inElementsAtIndex:(NSUInteger)idx {
    [self insertObject:value inElementsAtIndex:idx settingInverse:YES];
}

- (void)insertObject:(SBBSurveyElement*)value inElementsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements insertObject:value atIndex:idx];

}

- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx {
    [self removeObjectFromElementsAtIndex:idx settingInverse:YES];
}

- (void)removeObjectFromElementsAtIndex:(NSUInteger)idx settingInverse:(BOOL)setInverse {
    SBBSurveyElement *object = [self.elements objectAtIndex:idx];
    [self removeElementsObject:object settingInverse:YES];
}

- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self insertElements:value atIndexes:indexes settingInverse:YES];
}

- (void)insertElements:(NSArray *)value atIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {
    [(NSMutableArray *)self.elements insertObjects:value atIndexes:indexes];

}

- (void)removeElementsAtIndexes:(NSIndexSet *)indexes {
    [self removeElementsAtIndexes:indexes settingInverse:YES];
}

- (void)removeElementsAtIndexes:(NSIndexSet *)indexes settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value {
    [self replaceObjectInElementsAtIndex:idx withObject:value settingInverse:YES];
}

- (void)replaceObjectInElementsAtIndex:(NSUInteger)idx withObject:(SBBSurveyElement*)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements replaceObjectAtIndex:idx withObject:value];
}

- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)value {
    [self replaceElementsAtIndexes:indexes withElements:value settingInverse:YES];
}

- (void)replaceElementsAtIndexes:(NSIndexSet *)indexes withElements:(NSArray *)value settingInverse:(BOOL)setInverse {

    [(NSMutableArray *)self.elements replaceObjectsAtIndexes:indexes withObjects:value];
}

@end
