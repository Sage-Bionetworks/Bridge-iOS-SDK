//
//  SBBObjectManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 9/25/14.
//
//	Copyright (c) 2014-2017, Sage Bionetworks
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

#import "SBBObjectManager.h"
#import "SBBObjectManagerInternal.h"
#import "ModelObjectInternal.h"
#import "SBBComponentManager.h"
#import "NSDate+SBBAdditions.h"
#import "SBBBridgeObject.h"
#import <objc/runtime.h>


@implementation SBBObjectManager
@synthesize bypassCache = _bypassCache;

@synthesize cacheManager;

+ (instancetype)defaultComponent
{
    static SBBObjectManager *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self objectManager];
    });
    
    return shared;
}

+ (instancetype)objectManager
{
    return [self objectManagerWithCacheManager:SBBComponent(SBBCacheManager)];
}

+ (instancetype)objectManagerWithCacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    SBBObjectManager *om = [[self alloc] init];
    om.cacheManager = cacheManager;
    return om;
}

- (instancetype)init
{
    if (self = [super init]) {
        _classForType = [NSMutableDictionary dictionary];
        _typeForClass = [NSMutableDictionary dictionary];
        _mappingsForType = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (NSString *)bridgeClassNameFromType:(NSString *)type
{
    NSString *className = [NSString stringWithFormat:@"SBB%@", type];
    
    return className;
}

- (NSString *)classNameFromType:(NSString *)type
{
    NSString *className = _classForType[type];
    if (!className.length) {
        className = [[self class] bridgeClassNameFromType:type];
    }
    
    return className;
}

+ (Class)classFromClassName:(NSString *)className
{
    Class classFromType = Nil;
    if (className.length) {
        classFromType = NSClassFromString(className);
    }
    
    return classFromType;
}

+ (Class)bridgeClassFromType:(NSString *)type
{
    NSString *className = [self bridgeClassNameFromType:type];
    
    return [self classFromClassName:className];
}

- (Class)classFromType:(NSString *)type
{
    NSString *className = [self classNameFromType:type];
    
    return [[self class] classFromClassName:className];
}

- (NSString *)typeFromClass:(Class)objectClass
{
    NSString *className = NSStringFromClass(objectClass);
    NSString *typeName = _typeForClass[className];
    if (!typeName.length) {
        // check if it's one of ours
        if ([className hasPrefix:@"SBB"]) {
            typeName = [className substringFromIndex:3];
        }
    }
    
    return typeName;
}

- (NSString *)typeEncodingForPropertyName:(NSString *)propertyName inClass:(Class)objectClass
{
    objc_property_t theProperty = class_getProperty(objectClass, [propertyName UTF8String]);
    if (theProperty == NULL) {
        return nil;
    }
    
    const char *propertyAttrs = property_getAttributes(theProperty);
    NSString *propertyAttributes = [NSString stringWithCString:propertyAttrs encoding:NSUTF8StringEncoding];
    NSArray *attributeList = [propertyAttributes componentsSeparatedByString:@","];
    NSString *typeEncoding = [attributeList[0] substringFromIndex:1];
    
    return typeEncoding;
}

- (NSString *)camelizeString:(NSString *)string
{
    NSString *camelized = [[[string substringToIndex:1] uppercaseString] stringByAppendingString:[string substringFromIndex:1]];
//    NSLog(@"Camelized '%@' to '%@'", string, camelized);
    return camelized;
}

- (SEL)setterForPropertyName:(NSString *)propertyName inClass:(Class)objectClass
{
    objc_property_t theProperty = class_getProperty(objectClass, [propertyName UTF8String]);
    if (theProperty == NULL) {
        return nil;
    }
    
    const char *propertyAttrs = property_getAttributes(theProperty);
    NSString *propertyAttributes = [NSString stringWithCString:propertyAttrs encoding:NSUTF8StringEncoding];
    NSArray *attributeList = [propertyAttributes componentsSeparatedByString:@","];
    NSString *setterName = nil;
    for (int i = 1; i < attributeList.count - 1; ++i) {
        NSString *attribute = attributeList[i];
        if ([attribute isEqualToString:@"R"]) {
            // read-only, no setter
            return nil;
        }
        if ([attribute hasPrefix:@"S"]) {
            setterName = [attribute substringFromIndex:1];
        }
    }
    
    BOOL hasCustomSetter = setterName.length > 0;
    
    if (!hasCustomSetter) {
        setterName = [NSString stringWithFormat:@"set%@:", [self camelizeString:propertyName]];
    }
    
    if (![objectClass instancesRespondToSelector: NSSelectorFromString(setterName)]) {
        if (hasCustomSetter) {
            [NSException raise:NSInternalInconsistencyException format:@"%@ has property '%@' with custom setter '%@', but doesn't respond to it", NSStringFromClass(objectClass), propertyName, setterName];
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"%@ has property '%@' with no custom setter, but does not respond to the default setter '%@'", NSStringFromClass(objectClass), propertyName, setterName];
        }
    }
    
    return (NSSelectorFromString(setterName));
}

- (SEL)getterForPropertyName:(NSString *)propertyName inClass:(Class)objectClass
{
    objc_property_t theProperty = class_getProperty(objectClass, [propertyName UTF8String]);
    if (theProperty == NULL) {
        return nil;
    }
    
    const char *propertyAttrs = property_getAttributes(theProperty);
    NSString *propertyAttributes = [NSString stringWithCString:propertyAttrs encoding:NSUTF8StringEncoding];
    NSArray *attributeList = [propertyAttributes componentsSeparatedByString:@","];
    NSString *getterName = propertyName;
    BOOL hasCustomGetter = NO;
    for (int i = 1; i < attributeList.count - 1; ++i) {
        NSString *attribute = attributeList[i];
        if ([attribute hasPrefix:@"G"]) {
            getterName = [attribute substringFromIndex:1];
            hasCustomGetter = getterName.length > 0;
        }
    }
    
    if (![objectClass instancesRespondToSelector: NSSelectorFromString(getterName)]) {
        if (hasCustomGetter) {
            [NSException raise:NSInternalInconsistencyException format:@"%@ has property '%@' with custom getter '%@', but doesn't respond to it", NSStringFromClass(objectClass), propertyName, getterName];
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"%@ has property '%@' with no custom getter, but does not respond to the default getter '%@'", NSStringFromClass(objectClass), propertyName, getterName];
        }
    }
    
    return (NSSelectorFromString(getterName));
}

