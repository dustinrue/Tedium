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
    IBOutlet NSWindow *addNetworkShareSheet;
    IBOutlet NSTableView *destinationsTableView;
    IBOutlet NSButton *startAtLoginStatus;

}

enum {
    kDestinationVolumeSetSuccessfully = 0,
    kDestinationVolumeDoesNotExist    = 512,
    kDestinationVolumeUnreachable     = 1280,
    kDestinationVolumeNotAvailable    = 16384,
    kDestinationVolumeInvalidFormat   = 52736,
};


@property (assign) IBOutlet NSWindow *window;
@property (readwrite,retain,nonatomic) NSString *currentDestination;
@property (readwrite,retain) NSURL *currentDestinationAsNSURL;
@property (readwrite,assign) NSWindow *activeSheet;
@property (assign) NSString *destinationValueFromSheet;
@property (assign) NSArray *allConfiguredDestinations;


- (NSImage *)prepareImageForMenubar:(NSString *)name;
- (void)showInStatusBar:(id)sender;
- (void)setMenuBarImage:(NSImage *)imageName;
- (void) growlMessage:(NSString *)title message:(NSString *)message;
- (NSDictionary *)parseDestination:(NSString *)destination;


- (IBAction)openPreferences:(id)sender;
- (IBAction)addNetworkShare:(id)sender;
- (IBAction)addCurrentDrive:(id)sender;
- (IBAction)closeSheetWithOK:(id)sender;
- (IBAction)closeSheetWithCancel:(id)sender;
- (IBAction)closePreferences:(id)sender;
- (IBAction)applyNewDestination:(id)sender;
- (IBAction)removeDestination:(id)sender;

// Login item stuff
- (NSURL *)appPath;
- (BOOL)willStartAtLogin:(NSURL *)appPath;
- (void)startAtLogin;
- (void)disableStartAtLogin;
- (IBAction)toggleStartAtLoginAction:(id)sender;


@end
