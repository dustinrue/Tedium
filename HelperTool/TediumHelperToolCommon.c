//
//	HelperToolCommon.c
//	Tedium
//
//	Created by Dustin Rue on 1/16/2012.
//	Copyright 2012. All rights reserved.
//

#import "TediumHelpertoolCommon.h"
#import "BetterAuthorizationSampleLib.h"

const BASCommandSpec kTediumHelperToolCommandSet[] = {
	{	kTediumHelperToolGetVersionCommand,		// commandName
		NULL,								// rightName
		NULL,								// rightDefaultRule
		NULL,								// rightDescriptionKey
		NULL								// userData
	},
    {   kTediumHelperToolSetAFPDestinationCommand,
        kTediumHelperToolSetAFPDestinationCommandRight,
        "allow",
        "SetAFPDestination",
        NULL
    },
    {   kTediumHelperToolSetDestinationCommand,
        kTediumHelperToolSetDestinationCommandRight,
        "allow",
        "SetDestination",
        NULL
    },
    {   kTediumHelperToolSetMobileBackupCommand,
        kTediumHelperToolSetMobileBackupCommandRight,
        "allow",
        "SetMobileBackup",
        NULL
    },
    {   kTediumHelperToolMobileBackupNowCommand,
        kTediumHelperToolMobileBackupNowCommandRight,
        "allow",
        "MobileBackupNow",
        NULL
    },
    {   kTediumHelperToolBackupNowCommand,
        kTediumHelperToolBackupNowCommandRight,
        "allow",
        "BackupNow",
        NULL
    },
    {	NULL,
		NULL,
		NULL,
		NULL,
		NULL
	}
};
