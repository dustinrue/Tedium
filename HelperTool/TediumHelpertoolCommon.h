//
//  HelperToolCommon.h
//  Tedium
//
//  Created by Dustin Rue on 1/16/2012.
//  Copyright 2012. All rights reserved.
//

#ifndef Tedium_HelperToolCommon_h
#define Tedium_HelperToolCommon_h

#import "BetterAuthorizationSampleLib.h"

// Helper tool version
#define kTediumHelperToolVersionNumber                  1

// Commands
#define kTediumHelperToolGetVersionCommand              "GetVersion"
#define kTediumHelperToolGetVersionResponse             "Version"

#define kTediumHelperToolSetDestinationCommand          "SetDestination"

#define kTediumHelperToolSetDestinationCommandRight         "com.dustinrue.Tedium.SetDestinationCommandRight"

// Commands array (keep in sync!)
extern const BASCommandSpec kTediumHelperToolCommandSet[];

#endif
