//
//  _SBBSurveyQuestion.m
//
//	Copyright (c) 2014-2016 Sage Bionetworks
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
// Make changes to SBBSurveyQuestion.m instead.
//

#import "_SBBSurveyQuestion.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBSurveyConstraints.h"

@interface _SBBSurveyQuestion()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (SurveyQuestion)

@property (nullable, nonatomic, retain) NSString* uiHint;

@property (nullable, nonatomic, retain) NSManagedObject *constraints;

@end

@implementation _SBBSurveyQuestion

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

    self.uiHint = [dictionary objectForKey:@"uiHint"];

    NSDictionary *constraintsDict = [dictionary objectForKey:@"constraints"];

    if(constraintsDict != nil)
    {
        SBBSurveyConstraints *constraintsObj = [objectManager objectFromBridgeJSON:constraintsDict];
        self.constraints = constraintsObj;
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.uiHint forKey:@"uiHint"];

    [dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.constraints] forKey:@"constraints"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if(self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.constraints awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"SurveyQuestion";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.uiHint = managedObject.uiHint;

            NSManagedObject *constraintsManagedObj = managedObject.constraints;
        Class constraintsClass = [SBBObjectManager bridgeClassFromType:constraintsManagedObj.entity.name];
        SBBSurveyConstraints *constraintsObj = [[constraintsClass alloc] initWithManagedObject:constraintsManagedObj objectManager:objectManager cacheManager:cacheManager];
        if(constraintsObj != nil)
        {
          self.constraints = constraintsObj;
        }
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyQuestion" inManagedObjectContext:cacheContext];
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
    NSManagedObjectContext *cacheContext = managedObject.managedObjectContext;

    managedObject.uiHint = ((id)self.uiHint == [NSNull null]) ? nil : self.uiHint;

    // destination entity SurveyConstraints is not directly cacheable, so delete it and create the replacement
    if (managedObject.constraints) {
        [cacheContext deleteObject:managedObject.constraints];
    }
    NSManagedObject *relMoConstraints = [self.constraints createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];

    [managedObject setConstraints:relMoConstraints];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void) setConstraints: (SBBSurveyConstraints*) constraints_ settingInverse: (BOOL) setInverse
{

    _constraints = constraints_;

}

- (void) setConstraints: (SBBSurveyConstraints*) constraints_
{
    [self setConstraints: constraints_ settingInverse: YES];
}

- (SBBSurveyConstraints*) constraints
{
    return _constraints;
}

@synthesize constraints = _constraints;

@end
