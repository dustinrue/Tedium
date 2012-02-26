//
//  AppDelegate+HelperTool.h
//  From ControlPlane
//
//  Created by David Jennes on 05/09/11.
//  Modified for use with Tedium by Dustin Rue
//  Copyright 2011. All rights reserved.
//

#import "AppDelegate+HelperTool.h"
#import "TediumHelpertoolCommon.h"

@interface AppDelegate (HelperTool_Private)

- (OSStatus) helperToolActualPerform: (NSString *) action
                       withParameter: (id) parameter
                            response: (CFDictionaryRef *) response
                                auth: (AuthorizationRef) auth;
- (void) helperToolInit: (AuthorizationRef *) auth;
- (OSStatus) helperToolFix: (BASFailCode) failCode withAuth: (AuthorizationRef) auth;
- (void) helperToolAlert: (NSMutableDictionary *) parameters;

@end

@implementation AppDelegate (HelperTool)


- (NSInteger) helperToolPerformAction: (NSString *) action {
    NSLog(@"called helper tool without a parameter");
    return [self helperToolPerformAction:action withParameter:nil];
}

- (NSInteger) helperToolPerformAction: (NSString *) action withParameter: (id) parameter {
	static int32_t versionCheck = 0;
	
	CFDictionaryRef response = NULL;
	AuthorizationRef auth = NULL;
	OSStatus error = noErr;
    NSLog(@"calling helper tool with %@", (NSString *)action);
	// initialize
	[self helperToolInit: &auth];
	
	if (!versionCheck) {
		// start version check
		OSAtomicIncrement32(&versionCheck);
		
		// get version of helper tool
        NSLog(@"checking HelperTool version");
		error = [self helperToolActualPerform: @kTediumHelperToolGetVersionCommand withParameter:nil response: &response auth: auth];
		if (error) {
            NSLog(@"HelperTool version check failed");
			OSAtomicDecrement32(&versionCheck);
			return NO;
		}
		
		// check version and update if needed
		NSNumber *version = [(__bridge_transfer NSDictionary *) response objectForKey: @kTediumHelperToolGetVersionResponse];
		if ([version intValue] < kTediumHelperToolVersionNumber)
			[self helperToolFix: kBASFailNeedsUpdate withAuth: auth];
		
		// finish version check
		OSAtomicIncrement32(&versionCheck);
	}
	
	//  wait until version check is done
	while (versionCheck < 2)
		[NSThread sleepForTimeInterval: 1];
	
	// perform actual action
    
    
	error = [self helperToolActualPerform: (NSString *) action withParameter: parameter response: &response auth: auth];
    
	
	return (error);
}

- (OSStatus) helperToolActualPerform: (NSString *) action
                       withParameter: (id) parameter
                            response: (CFDictionaryRef *) response
                                auth: (AuthorizationRef) auth {
	
	NSString *bundleID;
	NSDictionary *request;
	OSStatus error = 0;
	*response = NULL;
	
	// create request
	bundleID = [[NSBundle mainBundle] bundleIdentifier];
	assert(bundleID != NULL);
	if (parameter)
		request = [NSDictionary dictionaryWithObjectsAndKeys: action, @kBASCommandKey, parameter, @"param", nil];
	else
		request = [NSDictionary dictionaryWithObjectsAndKeys: action, @kBASCommandKey, nil];
	assert(request != NULL);
	
	// Execute it.
	error = BASExecuteRequestInHelperTool(auth,
										  kTediumHelperToolCommandSet, 
										  (__bridge_retained CFStringRef) bundleID, 
										  (__bridge_retained CFDictionaryRef) request,
										  response);
	
	// If it failed, try to recover.
	if (error != noErr && error != userCanceledErr) {
        NSLog(@"HelperTool call failed, it probably needs to get installed");
		BASFailCode failCode = BASDiagnoseFailure(auth, (__bridge_retained CFStringRef) bundleID);
		
		// try to fix
		error = [self helperToolFix: failCode withAuth: auth];
		
		// If the fix went OK, retry the request.
		if (error == noErr)
			error = BASExecuteRequestInHelperTool(auth,
												  kTediumHelperToolCommandSet,
												  (__bridge_retained CFStringRef) bundleID,
												  (__bridge_retained CFDictionaryRef) request,
												  response);
        else {
            NSLog(@"fixing HelperTool failed");
        }
	}
    NSLog(@"call to helper tool succeeded, helper tool returned: %d", error);
	
	// If all of the above went OK, it means that the IPC to the helper tool worked.  We 
	// now have to check the response dictionary to see if the command's execution within 
	// the helper tool was successful.
	
	if (error == noErr)
		error = BASGetErrorFromResponse(*response);
	
    NSLog(@"command returned %d", error);
	return error;
}

- (void) helperToolInit: (AuthorizationRef *) auth {
	OSStatus err = 0;
	
	// Create the AuthorizationRef that we'll use through this application.  We ignore 
	// any error from this.  A failure from AuthorizationCreate is very unusual, and if it 
	// happens there's no way to recover; Authorization Services just won't work.
	
	err = AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, auth);
	assert(err == noErr);
	assert((err == noErr) == (*auth != NULL));
	
	// For each of our commands, check to see if a right specification exists and, if not,
	// create it.
	//
	// The last parameter is the name of a ".strings" file that contains the localised prompts 
	// for any custom rights that we use.
	
	BASSetDefaultRules(*auth, 
					   kTediumHelperToolCommandSet, 
					   CFBundleGetIdentifier(CFBundleGetMainBundle()), 
					   CFSTR("HelperToolAuthorizationPrompts"));
}

- (OSStatus) helperToolFix: (BASFailCode) failCode withAuth: (AuthorizationRef) auth {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	OSStatus err = noErr;
	
	// At this point we tell the user that something has gone wrong and that we need 
	// to authorize in order to fix it.  Ideally we'd use failCode to describe the type of 
	// error to the user.
	
	[self performSelectorOnMainThread: @selector(helperToolAlert:) withObject: parameters waitUntilDone: YES];
	err = [[parameters objectForKey: @"result"] intValue];
	
	// Try to fix things.
	if (err == NSAlertDefaultReturn) {
        
		err = BASFixFailure(auth, ((__bridge_retained CFStringRef) bundleID), CFSTR("TediumHelperInstallTool"), CFSTR("TediumHelperTool"), failCode);
                      
	} else
		err = userCanceledErr;
	
	return err;
}

- (void) helperToolAlert: (NSMutableDictionary *) parameters {
	NSInteger t = NSRunAlertPanel(NSLocalizedString(@"Tedium Helper Needed", @"Fix helper tool"),
								  NSLocalizedString(@"Tedium needs to install a helper app read and modify Time Machine settings", @"Fix helper tool"),
								  NSLocalizedString(@"Install", @"Fix helper tool"),
								  NSLocalizedString(@"Cancel", @"Fix helper tool"),
								  NULL);
	
	[parameters setObject: [NSNumber numberWithInteger: t] forKey: @"result"];
}

@end
