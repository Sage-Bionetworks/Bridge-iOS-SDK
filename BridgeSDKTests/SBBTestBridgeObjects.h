//
//  SBBTestBridgeObjects.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/29/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBTestObjects.h"

@interface TestMappedSubObject : NSObject

@property (nonatomic, strong) NSString *textField;

@end


@interface TestMappedObject : NSObject

@property (nonatomic) double numericField;

@property (nonatomic, strong) NSArray *mappedObjectArrayField;

@property (nonatomic, strong) TestMappedSubObject *mappedObjectSubField;

@property (nonatomic, strong) NSString *dateStringField;

@end
