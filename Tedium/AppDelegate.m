//
//  AppDelegate.m
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    menuBarImage = [self prepareImageForMenubar:@"uglyclock"];
    [self showInStatusBar:nil];
    [self setMenuBarImage:menuBarImage];
}

// Helper: Load a named image, and scale it to be suitable for menu bar use.
- (NSImage *)prepareImageForMenubar:(NSString *)name
{
	NSImage *img = [NSImage imageNamed:name];
	[img setScalesWhenResized:YES];
	[img setSize:NSMakeSize(18, 18)];
    
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

@end
