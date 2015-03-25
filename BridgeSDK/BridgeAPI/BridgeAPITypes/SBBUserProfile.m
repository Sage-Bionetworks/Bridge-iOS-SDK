//
//  SBBUserProfile.m
//	
//  $Id$
//

#import "SBBUserProfile.h"
@import ObjectiveC;

@implementation SBBUserProfile

#pragma mark Abstract method overrides

// Custom logic goes here.

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

@end
