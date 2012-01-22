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
    
    [[NSNotificationCenter defaultCenter] 
                                addObserver:self 
                                selector:@selector(saveSettings) 
                                name:NSWindowWillCloseNotification
                                object:nil];
 
    NSLog(@"loaded configuration %@",destinations);
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
    NSLog(@"growl");
    
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
}

- (void)addNewDestination:(NSString *)newDestination {

    // test to see if the destination is already inserted
    // there has to be a more efficient way of handling this...
    for (NSDictionary * aDictionary in destinations)
    {
        
        NSString *aDestination = [aDictionary valueForKey:@"destinationVolumePath"];
        NSLog(@"got %@ from %@",aDestination, aDictionary);
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
    
    [self addNewDestination:newVal];
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
	   didEndSelector:@selector(addExternalDriveSheetDidEnd:returnCode:contextInfo:)
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
    
    NSLog(@"setting to item at selectedRow %ld", [destinationsTableView selectedRow]);
    if ([destinationsTableView selectedRow] == -1) 
        return;
    
    NSDictionary *newDestination = [destinations objectAtIndex:[destinationsTableView selectedRow]];
    
    NSLog(@"new destination will be set to %@", [newDestination valueForKey:@"destinationVolumePath"]);

    
    NSString *command = @kTediumHelperToolSetDestinationCommand;
    if([self helperToolPerformAction: command withParameter:[newDestination valueForKey:@"destinationVolumePath"]])
        [self growlMessage:@"Failure" message:@"Failed to set new destination"];
}

- (void)addExternalDriveSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode != NSOKButton)
		return;
    
	NSLog(@"got new data!");
}

- (IBAction)removeDestination:(id)sender {
    [destinationsTableView abortEditing];
    NSLog(@"table view claims it has %ld rows",[destinationsTableView numberOfRows]);
    NSLog(@"about to remove item at index %ld", [destinationsTableView selectedRow]);    
    if ([destinationsTableView selectedRow] == -1)
        return;
    

    [destinations removeObjectAtIndex:[destinationsTableView selectedRow]];
    [destinationsTableView reloadData];

}

#pragma mark NSTableViewDataSource routines

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView 
{
    NSLog(@"numberOfRowsInTableView");
    if(!destinations)
        return 0;
    
    NSLog(@"destinations contains: %lu",[destinations count]);
    return [destinations count];
}



- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row 
{
    NSDictionary *d = [destinations objectAtIndex:row];
    NSLog(@"object value %@",[d valueForKey:[tableColumn identifier]]);
    return [d valueForKey:[tableColumn identifier]];
}

-(void)selectionChanged:(NSNotification *)notification 
{
    NSLog(@"selection changed");
}


@end
