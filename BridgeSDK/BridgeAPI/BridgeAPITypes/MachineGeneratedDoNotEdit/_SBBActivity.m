//
//  _SBBActivity.m
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
// Make changes to SBBActivity.m instead.
//

#import "_SBBActivity.h"
#import "ModelObjectInternal.h"
#import "NSDate+SBBAdditions.h"

#import "SBBCompoundActivity.h"
#import "SBBSurveyReference.h"
#import "SBBTaskReference.h"

@interface _SBBActivity()

@end

// see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/602958/documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface NSManagedObject (Activity)

@property (nullable, nonatomic, retain) NSString* activityType;

@property (nullable, nonatomic, retain) NSString* guid;

@property (nullable, nonatomic, retain) NSString* label;

@property (nullable, nonatomic, retain) NSString* labelDetail;

@property (nullable, nonatomic, retain) NSManagedObject *compoundActivity;

@property (nullable, nonatomic, retain) NSManagedObject *schedule;

@property (nullable, nonatomic, retain) NSManagedObject *scheduledActivity;

@property (nullable, nonatomic, retain) NSManagedObject *survey;

@property (nullable, nonatomic, retain) NSManagedObject *task;

@end

@implementation _SBBActivity

- (instancetype)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

#pragma mark Scalar values

#pragma mark Dictionary representation

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary objectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    [super updateWithDictionaryRepresentation:dictionary objectManager:objectManager];

    self.activityType = [dictionary objectForKey:@"activityType"];

    self.guid = [dictionary objectForKey:@"guid"];

    self.label = [dictionary objectForKey:@"label"];

    self.labelDetail = [dictionary objectForKey:@"labelDetail"];

    NSDictionary *compoundActivityDict = [dictionary objectForKey:@"compoundActivity"];

    if (compoundActivityDict != nil)
    {
        SBBCompoundActivity *compoundActivityObj = [objectManager objectFromBridgeJSON:compoundActivityDict];
        self.compoundActivity = compoundActivityObj;
    }

    NSDictionary *surveyDict = [dictionary objectForKey:@"survey"];

    if (surveyDict != nil)
    {
        SBBSurveyReference *surveyObj = [objectManager objectFromBridgeJSON:surveyDict];
        self.survey = surveyObj;
    }

    NSDictionary *taskDict = [dictionary objectForKey:@"task"];

    if (taskDict != nil)
    {
        SBBTaskReference *taskObj = [objectManager objectFromBridgeJSON:taskDict];
        self.task = taskObj;
    }

}

- (NSDictionary *)dictionaryRepresentationFromObjectManager:(id<SBBObjectManagerProtocol>)objectManager
{
    NSMutableDictionary *dict = [[super dictionaryRepresentationFromObjectManager:objectManager] mutableCopy];

    [dict setObjectIfNotNil:self.activityType forKey:@"activityType"];

    [dict setObjectIfNotNil:self.guid forKey:@"guid"];

    [dict setObjectIfNotNil:self.label forKey:@"label"];

    [dict setObjectIfNotNil:self.labelDetail forKey:@"labelDetail"];

    [dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.compoundActivity] forKey:@"compoundActivity"];

    [dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.survey] forKey:@"survey"];

    [dict setObjectIfNotNil:[objectManager bridgeJSONFromObject:self.task] forKey:@"task"];

	return [dict copy];
}

- (void)awakeFromDictionaryRepresentationInit
{
	if (self.sourceDictionaryRepresentation == nil)
		return; // awakeFromDictionaryRepresentationInit has been already executed on this object.

	[self.task awakeFromDictionaryRepresentationInit];
	[self.survey awakeFromDictionaryRepresentationInit];
	[self.compoundActivity awakeFromDictionaryRepresentationInit];

	[super awakeFromDictionaryRepresentationInit];
}

#pragma mark Core Data cache

