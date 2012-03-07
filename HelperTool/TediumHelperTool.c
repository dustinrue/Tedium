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


// Implements the SetAFPDestination. 
static OSStatus DoSetAFPDestination(AuthorizationRef		auth,
                                 const void *				userData,
                                 CFDictionaryRef			request,
                                 CFMutableDictionaryRef		response,
                                 aslclient					asl,
                                 aslmsg						aslMsg) {
	
	OSStatus retval = noErr;
	
	assert(auth     != NULL);
	assert(request  != NULL);
	assert(response != NULL);
    
    CFDictionaryRef parameters = (CFDictionaryRef) CFDictionaryGetValue(request, CFSTR("param"));
    CFStringRef uname     = (CFStringRef) CFDictionaryGetValue(parameters, CFSTR("username"));
    CFStringRef pwd       = (CFStringRef) CFDictionaryGetValue(parameters, CFSTR("password"));
    CFStringRef host      = (CFStringRef) CFDictionaryGetValue(parameters, CFSTR("hostname"));
    CFStringRef url       = (CFStringRef) CFDictionaryGetValue(parameters, CFSTR("url"));
    

    if (uname == NULL) 
        return BASErrnoToOSStatus(EINVAL);
    
    if (pwd == NULL)
        return BASErrnoToOSStatus(EINVAL);
    
    if (!host)
        return BASErrnoToOSStatus(EINVAL);
    
    if (!url)
        return BASErrnoToOSStatus(EINVAL);
    
    char command[1024];
    char hostname[1024];
    char username[1024];
    char password[1024];
    char theUrl[1024];

    Boolean success;

    success = CFStringGetCString(uname, username, 1024, kCFStringEncodingUTF8);
    
    if (!success) 
        return BASErrnoToOSStatus(EINVAL);;
    
    success = CFStringGetCString(pwd, password, 1024, kCFStringEncodingUTF8);
    
    if (!success) 
        return BASErrnoToOSStatus(EINVAL);
    
    success = CFStringGetCString(host, hostname, 1024, kCFStringEncodingUTF8);
    
    if (!success)
        return BASErrnoToOSStatus(EINVAL);
    
    success = CFStringGetCString(url, theUrl, 1024, kCFStringEncodingUTF8);
    
    if (!success)
        return BASErrnoToOSStatus(EINVAL);
            
    sprintf(command, "/usr/bin/tmutil setdestination afp://\"%s\":\"%s\"@%s%s", username, password, hostname, theUrl);

    retval = system(command);
	return retval;
    
}

// Implements the SetDestination. 
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
    
    CFStringRef parameter = (CFStringRef) CFDictionaryGetValue(request, CFSTR("param"));
    
    char command[256];
    char parameters[1024];
    
    CFStringGetCString(parameter,parameters,1024, kCFStringEncodingUTF8);
    
    //syslog(LOG_EMERG,"running command with '%s'", parameters);
    sprintf(command, "/usr/bin/tmutil setdestination '%s'", parameters);
    retval = system(command);
    //syslog(LOG_EMERG, "command finished");
	return retval;
    
}

// Implements the SetMobileBackup. Returns the version number of the helper tool.
static OSStatus DoSetMobileBackup(AuthorizationRef			auth,
                                 const void *				userData,
                                 CFDictionaryRef			request,
                                 CFMutableDictionaryRef		response,
                                 aslclient					asl,
                                 aslmsg						aslMsg) {
	
	OSStatus retval = noErr;
	int value;
	
	
	assert(auth     != NULL);
	assert(request  != NULL);
	assert(response != NULL);

    CFNumberRef parameter = (CFNumberRef) CFDictionaryGetValue(request, CFSTR("param"));
    
    char command[256];
    
    CFNumberGetValue(parameter, kCFNumberSInt32Type, &value);
    
    
    if (value) 
        sprintf(command, "/usr/bin/tmutil enablelocal");
    else
        sprintf(command, "/usr/bin/tmutil disablelocal");
    
    retval = system(command);
    //syslog(LOG_EMERG, "command finished");
	return retval;
    
}

// Implements the SetMobileBackup. Returns the version number of the helper tool.
static OSStatus DoMobileBackupNow(AuthorizationRef			auth,
                                  const void *				userData,
                                  CFDictionaryRef			request,
                                  CFMutableDictionaryRef	response,
                                  aslclient					asl,
                                  aslmsg					aslMsg) {
	
	OSStatus retval = noErr;
	
	assert(auth     != NULL);
	assert(request  != NULL);
	assert(response != NULL);
    
    
    char command[256];
    
    sprintf(command, "/usr/bin/tmutil snapshot");
    
    retval = system(command);
    //syslog(LOG_EMERG, "command finished");
	return retval;
    
}

// Implements the SetMobileBackup. Returns the version number of the helper tool.
static OSStatus DoBackupNow(AuthorizationRef                auth,
                                  const void *				userData,
                                  CFDictionaryRef			request,
                                  CFMutableDictionaryRef	response,
                                  aslclient					asl,
                                  aslmsg					aslMsg) {
	
	OSStatus retval = noErr;


	assert(auth     != NULL);
	assert(request  != NULL);
	assert(response != NULL);
    
    char command[256];
    
    

    sprintf(command, "/usr/bin/tmutil startbackup");

    
    retval = system(command);
    //syslog(LOG_EMERG, "command finished");
	return retval;
    
}

#pragma mark -
#pragma mark Tool Infrastructure

// the list defined here must match (same order) the list in CPHelperToolCommon.c
static const BASCommandProc kHelperToolCommandProcs[] = {
	DoGetVersion,
    DoSetAFPDestination,
    DoSetDestination,
    DoSetMobileBackup,
    DoMobileBackupNow,
    DoBackupNow,
	NULL
};

int main(int argc, char **argv) {
	// Go directly into BetterAuthorizationSampleLib code.
	
	// IMPORTANT
	// BASHelperToolMain doesn't clean up after itself, so once it returns 
	// we must quit.
	
	return BASHelperToolMain(kTediumHelperToolCommandSet, kHelperToolCommandProcs);
}
