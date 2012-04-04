//
//  AppDelegate.m
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+HelperTool.h"
#import "TediumHelpertoolCommon.h"
#import "KeychainServices.h"
#import "NSString+Bonjour.h"
#import "NSArray+Bonjour.h"
#import "NSDictionary+Bonjour.h"


@implementation AppDelegate
@synthesize versionString;
@synthesize destinationsSubMenu;
@synthesize mobileBackupNowMenuItem;
@synthesize backupNowMenuItem;
@synthesize usernameFieldControl;

@synthesize window = _window;
@synthesize currentDestination;
@synthesize activeSheet;
@synthesize destinationValueFromSheet;
@synthesize destinations;
@synthesize destination;
@synthesize currentDestinationAsNSURL;
@synthesize hideMenuBarIconStatus;
@synthesize localSnapshotsStatus;
@synthesize checkForUpdatesStatusForMenu;
@synthesize creditsFile;
@synthesize networkBrowser;
@synthesize foundDisks;
@synthesize selectedBonjourShare;
@synthesize usernameFromSheet;
@synthesize passwordFromSheet;
@synthesize shareToBeAdded;
@synthesize menuBarMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[BWQuincyManager sharedQuincyManager] setSubmissionURL:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"TediumCrashReportURL"]];
    [[BWQuincyManager sharedQuincyManager] setCompanyName:@"Tedium developers"];
    [[BWQuincyManager sharedQuincyManager] setDelegate:self];
    
    menuBarImage = [self prepareImageForMenubar:@"awesomeclock"];
    [self showInStatusBar:nil];
    [self setMenuBarImage:menuBarImage];
    
    foundDisks = [[NSMutableArray alloc] init];
    
    
    [self setNetworkBrowser:[[NetworkBrowser alloc] init]];
    [[self networkBrowser] start];

    
   	[GrowlApplicationBridge setGrowlDelegate: self];
    processInfo = [NSProcessInfo processInfo];
    [processInfo enableSuddenTermination];
    
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
	[appDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"SUCheckAtStartup"];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"SUEnableAutomaticChecks"];
    [appDefaults setValue:[NSNumber numberWithBool:NO] forKey:@"HideStatusBarIcon"];
    
    
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    [self setDestinations:[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"destinations"]]];
    
    if (![self destinations]) 
        [self setDestinations:[[NSMutableArray alloc] init]];
    
 
    //[destinationsTableView setDoubleAction:@selector(editDestination:)];
    [foundSharesTableView setDoubleAction:@selector(closeSheetWithOK:)];

    ([[NSUserDefaults standardUserDefaults] boolForKey:@"HideStatusBarIcon"] ? [self enableHideMenuBarIcon] : [self disableHideMenuBarIcon]);
    
    [startAtLoginStatusForMenu setState:[self willStartAtLogin:[self appPath]] ? 1:0];
    [hideMenuBarIconStatusForMenu setState:[self willHideMenuBarIcon] ? 1:0];
    [checkForUpdatesStatusForMenu setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"SUEnableAutomaticChecks"]];
    [localSnapshotsStatusForMenu setState:[self isLocalSnapshotsEnabled]];
    [self populateDestinationsSubMenu];
    
    [self setPasswordFromSheet:@""];
    [self setUsernameFromSheet:@""];
    [networkBrowser setDelegate:self];
    [[self mobileBackupNowMenuItem] setEnabled:NO];
    [self toggleMobileBackupMenuItem];
    
    [menuBarMenu update];
}


#pragma mark -
#pragma mark Menu Bar Icon
// Helper: Load a named image, and scale it to be suitable for menu bar use.
- (NSImage *)prepareImageForMenubar:(NSString *)name {
	NSImage *img = [NSImage imageNamed:name];
	[img setScalesWhenResized:YES];
	[img setSize:NSMakeSize(16, 16)];
    
	return img;
}

- (void)setMenuBarImage:(NSImage *)imageName {
    
    // if the menu bar item has been hidden menuBarStatusItem will have been released
    // and we should not attempt to update the image
    if (!menuBarStatusItem)
        return;
    

    [menuBarStatusItem setImage:imageName];

}

