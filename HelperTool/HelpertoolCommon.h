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
#define kHelperToolVersionNumber              1

// Commands
#define kHelperToolGetVersionCommand              "GetVersion"
#define kHelperToolGetVersionResponse             "Version"


// Commands array (keep in sync!)
extern const BASCommandSpec kHelperToolCommandSet[];

#endif
