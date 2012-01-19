//
//  AppDelegate.m
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize currentDestination;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    menuBarImage = [self prepareImageForMenubar:@"uglyclock"];
    [self showInStatusBar:nil];
    [self setMenuBarImage:menuBarImage];
    
   	[GrowlApplicationBridge setGrowlDelegate: self];
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

@end
