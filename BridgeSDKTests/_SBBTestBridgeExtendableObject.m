//
//  _SBBTestBridgeExtendableObject.m
//
//	Copyright (c) 2014-2017 Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBTestBridgeExtendableObject.m instead.
//

#import "_SBBTestBridgeExtendableObject.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

@import ObjectiveC;

@interface _SBBTestBridgeExtendableObject()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (TestBridgeExtendableObject)

@end

@implementation _SBBTestBridgeExtendableObject

- (instancetype)init
{
	if ((self = [super init]))
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

static id dynamicGetterIMP(id self, SEL _cmd)
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
// declared in categories of SBBTestBridgeExtendableObject, so that all the existing machinery around marshaling and serializing
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

- (NSString *)typeEncodingForPropertyName:(NSString *)propertyName
{
    objc_property_t theProperty = class_getProperty([self class], [propertyName UTF8String]);
    if (theProperty == NULL) {
        return nil;
    }

    const char *propertyAttrs = property_getAttributes(theProperty);
    NSString *propertyAttributes = [NSString stringWithCString:propertyAttrs encoding:NSUTF8StringEncoding];
    NSArray *attributeList = [propertyAttributes componentsSeparatedByString:@","];
    NSString *typeEncoding = [attributeList[0] substringFromIndex:1];

    return typeEncoding;
}

- (BOOL)typeIsNSString:(NSString *)propertyName
{
    return [[self typeEncodingForPropertyName:propertyName] isEqualToString:@"@\"NSString\""];
}

- (NSArray *)originalProperties
{
    static NSArray *props;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *localProps = [@[@"dateField", @"doubleField", @"floatField", @"guid", @"jsonArrayField", @"jsonDictField", @"longField", @"longLongField", @"shortField", @"stringField", @"type", @"uLongField", @"uLongLongField", @"uShortField", @"bridgeObjectArrayField", @"bridgeObjectSetField", @"bridgeSubObjectField", @"__end_of_properties__"] mutableCopy];
        [localProps removeLastObject];
        props = [localProps copy];
    });

    return props;
}

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    // now update from the custom fields
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.originalProperties];
    NSArray *customProperties = [dictionary.allKeys filteredArrayUsingPredicate:pred];
    for (NSString *propertyName in customProperties) {
        if (class_getProperty([self class], [propertyName UTF8String]) == NULL) {
            // we don't know about this property (probably a new base property added on the server) so ignore it
            continue;
        }

        // Assuming custom properties are not readonly, and why would they be, after all?
        // ...also assume they are JSON types (NSString, NSNumber, NSNull, NSArray<JSON-types>, NSDictionary<JSON-types>)
        // ...and that they are not using custom setter names.
        id value = [dictionary objectForKey:propertyName];
        if (![self typeIsNSString:propertyName]) {
            // Custom properties are always serialized as JSON NSStrings. If it's not an NSString, assume it's not one of our known custom ones and just ignore it.
            if (![value isKindOfClass:[NSString class]]) {
                continue;
            }
            value = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        }
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
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    // add in the custom fields
    NSDictionary *customFields = [self customFields];
    for (NSString *propertyName in [customFields allKeys]) {
        id value = customFields[propertyName];
        if (![self typeIsNSString:propertyName]) {
            // Custom properties are always serialized as JSON NSStrings.
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        [dict setValue:value forKey:propertyName];
    }

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"TestBridgeExtendableObject";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TestBridgeExtendableObject" inManagedObjectContext:cacheContext];
    [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (NSManagedObject *)saveToContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [cacheManager cachedObjectForBridgeObject:self inContext:cacheContext];
    if (managedObject) {
        [self updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];
    }

    // Calling code will handle saving these changes to cacheContext.

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    [super updateManagedObject:managedObject withObjectManager:objectManager cacheManager:cacheManager];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

@end
