//
//  SBBNotificationRegistration.h
//
//	Copyright (c) 2017 Sage Bionetworks
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

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@protocol SBBNotificationRegistration

@end

@interface SBBNotificationRegistration : SBBBridgeObject

/*
 The guid is how bridge unqieuly links an account with a group of device IDs
 It is used to update or delete a particular device ID without affecting the rest
 */
@property (nonatomic, strong) NSString* guid;

/*
 This should be either the device token retrieved from the iOS operation system, or the registrationId on Android.
 */
@property (nonatomic, strong) NSString* deviceId;

/*
     Information used to track which type of deviceId is being submitted. This string should be either "Android" or "iPhone OS" ("iOS" also works), and should match the operating system from which you retrieved a push notification identifier (deviceId).
 */
@property (nonatomic, strong) NSString* osName;

/*
 Date the client registered for push notifications with Bridge.
 */
@property (nonatomic, strong) NSString* createdOn;

/*
 The last time the registration was updated based on a new device identifier being issued by the client operating system (iOS or Android). If an updated registration is submitted but the deviceId has not changed, the record is not modified.
 */
@property (nonatomic, strong) NSString* modifiedOn;

/*
 Usually "NotificationRegistration"
 */
@property (nonatomic, strong) NSString* type;

@end
