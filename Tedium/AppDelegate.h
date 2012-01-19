//
//  AppDelegate.h
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,GrowlApplicationBridgeDelegate> {
    NSImage *menuBarImage;
    NSStatusItem *menuBarStatusItem;
    IBOutlet NSMenu *menuBarMenu;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (readwrite,retain) NSString *currentDestination;

- (NSImage *)prepareImageForMenubar:(NSString *)name;
- (void)showInStatusBar:(id)sender;
- (void)setMenuBarImage:(NSImage *)imageName;
- (void) growlMessage:(NSString *)title message:(NSString *)message;

@end
