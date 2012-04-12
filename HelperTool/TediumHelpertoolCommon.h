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
#define kTediumHelperToolVersionNumber                  5

// Commands
#define kTediumHelperToolGetVersionCommand              "GetVersion"
#define kTediumHelperToolGetVersionResponse             "Version"

#define kTediumHelperToolSetAFPDestinationCommand       "SetAFPDestination"
#define kTediumHelperToolSetDestinationCommand          "SetDestination"
#define kTediumHelperToolSetMobileBackupCommand         "SetMobileBackup"

#define kTediumHelperToolMobileBackupNowCommand         "MobileBackupNow"
#define kTediumHelperToolBackupNowCommand               "BackupNow"

#define kTediumHelperToolSetAFPDestinationCommandRight  "com.dustinrue.Tedium.SetAFPDestinationCommandRight"
#define kTediumHelperToolSetDestinationCommandRight     "com.dustinrue.Tedium.SetDestinationCommandRight"
#define kTediumHelperToolSetMobileBackupCommandRight    "com.dustinrue.Tedium.SetMobileBackupCommandRight"
#define kTediumHelperToolMobileBackupNowCommandRight    "com.dustinrue.Tedium.MobileBackupNowCommandRight"
#define kTediumHelperToolBackupNowCommandRight          "com.dustinrue.Tedium.BackupNowCommandRight"

// Commands array (keep in sync!)
extern const BASCommandSpec kTediumHelperToolCommandSet[];

#endif
