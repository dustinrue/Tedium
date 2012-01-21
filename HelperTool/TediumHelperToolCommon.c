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
    {   kTediumHelperToolSetDestinationCommand,
        kTediumHelperToolSetDestinationCommandRight,
        "allow",
        "SetDestination",
        NULL
    },
    {	NULL,
		NULL,
		NULL,
		NULL,
		NULL
	}
};