- (void)showInStatusBar:(id)sender {
	if (menuBarStatusItem) {
		// Already there? Rebuild it anyway.
		[[NSStatusBar systemStatusBar] removeStatusItem:menuBarStatusItem];
	}
    
    menuBarStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[menuBarStatusItem setHighlightMode:YES];
    


	[menuBarStatusItem setMenu:menuBarMenu];
    [self setMenuBarImage:menuBarImage];
}
- (void) enableHideMenuBarIcon {
    [self setHideMenuBarIconStatus:YES];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"HideStatusBarIcon"];
    [self saveSettings];
    sbHideTimer = [NSTimer scheduledTimerWithTimeInterval: (NSTimeInterval)STATUS_BAR_LINGER
                                                   target: self
                                                 selector: @selector(hideFromStatusBar:)
                                                 userInfo: nil
                                                  repeats: NO];
    [hideMenuBarIconStatusForMenu setState:[self willHideMenuBarIcon] ? 1:0];
}

- (void) disableHideMenuBarIcon {
    [self setHideMenuBarIconStatus:NO];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"HideStatusBarIcon"];
    
    if (sbHideTimer)
        [sbHideTimer invalidate];
    [self saveSettings];
    [hideMenuBarIconStatusForMenu setState:[self willHideMenuBarIcon] ? 1:0];
}

- (BOOL) willHideMenuBarIcon {
    return [self hideMenuBarIconStatus];
}

- (IBAction)toggleHideMenuBarIcon:(id)sender {
    if ([self willHideMenuBarIcon]) {
        [self disableHideMenuBarIcon];
    }
    else {
        [self enableHideMenuBarIcon];
        
    }
    [hideMenuBarIconStatusForMenu setState:[self willHideMenuBarIcon] ? 1:0];
}

- (void)hideFromStatusBar:(NSTimer *)theTimer {
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HideStatusBarIcon"])
		return;
    
	[[NSStatusBar systemStatusBar] removeStatusItem:menuBarStatusItem];
    
}


#pragma mark -
#pragma mark Growl Support
- (void) growlMessage:(NSString *)title message:(NSString *)message  {
    const int pri = 0;
    
    [GrowlApplicationBridge notifyWithTitle:title
								description:message
						   notificationName:@"TediumGrowl"
								   iconData:nil
								   priority:pri
								   isSticky:NO
							   clickContext:nil];
}

- (NSDictionary *) registrationDictionaryForGrowl {
    NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:1],
                         @"TicketVersion",
                         [NSArray arrayWithObject:@"TediumGrowl"], 
                         @"AllNotifications",
                         [NSArray arrayWithObject:@"TediumGrowl"], 
                         @"DefaultNotifications",
                         nil];
    return tmp;
}


- (void)saveSettings {
    [[NSUserDefaults standardUserDefaults] setObject:[self destinations] forKey:@"destinations"];
   	[[NSUserDefaults standardUserDefaults] synchronize];

}


