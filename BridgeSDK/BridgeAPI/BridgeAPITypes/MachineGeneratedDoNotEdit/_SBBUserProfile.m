//
//  SBBUserProfile.m
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUserProfile.h instead.
//

#import "_SBBUserProfile.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@import ObjectiveC;

@interface _SBBUserProfile()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (UserProfile)

@property (nonatomic, strong) NSString* email;

@property (nonatomic, strong) NSString* firstName;

@property (nonatomic, strong) NSString* lastName;

@property (nonatomic, strong) NSString* username;

@end

@implementation _SBBUserProfile

- (instancetype)init
{
	if((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

// Check that the selector corresponds to a property.
// Note that this doesn't handle custom getter/setter names in the declaration.
+ (objc_property_t)propertyFromSelector:(SEL)sel
{
    NSString *propertyName = NSStringFromSelector(sel);
    objc_property_t property = NULL;
    if ([propertyName hasSuffix:@":"]) {
        // setter--assume sel is of the form 'setXxxXxx:' where the property name is 'XxxXxx' or 'xxxXxx'
        // - cut off the trailing ':'
        propertyName = [[propertyName substringToIndex:propertyName.length - 1] substringFromIndex:3];
        property = class_getProperty([self class], [propertyName UTF8String]);
        if (property == NULL) {
            // dromedary-camelCase the string and try again
            propertyName = [[[propertyName substringToIndex:1] lowercaseString] stringByAppendingString:[propertyName substringFromIndex:1]];
            property = class_getProperty([self class], [propertyName UTF8String]);
        }
    } else {
        // getter--assume selector is property name
        property = class_getProperty([self class], [propertyName UTF8String]);
    }

    return property;
}

static NSString *nameForProperty(objc_property_t property)
{
    return [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
}

static void dynamicSetterIMP(id self, SEL _cmd, id value)
{
    objc_property_t property = [[self class] propertyFromSelector:_cmd];
    if (value) {
        [[self customFields] setObject:value forKey:nameForProperty(property)];
    } else {
        [[self customFields] removeObjectForKey:nameForProperty(property)];
    }
}

static NSString *dynamicGetterIMP(id self, SEL _cmd)
{
    objc_property_t property = [[self class] propertyFromSelector:_cmd];
    return [[self customFields] objectForKey:nameForProperty(property)];
}

// Create the custom fields container on demand.
// Note: it's an associated object and not just a property because we don't want to include it when serializing the object to JSON.
- (NSMutableDictionary *)customFields
{
    NSMutableDictionary *customFields = objc_getAssociatedObject(self, @selector(customFields));
    if (!customFields) {
        customFields = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(customFields), customFields, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return customFields;
}

// This is called by the Objective-C runtime when the object receives a message on a selector it doesn't implement.
// We're going to take advantage of that to provide setter and getter implementations for @dynamic properties
// declared in categories of SBBUserProfile, so that all the existing machinery around marshaling and serializing
// objects to/from Bridge JSON will just work.
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    BOOL isSetter = [NSStringFromSelector(sel) hasSuffix:@":"];
    objc_property_t property = [self propertyFromSelector:sel];
    if (property) {
        if (isSetter) {
            // set the IMP for sel to dynamicSetterIMP
            class_addMethod(self, sel, (IMP)dynamicSetterIMP, "v@:@");
        } else {
            // set the IMP for sel to dynamicGetterIMP
            class_addMethod(self, sel, (IMP)dynamicGetterIMP, "@@:");
        }
    }

    return [super resolveInstanceMethod:sel];
}

- (NSArray *)originalProperties
{
    NSMutableArray *props = [@[@"email", @"firstName", @"lastName", @"type", @"username", @"__end_of_properties__"] mutableCopy];
    [props removeLastObject];

    return props;
}

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.email = [dictionary objectForKey:@"email"];

    self.firstName = [dictionary objectForKey:@"firstName"];

    self.lastName = [dictionary objectForKey:@"lastName"];

    self.username = [dictionary objectForKey:@"username"];

    // now update from the custom fields
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.originalProperties];
    NSArray *customProperties = [dictionary.allKeys filteredArrayUsingPredicate:pred];
    for (NSString *propertyName in customProperties) {
        // assuming custom properties are not readonly, and why would they be, after all?
        // ...also assume they are not something like NSDates that have to be handled funkily
        // ...and that they are not using custom setter names
        NSString *value = [dictionary objectForKey:propertyName];
        NSString *camelizedProp = [[[propertyName substringToIndex:1] uppercaseString] stringByAppendingString:[propertyName substringFromIndex:1]];
        NSString *setterName = [NSString stringWithFormat:@"set%@:", camelizedProp];
        SEL setter = NSSelectorFromString(setterName);
        if ([self respondsToSelector:setter]) {
            [self performSelector:setter withObject:value];
        }
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentationFromObjectManager:objectManager]];

    [dict setObjectIfNotNil:self.email forKey:@"email"];

    [dict setObjectIfNotNil:self.firstName forKey:@"firstName"];

    [dict setObjectIfNotNil:self.lastName forKey:@"lastName"];

    [dict setObjectIfNotNil:self.username forKey:@"username"];

    // add in the custom fields
    [dict addEntriesFromDictionary:[self customFields]];

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
    return [NSEntityDescription entityForName:@"UserProfile" inManagedObjectContext:context];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self == [super init]) {

        self.email = managedObject.email;

        self.firstName = managedObject.firstName;

        self.lastName = managedObject.lastName;

        self.username = managedObject.username;

    }

    return self;

}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfile" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    managedObject.email = self.email;

    managedObject.firstName = self.firstName;

    managedObject.lastName = self.lastName;

    managedObject.username = self.username;

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
