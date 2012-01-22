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



@implementation AppDelegate

@synthesize window = _window;
@synthesize currentDestination;
@synthesize activeSheet;
@synthesize destinationValueFromSheet;
@synthesize allConfiguredDestinations;

enum {
    kDestinationVolumeSetSuccessfully = 0,
    kDestinationVolumeDoesNotExist    = 512,
    kDestinationVolumeUnreachable     = 1280,
};

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

    
    [destinations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            newDestination, @"destinationVolumePath",
                            @"", @"destinationVolumePathUsername",
                            @"", @"destinationVolumePathPassword",
                            [NSNumber numberWithInt:0], @"isAFP",nil]];
    [self saveSettings];
    [destinationsTableView reloadData];
}

- (void) setCurrentDestination:(NSString *)newVal {
    
    NSLog(@"setCurrentDestination %@", newVal);
    currentDestination = newVal;
    [self growlMessage:@"Updating Destination" message:[NSString stringWithFormat:@"Changing Time Machine destination to %@", newVal]];
    

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

- (IBAction)addExternalDrive:(id)sender 
{
    [self setActiveSheet:addExternalDriveSheet];
    [NSApp beginSheet:addExternalDriveSheet
	   modalForWindow:prefsWindow
	    modalDelegate:self
	   didEndSelector:@selector(addExternalDriveSheetDidEnd:returnCode:contextInfo:)
	      contextInfo:nil];
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

    
    NSString *command = @kTediumHelperToolSetDestinationCommand;
    
    NSInteger retval = [self helperToolPerformAction: command withParameter:[newDestination valueForKey:@"destinationVolumePath"]];
    
    switch (retval) {
        case kDestinationVolumeSetSuccessfully:
            [self growlMessage:@"Tedium succesfully changed the destination" message:@"Backup destination was changed successfully"];
            break;
            
            
        case kDestinationVolumeDoesNotExist:
            [self growlMessage:@"Tedium failed to change the destination" message:@"The specified mount point doesn't exist.  Is the external drive connected?"];
            break;
            
            
        case kDestinationVolumeUnreachable:
            [self growlMessage:@"Tedium failed to change the destination" message:@"Failed to set new destination, ensure remote server is available, check afp parameters or try again later"];
            break;
 
            
        default:
            [self growlMessage:@"Tedium failed to change the destination" message:[NSString stringWithFormat:@"Unknown error occurred, tmutil returned %d",retval]];
            break;
    }
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




@end
