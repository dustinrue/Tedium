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
    NSProcessInfo *processInfo;
    NSNotification *windowCloseNotification;

    
    IBOutlet NSMenu *menuBarMenu;
    IBOutlet NSWindow *prefsWindow;
    IBOutlet NSWindow *addExternalDriveSheet;
    IBOutlet NSWindow *addNetworkShareSheet;
    IBOutlet NSWindow *addCurrentDriveSheet;

}

@property (unsafe_unretained) IBOutlet NSArrayController *destinationsController;
@property (assign) IBOutlet NSWindow *window;
@property (readwrite,retain,nonatomic) NSString *currentDestination;
@property (readwrite,assign) NSArray *destinations;
@property (readwrite,assign) NSWindow *activeSheet;

- (NSImage *)prepareImageForMenubar:(NSString *)name;
- (void)showInStatusBar:(id)sender;
- (void)setMenuBarImage:(NSImage *)imageName;
- (void) growlMessage:(NSString *)title message:(NSString *)message;
- (IBAction)openPreferences:(id)sender;
- (IBAction)addExternalDrive:(id)sender;
- (IBAction)addNetworkShare:(id)sender;
- (IBAction)addCurrentDrive:(id)sender;
- (IBAction)closeSheetWithOK:(id)sender;
- (IBAction)closeSheetWithCancel:(id)sender;
- (IBAction)closePreferences:(id)sender;
- (IBAction)applyNewDestination:(id)sender;

@end
