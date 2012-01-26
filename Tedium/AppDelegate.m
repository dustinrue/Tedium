//
//  AppDelegate.m
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+HelperTool.h"
#import "TediumHelpertoolCommon.h"
#import "KeychainServices.h"



@implementation AppDelegate

@synthesize window = _window;
@synthesize currentDestination;
@synthesize activeSheet;
@synthesize destinationValueFromSheet;
@synthesize allConfiguredDestinations;
@synthesize currentDestinationAsNSURL;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    menuBarImage = [self prepareImageForMenubar:@"awesomeclock"];
    [self showInStatusBar:nil];
    [self setMenuBarImage:menuBarImage];
    

    
   	[GrowlApplicationBridge setGrowlDelegate: self];
    processInfo = [NSProcessInfo processInfo];
    [processInfo enableSuddenTermination];
    

    
    destinations = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"destinations"]];
    
 
    NSLog(@"loaded configuration");
    [self setAllConfiguredDestinations:destinations];
    notifications = [NSDistributedNotificationCenter defaultCenter];
    [notifications addObserver:self selector:@selector(didReceiveNotification:) name:@"com.dustinrue.Tedium.allDestinationsRequest" object:nil];

}

// Helper: Load a named image, and scale it to be suitable for menu bar use.
- (NSImage *)prepareImageForMenubar:(NSString *)name
{
	NSImage *img = [NSImage imageNamed:name];
	[img setScalesWhenResized:YES];
	[img setSize:NSMakeSize(16, 16)];
    
	return img;
}

- (void)setMenuBarImage:(NSImage *)imageName 
{
    
    // if the menu bar item has been hidden menuBarStatusItem will have been released
    // and we should not attempt to update the image
    if (!menuBarStatusItem)
        return;
    

    [menuBarStatusItem setImage:imageName];

}

- (void)showInStatusBar:(id)sender
{
	if (menuBarStatusItem) {
		// Already there? Rebuild it anyway.
		[[NSStatusBar systemStatusBar] removeStatusItem:menuBarStatusItem];
	}
    
	menuBarStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[menuBarStatusItem setHighlightMode:YES];
    

	
	[menuBarStatusItem setMenu:menuBarMenu];
}

- (void) growlMessage:(NSString *)title message:(NSString *)message 
{
    const int pri = 0;
    
    [GrowlApplicationBridge notifyWithTitle:title
								description:message
						   notificationName:@"TediumGrowl"
								   iconData:nil
								   priority:pri
								   isSticky:NO
							   clickContext:nil];
}



- (void)saveSettings {
    NSLog(@"saving settings");
    [[NSUserDefaults standardUserDefaults] setObject:destinations forKey:@"destinations"];
   	[[NSUserDefaults standardUserDefaults] synchronize];
    [self setAllConfiguredDestinations:destinations];
}

- (void)addNewDestination:(NSString *)newDestination {

    // test to see if the destination is already inserted
    // there has to be a more efficient way of handling this...
    for (NSDictionary * aDictionary in destinations)
    {
        
        NSString *aDestination = [aDictionary valueForKey:@"destinationVolumePath"];

        if ([aDestination isEqualToString:newDestination])
            return;
    }

    
    NSDictionary *afpURL = [self parseDestination:newDestination];
    
  

    if ([afpURL objectForKey:@"cleanedURL"]) {
        [destinations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [afpURL valueForKey:@"cleanedURL"], @"destinationVolumePath", nil]];
        
        if (![KeychainServices addKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[afpURL valueForKey:@"username"] withPassword:[afpURL valueForKey:@"password"] withAddress:[[afpURL valueForKey:@"cleanedURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
            [self growlMessage:@"Keychain Failure" message:[NSString stringWithFormat:@"Failed to add the password for %@ to the keychain",[afpURL valueForKey:@"cleanURL"]]];
        }
    }
    else {
        [destinations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 newDestination, @"destinationVolumePath",
                                 [NSNumber numberWithInt:0], @"isAFP",nil]];
    }
    
    [self saveSettings];
    [destinationsTableView reloadData];
}

- (NSDictionary *)parseDestination:(NSString *)destination {

    NSString *urlText = [destination stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self setCurrentDestinationAsNSURL:[NSURL URLWithString:urlText]];
    
    // it isn't an AFP URL so we simply return
    if ([self currentDestinationAsNSURL] == nil) {
        NSLog(@"returning nil");
        return nil;
        
    }
        
    
    NSString *username = [[self currentDestinationAsNSURL] user];
    NSString *password = [[self currentDestinationAsNSURL] password];
    NSString *hostname = [[self currentDestinationAsNSURL] host];
    NSString *url      = [[self currentDestinationAsNSURL] path];
    
    // if the URL couldn't be parsed return an empty NSDictionary
    if (!username || !hostname || !url) {
        return [[NSDictionary alloc] init];
    }
    
    // cover a case where we're setting the destination and we
    // haven't gotten the password yet.  Leaving this "nil" will
    // end our dictionary prematurely 
    if (!password) {
        password = @"";
    }
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            username, @"username",
            password, @"password",
            hostname, @"hostname",
            url, @"url",
            [NSString stringWithFormat:@"afp://%@@%@%@",username,hostname,url],@"cleanedURL",nil];

    
}