// internal use only, appropriate only for classes generated by mogenerator from PONSO templates with base class ModelObject
- (NSDictionary *)propertyNamesAndGettersInClass:(Class)objectClass objectsOnly:(BOOL)objectsOnly
{
    NSMutableDictionary *namesAndGetters = [NSMutableDictionary dictionary];
    while (objectClass != [ModelObject class]) {
        [self addNonScalarPropertyNamesAndGettersInClass:objectClass toDictionary:namesAndGetters objectsOnly:objectsOnly];
        objectClass = [objectClass superclass];
    }
    
    return namesAndGetters;
}

- (void)addNonScalarPropertyNamesAndGettersInClass:(Class)objectClass toDictionary:(NSMutableDictionary *)namesAndGetters objectsOnly:(BOOL)objectsOnly
{
    unsigned int numProperties;
    objc_property_t *properties = class_copyPropertyList(objectClass, &numProperties);
    
    for (unsigned int i = 0; i < numProperties; ++i) {
        const char *propertyAttrs = property_getAttributes(properties[i]);
        NSString *propertyAttributes = [NSString stringWithCString:propertyAttrs encoding:NSUTF8StringEncoding];
        NSArray *attributeList = [propertyAttributes componentsSeparatedByString:@","];
        NSString *propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        NSString *getterName = propertyName;
        BOOL hasCustomGetter = NO;
        
        if (objectsOnly) {
            NSString *typeEncoding = [attributeList[0] substringFromIndex:1];
            if (!typeEncoding.length || [typeEncoding characterAtIndex:0] != '@') {
                // skip non-object properties
                continue;
            }
        }
        
        for (int i = 1; i < attributeList.count - 1; ++i) {
            NSString *attribute = attributeList[i];
            if ([attribute hasPrefix:@"G"]) {
                getterName = [attribute substringFromIndex:1];
                hasCustomGetter = getterName.length > 0;
            }
        }
        
//        NSLog(@"property:%@, getter:%@", propertyName, getterName);
        
        if (![objectClass instancesRespondToSelector: NSSelectorFromString(getterName)]) {
            if (hasCustomGetter) {
                [NSException raise:NSInternalInconsistencyException format:@"%@ has property '%@' with custom getter '%@', but doesn't respond to it", NSStringFromClass(objectClass), propertyName, getterName];
            } else {
                [NSException raise:NSInternalInconsistencyException format:@"%@ has property '%@' with no custom getter, but does not respond to the default getter '%@'", NSStringFromClass(objectClass), propertyName, getterName];
            }
        }
        
        if (getterName && propertyName) {
            namesAndGetters[propertyName] = getterName;
        }
    }
    
    free(properties);
}