#pragma mark -
#pragma mark Destination Handling
- (void)addNewDestination:(NSDictionary *)newDestination {

    // test to see if the destination is already inserted
    // there has to be a more efficient way of handling this...
    for (NSDictionary * aDictionary in [self destinations])
    {
        
        NSString *aDestination = [aDictionary valueForKey:@"destinationVolumePath"];

        if ([aDestination isEqualToString:[newDestination valueForKey:@"cleanURL"]])
            return;
    }

    if ([[newDestination valueForKey:@"isAFP"] boolValue]) {
        // if the selectedRow is NOT -1 then we are editing an entry
        if ([destinationsTableView selectedRow] != -1) {
            [[self destinations] replaceObjectAtIndex:[destinationsTableView selectedRow] withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [newDestination valueForKey:@"cleanURL"], @"destinationVolumePath",
                                            [newDestination valueForKey:@"username"], @"username",
                                            [newDestination valueForKey:@"hostname"], @"hostname", 
                                            [NSNumber numberWithInt:1], @"isAFP",
                                            [newDestination valueForKey:@"url"], @"url",nil]];
            
            [destinationsTableView deselectAll:self];
            
            
            if ([KeychainServices checkForExistanceOfKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[newDestination valueForKey:@"username"] withAddress:[[newDestination valueForKey:@"cleanURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
                if (![KeychainServices modifyKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[newDestination valueForKey:@"username"] withNewPassword:[newDestination valueForKey:@"password"] withAddress:[[newDestination valueForKey:@"cleanURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
                    [self growlMessage:@"Keychain Failure" message:[NSString stringWithFormat:@"Failed to update the password for %@ to the keychain",[newDestination valueForKey:@"cleanURL"]]];
                }
            }
            else {
                if (![KeychainServices addKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[newDestination valueForKey:@"username"] withPassword:[newDestination valueForKey:@"password"] withAddress:[[newDestination valueForKey:@"cleanURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
                    [self growlMessage:@"Keychain Failure" message:[NSString stringWithFormat:@"Failed to add the password for %@ to the keychain",[newDestination valueForKey:@"cleanURL"]]];
                }
            }
        }
        else {
            [[self destinations] addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [newDestination valueForKey:@"cleanURL"], @"destinationVolumePath", 
                                 [newDestination valueForKey:@"username"], @"username",
                                 [newDestination valueForKey:@"hostname"], @"hostname",
                                 [NSNumber numberWithInt:1], @"isAFP",
                                 [newDestination valueForKey:@"url"], @"url",           nil]];
            if (![KeychainServices addKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[newDestination valueForKey:@"username"] withPassword:[newDestination valueForKey:@"password"] withAddress:[[newDestination valueForKey:@"cleanURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
                [self growlMessage:@"Keychain Failure" message:[NSString stringWithFormat:@"Failed to add the password for %@ to the keychain",[newDestination valueForKey:@"cleanURL"]]];
            }
        }
        
        
        
    }
    else {
        if ([destinationsTableView selectedRow] != -1) {
            [[self destinations] replaceObjectAtIndex:[destinationsTableView selectedRow] withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [newDestination valueForKey:@"cleanURL"], @"destinationVolumePath",
                                            [NSNumber numberWithInt:0], @"isAFP",nil]];
            [destinationsTableView deselectAll:self];
        }
        else {
            [[self destinations] addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [newDestination valueForKey:@"cleanURL"], @"destinationVolumePath",
                                 [NSNumber numberWithInt:0], @"isAFP",nil]];
        }
    }
    
    [self saveSettings];
    [destinationsSubMenu removeAllItems];
    [self populateDestinationsSubMenu];
    [destinationsTableView reloadData];
}

- (NSMutableDictionary *)parseDestination:(NSString *)destinationToParse {

    NSMutableDictionary *retDictionary = nil;
    NSString *urlText = [destinationToParse stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self setCurrentDestinationAsNSURL:[NSURL URLWithString:urlText]];
    
    // it isn't an AFP URL so we simply return
    if ([self currentDestinationAsNSURL] == nil)
        return nil;
        

    NSString *hostname = [[self currentDestinationAsNSURL] host];
    NSString *url      = [[self currentDestinationAsNSURL] path];
    NSString *username = [[self currentDestinationAsNSURL] user];
    
    // if the URL couldn't be parsed return an empty NSDictionary
    if (!hostname || !url) {
        retDictionary = [[NSMutableDictionary alloc] init];
        return [[NSMutableDictionary alloc] init];
    }
    
    retDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     hostname, @"hostname",
                     url, @"url", nil];
    
    if (username)
        [retDictionary setValue:username forKey:@"username"];
    
    return retDictionary;

    
}

// this gets the "destinationVolumePath" from either the destinations
// menu or the tableview.  We need to look that value up in the 
// destinations array and grab the associated values.
- (void) setCurrentDestination:(NSString *)newVal {
    
    NSString *password;
    NSString *command;
    NSInteger retval;
    NSMutableDictionary *tmp = nil;
    
    for (NSMutableDictionary *dest in [self destinations]) {
        if ([[dest valueForKey:@"destinationVolumePath"] isEqualToString:newVal]) {
            tmp = [dest mutableCopy];
        }
    }
    if (!tmp) {
        tmp = [[self parseDestination:newVal] mutableCopy];
        [tmp setValue:[self cleanURL:[NSString stringWithFormat:@"afp://%@@%@%@", [tmp valueForKey:@"username"], [tmp valueForKey:@"hostname"], [tmp valueForKey:@"url"]]] forKey:@"cleanURL"];
    }

    // if isAFP then this is an AFP share and we need to call the
    // appropriate command 
    if ([[tmp valueForKey:@"isAFP"] intValue] == 1) {
        command = @kTediumHelperToolSetAFPDestinationCommand;
        password = [KeychainServices getPasswordFromKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[tmp valueForKey:@"username"] withAddress:[[tmp valueForKey:@"destinationVolumePath"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [self growlMessage:@"Updating Destination" message:[NSString stringWithFormat:@"Changing Time Machine destination to %@", [tmp valueForKey:@"destinationVolumePath"]]];
    }
    
    // not an AFP share so we basically pass destinationVolumePath to 
    // tmutil as is
    else {
        command = @kTediumHelperToolSetDestinationCommand;
        [self growlMessage:@"Updating Destination" message:[NSString stringWithFormat:@"Changing Time Machine destination to %@", newVal]];
    }
    

    if ([[tmp valueForKey:@"isAFP"] intValue] == 1)
        [tmp setValue:password forKey:@"password"];
    

    if ([[tmp valueForKey:@"isAFP"] intValue] == 1) {
        retval = [self helperToolPerformAction: command withParameter:tmp];
    }
    else 
        retval = [self helperToolPerformAction: command withParameter:newVal];
    
    switch (retval) {
        case kDestinationVolumeSetSuccessfully:
            [self growlMessage:@"Succesfully changed backup destination" message:@"Backup destination was changed successfully"];
            break;
            
            
        case kDestinationVolumeDoesNotExist:
            [self growlMessage:@"Failed to change backup destination" message:@"The specified mount point doesn't exist.  Is the external drive connected?"];
            break;
            
            
        case kDestinationVolumeUnreachable:
            [self growlMessage:@"Failed to change backup destination" message:@"Ensure remote server is available, check afp parameters or try again later."];
            break;
            
        case kDestinationVolumeInvalidFormat:
            [self growlMessage:@"Failed to change backup destination" message:@"Failed to set new backup destination, check afp parameters."];
            break;
            
        case kDestinationVolumeNotAvailable:
            [self growlMessage:@"Failed to change backup destination" message:@"AFP server isn't available, try again later"];
            break;
            
        default:
            [self growlMessage:@"Failed to change backup destination" message:[NSString stringWithFormat:@"Unknown error occurred, tmutil returned %d.",retval]];
            break;
    }

}

- (void)buildFoundDisksList {
    // if we're coming from a menu item, specifically
    // then we're not editing an entry, deselect
    // all rows because "editing" is later
    // determined by the fact that NSTableView has a 
    // selectedRow > 1
    
    [[self foundDisks] removeAllObjects];
    [foundSharesTableView reloadData];
    
    NSDictionary *aRecord = nil;
    
    // The networkBrowser is specifically looking for adisk shares
    // on the network.  A Time Capsule or AFP server will advertise 
    // that it has adisk shares and foundServers will return an array of
    // found Time Capsules/AFP servers (or anything claiming to be as much).
    // Here Tedium is going to look at each one to see if they 
    // also advertise an available Time Machine compatible share
    for (NSNetService *service in [networkBrowser foundServers]) {
        
        // get the TXT record for this service (Time Capsule)
        aRecord = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
        NSArray *allKeys = [aRecord allKeys];
        
        //NSLog(@"%@", aRecord);
        
        // The TXT record describes what shares are available, look
        // at each one and determine if it is a Time Machine compatible
        // share
        for (NSString *key in allKeys) {
            
            NSArray *share = [[[NSString alloc] initWithData:[aRecord valueForKey:key] encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
            
            NSDictionary *shareDictionary = [share dictionary];
            
            //NSLog(@"share properties %@",shareDictionary);
            
            // shareDictionary is now a single disk share hosted on a Time Capsule or AFP server.
            // Tedium now checks the properties for this share and determines if it is
            // a Time Machine compatible share or not
            if ([shareDictionary isTimeMachineShare]) {
                
                [[self foundDisks] addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [service hostName], @"hostname",
                                              [NSString stringWithFormat:@"/%@",[shareDictionary valueForKey:@"adVN"]], @"url", nil]];
               
            }
        }
        
    }
    //NSLog(@"found disks is now %@", [self foundDisks]);
}






#pragma mark -
#pragma mark GUI Routines
- (IBAction)openPreferences:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [prefsWindow makeKeyAndOrderFront:self];
    [destinationsTableView reloadData];
}

- (IBAction)showAbout:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [aboutWindow makeKeyAndOrderFront:sender];
    [creditsFile readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"]];

}





- (IBAction)addBonjourBasedNetworkShare:(id)sender {
    [self buildFoundDisksList];
    
    //NSLog(@"%@", [self foundDisks]);
    
    if ([sender class] == [NSMenuItem class]) {
        [destinationsTableView deselectAll:self];
    }
    [foundSharesTableView reloadData];
    [self setActiveSheet:bonjourBasedShareSheet];
    [NSApp beginSheet:bonjourBasedShareSheet
	   modalForWindow:prefsWindow
	    modalDelegate:self
	   didEndSelector:@selector(bonjourBasedShareSheetDidEnd:returnCode:contextInfo:)
	      contextInfo:nil];
}

- (IBAction)addNetworkShare:(id)sender {
    // if we're coming from a menu item, specifically
    // then we're not editing an entry, deselect
    // all rows because "editing" is later
    // determined by the fact that NSTableView has a 
    // selectedRow > 1
    
    
    if ([sender class] == [NSMenuItem class]) {
        [destinationsTableView deselectAll:self];
    }
    
    [self setActiveSheet:addNetworkShareSheet];
    [NSApp beginSheet:addNetworkShareSheet
	   modalForWindow:prefsWindow
	    modalDelegate:self
	   didEndSelector:@selector(addNetworkDriveSheetDidEnd:returnCode:contextInfo:)
	      contextInfo:nil];
}

- (IBAction)addCurrentDrive:(id)sender {

    NSDictionary *tmp = [NSDictionary dictionaryWithContentsOfFile:@"/Library/Preferences/com.apple.TimeMachine.plist"];

    NSDictionary *newDestination = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"/Volumes/%@",[tmp valueForKey:@"LocalizedDiskImageVolumeName"]],@"cleanURL",
                                    [NSNumber numberWithBool:NO],@"isAFP", nil];
    [self addNewDestination:newDestination];
}

- (IBAction)closeSheetWithOK:(id)sender {
	[NSApp endSheet:[self activeSheet] returnCode:NSOKButton];
}

- (IBAction)closeSheetWithCancel:(id)sender {
	[NSApp endSheet:[self activeSheet] returnCode:NSCancelButton];
}


- (IBAction)closePreferences:(id)sender {
    [prefsWindow close];
}

- (IBAction)applyNewDestination:(id)sender {
    
    if ([destinationsTableView selectedRow] == -1) 
        return;
    
    NSDictionary *newDestination = [[self destinations] objectAtIndex:[destinationsTableView selectedRow]];

    [self setCurrentDestination:[newDestination valueForKey:@"destinationVolumePath"]];
    [prefsWindow close];
}

- (void) applyDestinationViaMenu:(id) sender {
    [self setCurrentDestination:[sender title]];
}

- (void)addNetworkDriveSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    
    [sheet orderOut:nil];
    
	if (returnCode != NSOKButton)
		return;
    

    [self setShareToBeAdded:[[self parseDestination:[self destinationValueFromSheet]] mutableCopy]];
    [self setDestinationValueFromSheet:@""];
    
    
    
    [self setActiveSheet:usernamePasswordSheet];
    [NSApp beginSheet:usernamePasswordSheet
	   modalForWindow:prefsWindow
	    modalDelegate:self
	   didEndSelector:@selector(usernamePasswordSheetDidEnd:returnCode:contextInfo:)
	      contextInfo:nil];
}

- (void)bonjourBasedShareSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    
    [sheet orderOut:nil];
    
	if (returnCode != NSOKButton)
		return;
    
    if ([foundSharesTableView selectedRow] == -1) 
        return;
    
    [self setShareToBeAdded:[[[self foundDisks] objectAtIndex:[foundSharesTableView selectedRow]] mutableCopy]];
    [self setActiveSheet:usernamePasswordSheet];
    [NSApp beginSheet:usernamePasswordSheet
	   modalForWindow:prefsWindow
	    modalDelegate:self
	   didEndSelector:@selector(usernamePasswordSheetDidEnd:returnCode:contextInfo:)
	      contextInfo:nil];


}

- (void)usernamePasswordSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    
   
    if (returnCode != NSOKButton) {
        [sheet orderOut:nil];
        return;
    }


    
    if ([[self passwordFromSheet] isEqualToString:@""]) {
        // handle this, a password is required for tmutil
        NSAlert *alert = [[NSAlert alloc] init];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:NSLocalizedString(@"Password Required", @"")];
		[alert setInformativeText:NSLocalizedString(@"Destinations without a password are not supported", @"")];
		[alert addButtonWithTitle:NSLocalizedString(@"Retry", @"")];
		[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
        
		[alert beginSheetModalForWindow:usernamePasswordSheet
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
    }
    else {
        [sheet orderOut:nil];
        [[self shareToBeAdded] setValue:[self usernameFromSheet] forKey:@"username"];
        [[self shareToBeAdded] setValue:[self passwordFromSheet] forKey:@"password"];
        [[self shareToBeAdded] setValue:[self cleanURL:[NSString stringWithFormat:@"afp://%@@%@%@", [self usernameFromSheet], [[self shareToBeAdded] valueForKey:@"hostname"], [[self shareToBeAdded] valueForKey:@"url"]]] forKey:@"cleanURL"];
        [[self shareToBeAdded] setValue:[NSNumber numberWithBool:YES] forKey:@"isAFP"];
        [self addNewDestination:[self shareToBeAdded]];
        [self setSelectedBonjourShare:nil];
    }
    
    [self setUsernameFromSheet:@""];
    [self setPasswordFromSheet:@""];
    [[self usernameFieldControl] becomeFirstResponder];
    [foundSharesTableView deselectAll:self];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    

    if (returnCode == NSAlertFirstButtonReturn) {
        [NSApp beginSheet:usernamePasswordSheet
           modalForWindow:prefsWindow
            modalDelegate:self
           didEndSelector:@selector(usernamePasswordSheetDidEnd:returnCode:contextInfo:)
              contextInfo:nil];
    }
    else {
        [usernamePasswordSheet orderOut:nil];
    }
}

- (IBAction)removeDestination:(id)sender {
    [destinationsTableView abortEditing];
   
    if ([destinationsTableView selectedRow] == -1)
        return;
   
    NSMutableDictionary *destinationURL = [[[self destinations] objectAtIndex:[destinationsTableView selectedRow]] mutableCopy];

    
    if ([[destinationURL valueForKey:@"isAFP"] boolValue]) {
        [destinationURL setValue:[self cleanURL:[NSString stringWithFormat:@"afp://%@@%@%@", [destinationURL valueForKey:@"username"], [destinationURL valueForKey:@"hostname"], [destinationURL valueForKey:@"url"]]] forKey:@"cleanURL"];
    }
    
    //NSLog(@"will remove %@ %@", [destinationURL objectForKey:@"cleanURL"],([destinationURL objectForKey:@"cleanURL"]) ? @"YES":@"NO");
    if ([[destinationURL valueForKey:@"isAFP"] boolValue] && [KeychainServices checkForExistanceOfKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[destinationURL valueForKey:@"username"] withAddress:[[destinationURL valueForKey:@"cleanURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
        [KeychainServices deleteKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[destinationURL valueForKey:@"username"] withAddress:[destinationURL valueForKey:@"cleanURL"]];
    }

   

    [[self destinations] removeObjectAtIndex:[destinationsTableView selectedRow]];
    [destinationsTableView reloadData];
    [self populateDestinationsSubMenu];
    [self saveSettings];

}

- (IBAction)editDestination:(id)sender {
    [destinationsTableView abortEditing];
    
    if ([destinationsTableView selectedRow] == -1)
        return;
    
    NSDictionary *tmp = [[self destinations] objectAtIndex:[destinationsTableView selectedRow]];
    
    [self setDestinationValueFromSheet:[tmp valueForKey:@"destinationVolumePath"]];
    [self addNetworkShare:self];
}

- (IBAction)openTediumGitHubIssues:(id)sender {
    NSURL *url = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"TediumGithubIssuesURL"]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openDonationPage:(id)sender {
    NSURL *url = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"TediumDonationsURL"]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) populateDestinationsSubMenu {
    [destinationsSubMenu removeAllItems];
    for (NSDictionary *tmp in [self destinations]) {
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:[tmp valueForKey:@"destinationVolumePath"] action:@selector(applyDestinationViaMenu:) keyEquivalent:@""];
        [destinationsSubMenu addItem:newMenuItem];
        
    }
}

- (IBAction)toggleMobileBackups:(id)sender {
    if ([localSnapshotsStatusForMenu state]) {
        NSString *command = @kTediumHelperToolSetMobileBackupCommand;
        
        [self helperToolPerformAction: command withParameter:[NSNumber numberWithInt:1]];
        [localSnapshotsStatusForMenu setState:1];
    }
    else {
        NSString *command = @kTediumHelperToolSetMobileBackupCommand;
        
        [self helperToolPerformAction: command withParameter:[NSNumber numberWithInt:0]];
        [localSnapshotsStatusForMenu setState:0];
    }
    [self toggleMobileBackupMenuItem];
}

#pragma mark -
#pragma mark Backup Routines
- (IBAction)doMobileBackupNow:(id)sender {

    NSString *command = @kTediumHelperToolMobileBackupNowCommand;
        
    [self helperToolPerformAction: command withParameter:nil];

    [self growlMessage:@"Mobile Backup Started" message:@"Mobile backup started"];
}

- (IBAction)doBackupNow:(id)sender {
    
    NSString *command = @kTediumHelperToolBackupNowCommand;
    
    [self helperToolPerformAction: command withParameter:nil];
    [self growlMessage:@"Backup Started" message:@"Time Machine backup started"];
}

- (void) toggleMobileBackupMenuItem {

    [[self mobileBackupNowMenuItem] setEnabled:[self isLocalSnapshotsEnabled]];
    [menuBarMenu update];
        
}
- (void) toggleBackupMenuItem {
    [menuBarMenu update];    
}

- (BOOL) isLocalSnapshotsEnabled {
    NSDictionary *tmp = [NSDictionary dictionaryWithContentsOfFile:@"/Library/Preferences/com.apple.TimeMachine.plist"];
    
    return [[tmp valueForKey:@"MobileBackups"] boolValue];
}


#pragma mark -
#pragma mark NSTableViewDataSource routines

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    if (tableView == destinationsTableView) {
        if (!destinations) {
            return 0;
        }
        return [[self destinations] count];
    }
    else {
        if (!foundDisks) {
            return 0;
        }
        return [[self foundDisks] count];
    }
    
    return 0;
}



- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (tableView == destinationsTableView) {

        NSDictionary *d = [[self destinations] objectAtIndex:row];

        return [d valueForKey:[tableColumn identifier]];
    }
    else if (tableView == foundSharesTableView) {
        NSDictionary *tmp = [[self foundDisks] objectAtIndex:row];
        return [NSString stringWithFormat:@"afp://%@%@", [tmp valueForKey:@"hostname"], [tmp valueForKey:@"url"]];
    }
    
    return @"I AM ERROR";
}


#pragma mark -
#pragma mark Login Item Routines

- (NSURL *) appPath {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void) startAtLogin {
    LSSharedFileListRef loginItemList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    LSSharedFileListInsertItemURL(loginItemList, kLSSharedFileListItemBeforeFirst,
                                  NULL, NULL, (__bridge_retained CFURLRef)[self appPath], NULL, NULL);
    CFRelease(loginItemList);
}

- (void) disableStartAtLogin {
    NSURL *appPath = [self appPath];
    
    // Creates shared file list reference to be used for changing list and reading its various properties.
    LSSharedFileListRef loginItemList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    // represents a found start up item
    
    // check to see if Tedium is already listed in Start Up Items
    if (loginItemList) {
        UInt32 seedValue = 0;
        
        // take a snapshot of the list creating an array out of it
        NSArray *currentLoginItems = (__bridge_transfer id)LSSharedFileListCopySnapshot(loginItemList, &seedValue);
        
        // walk the array looking for an entry that belongs to us
        for (id currentLoginItem in currentLoginItems) {
            LSSharedFileListItemRef itemToCheck = (__bridge_retained LSSharedFileListItemRef)currentLoginItem;
            
            UInt32 resolveFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef pathOfCurrentItem = NULL;
            OSStatus err = LSSharedFileListItemResolve(itemToCheck, resolveFlags, &pathOfCurrentItem, NULL);
            
            if (err == noErr) {
                BOOL startupItemFound = CFEqual(pathOfCurrentItem,(__bridge_retained CFTypeRef) appPath);
                CFRelease(pathOfCurrentItem);
                
                if (startupItemFound) {
                    LSSharedFileListItemRemove(loginItemList, itemToCheck);
                }
            }
        }
		
		CFRelease(loginItemList);
    }
}



- (BOOL) willStartAtLogin:(NSURL *)appPath {
    
    // Creates shared file list reference to be used for changing list and reading its various properties.
    LSSharedFileListRef loginItemList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    
    // check to see if Tedium is already listed in Start Up Items
    if (loginItemList) {
        UInt32 seedValue = 0;
        
        // take a snapshot of the list creating an array out of it
        NSArray *currentLoginItems = (__bridge_transfer id)LSSharedFileListCopySnapshot(loginItemList, &seedValue);
        
        // walk the array looking for an entry that belongs to us
        for (id currentLoginItem in currentLoginItems) {
            LSSharedFileListItemRef itemToCheck = (__bridge_retained LSSharedFileListItemRef)currentLoginItem;
            
            UInt32 resolveFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef pathOfCurrentItem = NULL;
            OSStatus err = LSSharedFileListItemResolve(itemToCheck, resolveFlags, &pathOfCurrentItem, NULL);
            
            if (err == noErr) {
                BOOL startupItemFound = CFEqual(pathOfCurrentItem,(__bridge_retained CFTypeRef)appPath);
                CFRelease(pathOfCurrentItem);
                
                if (startupItemFound) {
                    CFRelease(loginItemList);
                    return TRUE;
                }
            }
        }
        
        CFRelease(loginItemList);
    }
	
    return FALSE;
}

- (IBAction) toggleStartAtLoginAction:(id)sender {
    
    
    if ([self willStartAtLogin:[self appPath]]) {
        [self disableStartAtLogin];
    }
    else {
        [self startAtLogin];
        
    }
    [startAtLoginStatusForMenu setState:[self willStartAtLogin:[self appPath]] ? 1:0];
}





#pragma mark -
#pragma mark Scripting Support


- (NSMutableArray *)getDestinationsForScripting {
    return [self destinations];
}

#pragma mark -
#pragma mark QuincyKit
- (void) showMainApplicationWindow {
	[prefsWindow makeFirstResponder: nil];
    
}
 


- (IBAction)toggleCheckForUpdates:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SUEnableAutomaticChecks"]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"SUCheckAtStartup"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"SUEnableAutomaticChecks"];
        
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SUCheckAtStartup"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SUEnableAutomaticChecks"];    
    }
    
    [[self checkForUpdatesStatusForMenu] setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"SUEnableAutomaticChecks"]];
    [self.creditsFile readRTFDFromFile:@"Credits.rtf"];
    [self saveSettings];
}






#pragma mark -
#pragma mark NSApplication Delegates
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	// Set up status bar.
    [self showInStatusBar:self];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HideStatusBarIcon"]) {
		
		sbHideTimer = [NSTimer scheduledTimerWithTimeInterval: (NSTimeInterval)STATUS_BAR_LINGER
														target: self
													  selector: @selector(hideFromStatusBar:)
													  userInfo: nil
													   repeats: NO];
	}
    
	return YES;
}

#pragma mark -
#pragma mark DRNetworkBrowserDelegate routines
- (void) foundDisksDidChange {
    [self buildFoundDisksList];
    [foundSharesTableView reloadData];
}


#pragma mark -
#pragma mark NSMenu delegates
- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem == [self mobileBackupNowMenuItem])
        return [self isLocalSnapshotsEnabled];
    else 
        return YES;
}

- (void)menuWillOpen:(NSMenu *)menu {
    [self toggleMobileBackupMenuItem];
    [menuBarMenu update];
}

#pragma mark -
#pragma mark Misc
- (NSString *)versionString {
	return [NSString stringWithFormat:@"Tedium %@",[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
}

- (NSString *)cleanURL:(NSString *)urlToClean {
    return [urlToClean stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
