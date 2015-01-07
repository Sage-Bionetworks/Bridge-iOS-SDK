//
//  BridgeSDKInternal.h
//  BridgeSDK
//
//  Created by Erin Mounts on 1/7/15.
//  Copyright (c) 2015 Sage Bionetworks. All rights reserved.
//

// SBBBUNDLEID is a preprocessor macro defined in the build settings; this converts it to an NSString literal
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SBBBUNDLEIDSTRING @STRINGIZE2(SBBBUNDLEID)