- (char)charFromJson:(id)json
{
    char value = '\0';
    if ([json isKindOfClass:[NSNumber class]]) {
        value = [((NSNumber *)json) charValue];
    } else if ([json isKindOfClass:[NSString class]]) {
        NSString *jString = (NSString *)json;
        if (jString.length > 1) {
            value = [jString integerValue];
        } else {
            value = [jString characterAtIndex:0];
        }
    }
    
    return value;
}

- (unsigned char)unsignedCharFromJson:(id)json
{
    char value = '\0';
    if ([json isKindOfClass:[NSNumber class]]) {
        value = [((NSNumber *)json) unsignedCharValue];
    } else if ([json isKindOfClass:[NSString class]]) {
        NSString *jString = (NSString *)json;
        if (jString.length > 1) {
            value = [jString integerValue];
        } else {
            value = [jString characterAtIndex:0];
        }
    }
    
    return value;
}

- (long long)integerFromJson:(id)json
{
    NSInteger value = 0;
    
    if ([json isKindOfClass:[NSNumber class]] ||
        [json isKindOfClass:[NSString class]]) {
        value = [json integerValue];
    }
    
    return value;
}

- (unsigned long long)unsignedIntFromJson:(id)json
{
    NSUInteger value = 0;
    if ([json isKindOfClass:[NSNumber class]]) {
        value = [((NSNumber *)json) unsignedIntegerValue];
    } else if ([json isKindOfClass:[NSString class]]) {
        NSString *jString = (NSString *)json;
        value = [jString integerValue];
    }
    
    return value;
}

- (double)doubleFromJson:(id)json
{
    double value = 0.0;
    
    if ([json isKindOfClass:[NSNumber class]] ||
        [json isKindOfClass:[NSString class]]) {
        value = [json doubleValue];
    }
    
    return value;
}

- (id)class:(Class)targetClass fromJson:(id)json
{
    id converted = nil;
    
    if ((targetClass == [NSArray class] || targetClass == [NSSet class]) && [json isKindOfClass:[NSArray class]]) {
        // try converting to an array of bridge objects, and use that if so (otherwise just throw it in as-is)
        NSArray *objectArray = [self objectFromBridgeJSON:json];
        if (objectArray) {
            if (targetClass == [NSArray class]) {
                converted = objectArray;
            } else {
                converted = [NSSet setWithArray:objectArray];
            }
        } else {
            converted = json;
        }
    } else if ([json isKindOfClass:targetClass]) {
        // it's already the desired class
        converted = json;
    } else if (targetClass == [NSDate class]) {
        // API dates are always ISO8601 strings
        if ([json isKindOfClass:[NSString class]]) {
            converted = [NSDate dateWithISO8601String:json];
        }
    } else if ([targetClass isSubclassOfClass:[NSString class]]) {
        converted = [json description];
    } else if ([json isKindOfClass:[NSDictionary class]]) {
        // try converting it to an object as if it's a bridge object, and see if that's the right type
        id object = [self objectFromBridgeJSON:json];
        if ([object isKindOfClass:targetClass]) {
            converted = object;
        }
    }
    
#if DEBUG
    // don't log an issue if it's an NSNull, just return nil
    if (!converted && ![json isKindOfClass:[NSNull class]]) {
        NSLog(@"Target property class is %@, json object is %@, don't know how to convert", NSStringFromClass(targetClass), json);
    }
#endif
    
    return converted;
}