+ (NSString *)entityName
{
    return @"Activity";
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject objectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{

    if (self = [super initWithManagedObject:managedObject objectManager:objectManager cacheManager:cacheManager]) {

        self.activityType = managedObject.activityType;

        self.guid = managedObject.guid;

        self.label = managedObject.label;

        self.labelDetail = managedObject.labelDetail;

            NSManagedObject *compoundActivityManagedObj = managedObject.compoundActivity;
        Class compoundActivityClass = [SBBObjectManager bridgeClassFromType:compoundActivityManagedObj.entity.name];
        SBBCompoundActivity *compoundActivityObj = [[compoundActivityClass alloc] initWithManagedObject:compoundActivityManagedObj objectManager:objectManager cacheManager:cacheManager];
        if (compoundActivityObj != nil)
        {
          self.compoundActivity = compoundActivityObj;
        }
            NSManagedObject *surveyManagedObj = managedObject.survey;
        Class surveyClass = [SBBObjectManager bridgeClassFromType:surveyManagedObj.entity.name];
        SBBSurveyReference *surveyObj = [[surveyClass alloc] initWithManagedObject:surveyManagedObj objectManager:objectManager cacheManager:cacheManager];
        if (surveyObj != nil)
        {
          self.survey = surveyObj;
        }
            NSManagedObject *taskManagedObj = managedObject.task;
        Class taskClass = [SBBObjectManager bridgeClassFromType:taskManagedObj.entity.name];
        SBBTaskReference *taskObj = [[taskClass alloc] initWithManagedObject:taskManagedObj objectManager:objectManager cacheManager:cacheManager];
        if (taskObj != nil)
        {
          self.task = taskObj;
        }
    }

    return self;

}

- (NSManagedObject *)createInContext:(NSManagedObjectContext *)cacheContext withObjectManager:(id<SBBObjectManagerProtocol>)objectManager cacheManager:(id<SBBCacheManagerProtocol>)cacheManager
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:cacheContext];
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

    managedObject.activityType = ((id)self.activityType == [NSNull null]) ? nil : self.activityType;

    managedObject.guid = ((id)self.guid == [NSNull null]) ? nil : self.guid;

    managedObject.label = ((id)self.label == [NSNull null]) ? nil : self.label;

    managedObject.labelDetail = ((id)self.labelDetail == [NSNull null]) ? nil : self.labelDetail;

    // destination entity CompoundActivity is not directly cacheable, so delete it and create the replacement
    if (managedObject.compoundActivity) {
        [cacheContext deleteObject:managedObject.compoundActivity];
    }
    NSManagedObject *relMoCompoundActivity = [self.compoundActivity createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];

    [managedObject setCompoundActivity:relMoCompoundActivity];

    // destination entity SurveyReference is not directly cacheable, so delete it and create the replacement
    if (managedObject.survey) {
        [cacheContext deleteObject:managedObject.survey];
    }
    NSManagedObject *relMoSurvey = [self.survey createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];

    [managedObject setSurvey:relMoSurvey];

    // destination entity TaskReference is not directly cacheable, so delete it and create the replacement
    if (managedObject.task) {
        [cacheContext deleteObject:managedObject.task];
    }
    NSManagedObject *relMoTask = [self.task createInContext:cacheContext withObjectManager:objectManager cacheManager:cacheManager];

    [managedObject setTask:relMoTask];

    // Calling code will handle saving these changes to cacheContext.
}

#pragma mark Direct access

- (void) setCompoundActivity: (SBBCompoundActivity*) compoundActivity_ settingInverse: (BOOL) setInverse
{

    _compoundActivity = compoundActivity_;

}

- (void) setCompoundActivity: (SBBCompoundActivity*) compoundActivity_
{
    [self setCompoundActivity: compoundActivity_ settingInverse: YES];
}

- (SBBCompoundActivity*) compoundActivity
{
    return _compoundActivity;
}

- (void) setSurvey: (SBBSurveyReference*) survey_ settingInverse: (BOOL) setInverse
{

    _survey = survey_;

}

- (void) setSurvey: (SBBSurveyReference*) survey_
{
    [self setSurvey: survey_ settingInverse: YES];
}

- (SBBSurveyReference*) survey
{
    return _survey;
}

- (void) setTask: (SBBTaskReference*) task_ settingInverse: (BOOL) setInverse
{

    _task = task_;

}

- (void) setTask: (SBBTaskReference*) task_
{
    [self setTask: task_ settingInverse: YES];
}

- (SBBTaskReference*) task
{
    return _task;
}

@synthesize compoundActivity = _compoundActivity;@synthesize survey = _survey;@synthesize task = _task;

@end
