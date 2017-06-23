//
//  BridgeSDK+Internal.h
//  BridgeSDK
//
//	Copyright (c) 2015-2017, Sage Bionetworks
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

#import "BridgeSDK.h"

#define V3_API_PREFIX @"/v3"
#define V4_API_PREFIX @"/v4"

// SBBBUNDLEID is a preprocessor macro defined in the build settings; this converts it to an NSString literal
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SBBBUNDLEIDSTRING @STRINGIZE2(SBBBUNDLEID)

// Logging macros to prepend with file, line, & function/method info
#define SBBPrettyLogInfo()                             \
([NSString stringWithFormat: @"%@ line %d (%s)",    \
@(__FILE__).lastPathComponent,                      \
(int) (__LINE__),                                   \
(__PRETTY_FUNCTION__)                               \
])

#define SBBLog(format, ...) NSLog(@"%@: %@", SBBPrettyLogInfo(), [NSString stringWithFormat:format, ##__VA_ARGS__])


@protocol SBBBridgeErrorUIDelegate;

extern _Nullable id<SBBBridgeErrorUIDelegate> gSBBErrorUIDelegate;

@interface BridgeSDK (internal)

+ (BOOL)isRunningInAppExtension;

@end

