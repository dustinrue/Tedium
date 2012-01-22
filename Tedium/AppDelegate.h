//
//  AppDelegate.h
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,GrowlApplicationBridgeDelegate,NSTableViewDataSource> {
    NSImage *menuBarImage;
    NSStatusItem *menuBarStatusItem;
    NSProcessInfo *processInfo;
    NSNotification *windowCloseNotification;
    NSMutableArray *destinations;

    
    IBOutlet NSMenu *menuBarMenu;
    IBOutlet NSWindow *prefsWindow;
    IBOutlet NSWindow *addExternalDriveSheet;
    IBOutlet NSWindow *addNetworkShareSheet;
    IBOutlet NSWindow *addCurrentDriveSheet;
    IBOutlet NSTableView *destinationsTableView;

}

enum {
    kDestinationVolumeSetSuccessfully = 0,
    kDestinationVolumeDoesNotExist    = 512,
    kDestinationVolumeUnreachable     = 1280,
};


@property (assign) IBOutlet NSWindow *window;
@property (readwrite,retain,nonatomic) NSString *currentDestination;
@property (readwrite,assign) NSWindow *activeSheet;
@property (assign) NSString *destinationValueFromSheet;
@property (assign) NSArray *allConfiguredDestinations;


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
- (IBAction)removeDestination:(id)sender;


@end
