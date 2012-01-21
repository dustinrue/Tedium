//
//	HelperTool.c
//	Tedium
//
//	Created by Dustin Rue on 1/16/2012.
//	Copyright 2012. All rights reserved.
//

#import <netinet/in.h>
#import <sys/socket.h>
#import <stdio.h>
#import <unistd.h>
#import <CoreServices/CoreServices.h>
#import <syslog.h>

#import "AuthorizationLib/BetterAuthorizationSampleLib.h"
#import "TediumHelpertoolCommon.h"

extern const BASCommandSpec kTediumHelperToolCommandSet[];


// Implements the GetVersionCommand. Returns the version number of the helper tool.
static OSStatus DoGetVersion(AuthorizationRef			auth,
							 const void *				userData,
							 CFDictionaryRef			request,
							 CFMutableDictionaryRef		response,
							 aslclient					asl,
							 aslmsg						aslMsg) {
	
	OSStatus retval = noErr;
	CFNumberRef value;
	static const unsigned int kCurrentVersion = kTediumHelperToolVersionNumber;
	
	assert(auth     != NULL);
	assert(request  != NULL);
	assert(response != NULL);
	
    syslog(LOG_DEBUG,"Getting Helper Tool Version");
	// Add to the response.
	value = CFNumberCreate(NULL, kCFNumberIntType, &kCurrentVersion);
	if (!value)
		retval = coreFoundationUnknownErr;
	else {
		CFDictionaryAddValue(response, CFSTR(kTediumHelperToolGetVersionResponse), value);
		CFRelease(value);
	}
	
	return retval;
}


// Implements the GetVersionCommand. Returns the version number of the helper tool.
static OSStatus DoSetDestination(AuthorizationRef			auth,
                                 const void *				userData,
                                 CFDictionaryRef			request,
                                 CFMutableDictionaryRef		response,
                                 aslclient					asl,
                                 aslmsg						aslMsg) {
	
	OSStatus retval = noErr;
	
	
	
	assert(auth     != NULL);
	assert(request  != NULL);
	assert(response != NULL);
	return retval;
    
}



#pragma mark -
#pragma mark Tool Infrastructure

// the list defined here must match (same order) the list in CPHelperToolCommon.c
static const BASCommandProc kHelperToolCommandProcs[] = {
	DoGetVersion,
    DoSetDestination,
	NULL
};

int main(int argc, char **argv) {
	// Go directly into BetterAuthorizationSampleLib code.
	
	// IMPORTANT
	// BASHelperToolMain doesn't clean up after itself, so once it returns 
	// we must quit.
	
	return BASHelperToolMain(kTediumHelperToolCommandSet, kHelperToolCommandProcs);
}