- (void) setCurrentDestination:(NSString *)newVal {
    
    currentDestination = newVal;
    
    NSDictionary *tmp = [self parseDestination:newVal];

    
    NSString *newDestination;
    
    if ([tmp objectForKey:@"cleanedURL"]) {
        NSString *password = [KeychainServices getPasswordFromKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[tmp valueForKey:@"username"] withAddress:[[tmp valueForKey:@"cleanedURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        newDestination = [NSString stringWithFormat:@"afp://%@:%@@%@%@",[tmp valueForKey:@"username"],password,[tmp valueForKey:@"hostname"],[tmp valueForKey:@"url"]];
        
        [self growlMessage:@"Updating Destination" message:[NSString stringWithFormat:@"Changing Time Machine destination to %@", [tmp valueForKey:@"cleanedURL"]]];
    }
    else {
        newDestination = newVal;
        [self growlMessage:@"Updating Destination" message:[NSString stringWithFormat:@"Changing Time Machine destination to %@", newDestination]];
    }
    



    
    NSString *command = @kTediumHelperToolSetDestinationCommand;
    
    NSInteger retval = [self helperToolPerformAction: command withParameter:newDestination];
    
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

#pragma mark Growl Delegates

- (void) growlIsReady
{
    NSLog(@"growl reports it is ready");
}


- (void) growlNotificationWasClicked:(id)clickContext
{
    NSLog(@"growl reports the notification was clicked");
}

- (void) growlNotificationTimedOut:(id)clickContext
{
    NSLog(@"growl reports the notification timed out");
}

- (NSDictionary *) registrationDictionaryForGrowl 
{
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

#pragma mark GUI Routines
- (IBAction)openPreferences:(id)sender 
{
    [NSApp activateIgnoringOtherApps:YES];
    [prefsWindow makeKeyAndOrderFront:self];
    [destinationsTableView reloadData];
}


- (IBAction)addNetworkShare:(id)sender 
{
    [self setActiveSheet:addNetworkShareSheet];
    [NSApp beginSheet:addNetworkShareSheet
	   modalForWindow:prefsWindow
	    modalDelegate:self
	   didEndSelector:@selector(addNetworkDriveSheetDidEnd:returnCode:contextInfo:)
	      contextInfo:nil];
}

- (IBAction)addCurrentDrive:(id)sender 
{

    NSDictionary *tmp = [NSDictionary dictionaryWithContentsOfFile:@"/Library/Preferences/com.apple.TimeMachine.plist"];

    [self addNewDestination:[NSString stringWithFormat:@"/Volumes/%@",[tmp valueForKey:@"LocalizedDiskImageVolumeName"]]];
}

- (IBAction)closeSheetWithOK:(id)sender
{
	[NSApp endSheet:[self activeSheet] returnCode:NSOKButton];
	[[self activeSheet] orderOut:nil];
    [self setActiveSheet:nil];

}

- (IBAction)closeSheetWithCancel:(id)sender
{
	[NSApp endSheet:[self activeSheet] returnCode:NSCancelButton];
	[[self activeSheet] orderOut:nil];
    [self setActiveSheet:nil];
}


- (IBAction)closePreferences:(id)sender {
    [prefsWindow close];
}

- (IBAction)applyNewDestination:(id)sender {
    [prefsWindow close];
    
    if ([destinationsTableView selectedRow] == -1) 
        return;
    
    NSDictionary *newDestination = [destinations objectAtIndex:[destinationsTableView selectedRow]];

    [self setCurrentDestination:[newDestination valueForKey:@"destinationVolumePath"]];
    
}

- (void)addExternalDriveSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode != NSOKButton)
		return;
    
	NSLog(@"got new data!");
}

- (void)addNetworkDriveSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode != NSOKButton)
		return;
    
    [self addNewDestination:[self destinationValueFromSheet]];
    [self setDestinationValueFromSheet:@""];
}

- (IBAction)removeDestination:(id)sender {
    [destinationsTableView abortEditing];
   
    if ([destinationsTableView selectedRow] == -1)
        return;
   
    NSDictionary *tmp = [self parseDestination:[[destinations objectAtIndex:[destinationsTableView selectedRow]] valueForKey:@"destinationVolumePath"]];

    

    if ([tmp objectForKey:@"cleanedURL"]) {
        [KeychainServices deleteKeychainItem:@"Tedium" withItemKind:@"Time Machine Password" forUsername:[tmp valueForKey:@"username"] withAddress:[[tmp valueForKey:@"cleanedURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

   

    [destinations removeObjectAtIndex:[destinationsTableView selectedRow]];
    [destinationsTableView reloadData];

    [self saveSettings];

}

#pragma mark NSTableViewDataSource routines

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView 
{
    if(!destinations)
        return 0;
    
    return [destinations count];
}



- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row 
{

    NSDictionary *d = [destinations objectAtIndex:row];

    return [d valueForKey:[tableColumn identifier]];
}


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
    [startAtLoginStatus setState:[self willStartAtLogin:[self appPath]] ? 1:0];
}

#pragma mark Notifications routines

-(void) didReceiveNotification:(NSNotification *)notification
{

    NSLog(@"got notified of %@ from %@",[notification name], [notification object]);
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:[[self allConfiguredDestinations] count]];
    
    
    [tmp setValue:[self allConfiguredDestinations] forKey:@"destinations"];
    
    [notifications postNotificationName:@"com.dustinrue.Tedium.allDestinationsResponse" object:nil userInfo:tmp deliverImmediately:YES];
}

@end
