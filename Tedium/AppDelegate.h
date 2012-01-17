//
//  AppDelegate.h
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSImage *menuBarImage;
    NSStatusItem *menuBarStatusItem;
    IBOutlet NSMenu *menuBarMenu;
}

@property (assign) IBOutlet NSWindow *window;

- (NSImage *)prepareImageForMenubar:(NSString *)name;
- (void)showInStatusBar:(id)sender;
- (void)setMenuBarImage:(NSImage *)imageName;

@end
