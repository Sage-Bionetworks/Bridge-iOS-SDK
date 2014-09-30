//
//  SBBTestBridgeObject.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeObject.h"

@interface SBBTestBridgeObject : SBBBridgeObject

@property (nonatomic, strong) NSString *stringField;

@property (nonatomic) char charField;

@property (nonatomic) int intField;

@property (nonatomic) short shortField;

@property (nonatomic) long longField;

@property (nonatomic) long long longLongField;

@property (nonatomic) unsigned char uCharField;

@property (nonatomic) unsigned int uIntField;

@property (nonatomic) unsigned short uShortField;

@property (nonatomic) unsigned long uLongField;

@property (nonatomic) unsigned long long uLongLongField;

@property (nonatomic) float floatField;

@property (nonatomic) double doubleField;

@property (nonatomic, strong) NSDate *dateField;

@property (nonatomic, strong) NSArray *jsonArrayField;

@property (nonatomic, strong) NSDictionary *jsonDictField;

@property (nonatomic, strong) SBBBridgeObject *bridgeSubObjectField;

@property (nonatomic, strong) NSArray *bridgeObjectArrayField;

@end



@interface SBBTestBridgeSubObject : SBBBridgeObject

@property (nonatomic, strong) NSString *stringField;

@end


@interface TestMappedSubObject : NSObject

@property (nonatomic, strong) NSString *textField;

@end


@interface TestMappedObject : NSObject

@property (nonatomic) double numericField;

@property (nonatomic, strong) NSArray *mappedObjectArrayField;

@property (nonatomic, strong) TestMappedSubObject *mappedObjectSubField;

@property (nonatomic, strong) NSString *dateStringField;

@end