- (void)setProperty:(NSString *)propertyName inObject:(id)object fromJson:(id)json
{
//    NSLog(@"Setting property %@ in object:%@\nfromJson:\n%@\n\n", propertyName, object, json);
    SEL setter = [self setterForPropertyName:propertyName inClass:[object class]];
    if (!setter) {
        // object doesn't respond to any known setter for this property--skip
        return;
    }
    
    NSString *propertyEncoding = [self typeEncodingForPropertyName:propertyName inClass:[object class]];
    if (!propertyEncoding.length) {
        // object doesn't have this property--skip
        return;
    }
    
    NSMethodSignature *setterSig = [[object class] instanceMethodSignatureForSelector:setter];
    NSInvocation *setterInvocation = [NSInvocation invocationWithMethodSignature:setterSig];
    [setterInvocation setSelector:setter];
    [setterInvocation setTarget:object];
    
    char typeChar = [propertyEncoding characterAtIndex:0];
    switch (typeChar) {
        case '@':
        {
            // it's an id; object class name, if any, will be in quotes
            NSString *className = [[propertyEncoding substringFromIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if (className.length) {
                Class propertyClass = NSClassFromString(className);
                if (propertyClass == Nil) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@ has property '%@' of type '%@ *', but '%@' is not a known class", [object class], propertyName, className, className];
                }
                
                // attempt to convert it, if necessary, to the required class
                id converted = [self class:propertyClass fromJson:json];
                if (converted) {
                    [setterInvocation setArgument:&converted atIndex:2];
                    [setterInvocation invoke];
                }
            } else {
                // no specific class; just stuff the raw json in there directly
                [setterInvocation setArgument:&json atIndex:2];
                [setterInvocation invoke];
            }
            
        }
            break;
            
        case 'c':
        {
            char charFromJson = [self charFromJson:json];
            [setterInvocation setArgument:&charFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'i':
        {
            int intFromJson = (int)[self integerFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 's':
        {
            short intFromJson = (short)[self integerFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'l':
        {
            long intFromJson = (long)[self integerFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'q':
        {
            long long intFromJson = [self integerFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'C':
        {
            unsigned char charFromJson = [self unsignedCharFromJson:json];
            [setterInvocation setArgument:&charFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'I':
        {
            unsigned int intFromJson = (unsigned int)[self unsignedIntFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'S':
        {
            unsigned short intFromJson = (unsigned short)[self unsignedIntFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'L':
        {
            unsigned long intFromJson = (unsigned long)[self unsignedIntFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'Q':
        {
            unsigned long long intFromJson = [self unsignedIntFromJson:json];
            [setterInvocation setArgument:&intFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'f':
        {
            float floatFromJson = (float)[self doubleFromJson:json];
            [setterInvocation setArgument:&floatFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        case 'd':
        {
            double doubleFromJson = [self doubleFromJson:json];
            [setterInvocation setArgument:&doubleFromJson atIndex:2];
            [setterInvocation invoke];
        }
            break;
            
        default:
            break;
    }
}

- (id)getJsonFromProperty:(NSString *)propertyName inObject:(id)object
{
//    NSLog(@"Getting json from property %@ in object %@", propertyName, object);
    if (!propertyName || !object) {
        return nil;
    }
    SEL getter = [self getterForPropertyName:propertyName inClass:[object class]];
    if (!getter) {
        // object doesn't respond to any known getter for this property--skip
        return nil;
    }
    
    id json = nil;
    NSString *propertyEncoding = [self typeEncodingForPropertyName:propertyName inClass:[object class]];
    if (!propertyEncoding.length) {
        // object doesn't have this property--skip
        return nil;
    }
    
    NSMethodSignature *getterSig = [[object class] instanceMethodSignatureForSelector:getter];
    NSInvocation *getterInvocation = [NSInvocation invocationWithMethodSignature:getterSig];
    [getterInvocation setSelector:getter];
    [getterInvocation setTarget:object];
    [getterInvocation invoke];
    
    char typeChar = [propertyEncoding characterAtIndex:0];
    switch (typeChar) {
        case '@':
        {
            // it's an object (id)
            __unsafe_unretained id propertyValue = nil;
            [getterInvocation getReturnValue:&propertyValue];
            json = [self bridgeJSONFromObject:propertyValue];
        }
            break;
            
        case 'c':
        {
            char propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithChar:propertyValue];
        }
            break;
            
        case 'i':
        {
            int propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithInt:propertyValue];
        }
            break;
            
        case 's':
        {
            short propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithShort:propertyValue];
        }
            break;
            
        case 'l':
        {
            long propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithLong:propertyValue];
        }
            break;
            
        case 'q':
        {
            long long propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithLongLong:propertyValue];
        }
            break;
            
        case 'C':
        {
            unsigned char propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithUnsignedChar:propertyValue];
        }
            break;
            
        case 'I':
        {
            unsigned int propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithUnsignedInt:propertyValue];
        }
            break;
            
        case 'S':
        {
            unsigned short propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithUnsignedShort:propertyValue];
        }
            break;
            
        case 'L':
        {
            unsigned long propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithUnsignedLong:propertyValue];
        }
            break;
            
        case 'Q':
        {
            unsigned long long propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithUnsignedLongLong:propertyValue];
        }
            break;
            
        case 'f':
        {
            float propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithFloat:propertyValue];
        }
            break;
            
        case 'd':
        {
            double propertyValue;
            [getterInvocation getReturnValue:&propertyValue];
            json = [NSNumber numberWithDouble:propertyValue];
        }
            break;
            
        default:
            break;
    }
    
    return json;
}


- (id)objectFromBridgeJSON:(id)json
{
    id object = nil;
    
    if ([json isKindOfClass:[NSArray class]]) {
        NSMutableArray *list = [NSMutableArray array];
        for (id subJson in json) {
            if ([subJson isKindOfClass:[NSDictionary class]] || [subJson isKindOfClass:[NSArray class]]) {
                id subObject = [self objectFromBridgeJSON:subJson];
                if (subObject == nil) {
#if DEBUG
                    NSLog(@"Unable to create Bridge object from json, skipping:\n%@", subJson);
#endif
                } else {
                    [list addObject:subObject];
                }
            } else {
                [list addObject:subJson];
            }
        }
        object = list;
    } else if ([json isKindOfClass:[NSDictionary class]]) {
        NSString *type = json[@"type"];
        if (!type.length) {
            // not an API object, no way to determine type; just pass it through as raw json
            return json;
        }
        
        id bridgeJson = json;
        
        id bridgeObject = nil;
        if (gSBBUseCache && !_bypassCache) {
            // Try the cache first (if it's not a directly cacheable entity, this will be nil)
            id<SBBCacheManagerProtocol> cacheMan = self.cacheManager ?: SBBComponent(SBBCacheManager);
            bridgeObject = [cacheMan cachedObjectFromBridgeJSON:json];
        }
        // otherwise, our internal class for this type knows how to initialize itself from the json
        if (bridgeObject) {
            // in case we got partial json passed in and combined it with what was cached
            bridgeJson = [bridgeObject dictionaryRepresentationFromObjectManager:self];
        } else {
            Class bridgeClass = [[self class] bridgeClassFromType:type];
            if (bridgeClass == Nil) {
#if DEBUG
                NSLog(@"Unable to determine class of object to create for type %@", type);
#endif
                return nil;
            }
            bridgeObject = [[bridgeClass alloc] initWithDictionaryRepresentation:json objectManager:self];
        }
        
        NSDictionary *mappings = _mappingsForType[type];
        if (mappings) {
            object = [self mappedObjectForBridgeJSON:bridgeJson ofType:type withMappings:mappings];
        } else {
            object = bridgeObject;
        }
    }
    
//    NSLog(@"Created object %@ from Bridge JSON:\n%@", object, json);
    return object;
}

- (id)bridgeJSONFromObject:(id)object
{
    if (object == nil) {
        return nil;
    }
    
    Class objectClass = [object class];
    id bridgeJSON = nil;
    if ([objectClass isSubclassOfClass:[NSArray class]] ||
        [objectClass isSubclassOfClass:[NSSet class]]) {
        bridgeJSON = [NSMutableArray array];
        for (id subObject in object) {
            id json = [self bridgeJSONFromObject:subObject];
            if (json == nil) {
#if DEBUG
                NSLog(@"Unable to convert %@ object to json:\n%@", NSStringFromClass(objectClass), object);
#endif
                return nil;
            }
            [bridgeJSON addObject:json];
        }
    } else if ([objectClass isSubclassOfClass:[NSDictionary class]] ||
               [objectClass isSubclassOfClass:[NSNumber class]] ||
               [objectClass isSubclassOfClass:[NSString class]]) {
        // assume it's already json
        return object;
    } else if ([objectClass isSubclassOfClass:[NSDate class]]) {
        bridgeJSON = [(NSDate *)object ISO8601String];
    } else {
        bridgeJSON = [NSMutableDictionary dictionary];
        NSString *type = [self typeFromClass:objectClass];
        NSDictionary *mappings = _mappingsForType[type];
        if (mappings) {
            for (NSString *bridgeFieldKey in [mappings allKeys]) {
                NSString *targetClassKey = mappings[bridgeFieldKey];
                id jsonForKey = [self getJsonFromProperty:targetClassKey inObject:object];
                if (jsonForKey) {
                    bridgeJSON[bridgeFieldKey] = jsonForKey;
                }
            }
            
            // set the Bridge "type" field, if necessary
            if (!bridgeJSON[@"type"]) {
                bridgeJSON[@"type"] = type;
            }
        } else {
            // our internal class for this type knows how to convert itself to json
            bridgeJSON = [object dictionaryRepresentationFromObjectManager:self];
        }
    }
    return bridgeJSON;
}

#pragma mark - Object mapping

- (void)setupMappingForType:(NSString *)type toClass:(Class)mapToClass fieldToPropertyMappings:(NSDictionary *)mappings
{
    if (!type.length) {
        return;
    }
    NSString *className = NSStringFromClass(mapToClass);
    if (className && mappings) {
        [_classForType setObject:className forKey:type];
        [_typeForClass setObject:type forKey:className];
        [_mappingsForType setObject:mappings forKey:type];
    } else {
        className = _classForType[type];
        [_classForType removeObjectForKey:type];
        if (className) {
            [_typeForClass removeObjectForKey:className];
        }
        [_mappingsForType removeObjectForKey:type];
    }
}

- (void)clearMappingForType:(NSString *)type
{
    if (!type.length) {
        return;
    }
    NSString *className = _classForType[type];
    if (!className.length) {
        return;
    }
    [_classForType removeObjectForKey:type];
    [_typeForClass removeObjectForKey:className];
    [_mappingsForType removeObjectForKey:type];
}

- (id)mappedObjectForBridgeJSON:(id)bridgeJson ofType:(NSString *)type withMappings:(NSDictionary *)mappings
{
    Class objectClass = [self classFromType:type];
    if (objectClass == Nil) {
#if DEBUG
        NSLog(@"Unable to determine class of object to create for type %@", type);
#endif
        return nil;
    }
    id object = [objectClass new];
    
    for (NSString *bridgeFieldKey in [mappings allKeys]) {
        id bridgeFieldValue = bridgeJson[bridgeFieldKey];
        if (!bridgeFieldValue) {
            continue;
        }
        NSString *targetClassKey = mappings[bridgeFieldKey];
        [self setProperty:targetClassKey inObject:object fromJson:bridgeFieldValue];
    }
    
    return object;
}

- (id)mappedObjectForBridgeObject:(SBBBridgeObject *)bridgeObject
{
    NSDictionary *mappings = _mappingsForType[bridgeObject.type];
    if (!mappings) {
        return bridgeObject;
    }

    id bridgeJSON = [bridgeObject dictionaryRepresentationFromObjectManager:self];
    return [self mappedObjectForBridgeJSON:bridgeJSON ofType:bridgeObject.type withMappings:mappings];
}

@end
