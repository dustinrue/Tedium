//
//  AppDelegate.h
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "BWQuincyManager.h"
#import "NetworkBrowser.h"

@class Destination;

#define STATUS_BAR_LINGER	10

@interface AppDelegate : NSObject <NSApplicationDelegate,GrowlApplicationBridgeDelegate,NSTableViewDataSource,BWQuincyManagerDelegate> {
    NSImage *menuBarImage;
    NSStatusItem *menuBarStatusItem;
    NSProcessInfo *processInfo;
    NSNotification *windowCloseNotification;
    NSDistributedNotificationCenter *notifications;
	NSTimer *sbHideTimer;

    
    IBOutlet NSMenu *menuBarMenu;
    IBOutlet NSWindow *prefsWindow;
    IBOutlet NSWindow *addNetworkShareSheet;
    IBOutlet NSWindow *aboutWindow;
    IBOutlet NSTableView *destinationsTableView;
    IBOutlet NSButton *startAtLoginStatusForMenu;
    IBOutlet NSButton *hideMenuBarIconStatusForMenu;
    __unsafe_unretained NSMenu *destinationsSubMenu;
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
@property (retain) NSMutableArray *destinations;
@property (retain) Destination *destination;
@property (assign) BOOL hideMenuBarIconStatus;
@property (readwrite,retain) NetworkBrowser *networkBrowser;
@property (readwrite,retain) NSMutableArray *foundDisks;

@property (unsafe_unretained) IBOutlet NSButton *checkForUpdatesStatusForMenu;
@property (unsafe_unretained) IBOutlet NSTextView *creditsFile;
@property (unsafe_unretained) IBOutlet NSMenu *destinationsSubMenu;


- (NSImage *) prepareImageForMenubar:(NSString *)name;
- (void) showInStatusBar:(id)sender;
- (void) setMenuBarImage:(NSImage *)imageName;
- (void) growlMessage:(NSString *)title message:(NSString *)message;
- (NSDictionary *)parseDestination:(NSString *)destination;
- (NSMutableArray *)getDestinationsForScripting;
- (void) enableHideMenuBarIcon;
- (void) disableHideMenuBarIcon;
- (BOOL) willHideMenuBarIcon;
- (void) populateDestinationsSubMenu;
- (void) applyDestinationViaMenu:(id) sender;


- (IBAction)openPreferences:(id)sender;
- (IBAction)addNetworkShare:(id)sender;
- (IBAction)addCurrentDrive:(id)sender;
- (IBAction)closeSheetWithOK:(id)sender;
- (IBAction)closeSheetWithCancel:(id)sender;
- (IBAction)closePreferences:(id)sender;
- (IBAction)applyNewDestination:(id)sender;
- (IBAction)removeDestination:(id)sender;
- (IBAction)editDestination:(id)sender;
- (IBAction)toggleStartAtLoginAction:(id)sender;
- (IBAction)openTediumGitHubIssues:(id)sender;
- (IBAction)openDonationPage:(id)sender;
- (IBAction)toggleHideMenuBarIcon:(id)sender;
- (IBAction)toggleCheckForUpdates:(id)sender;
- (IBAction)showAbout:(id)sender;

// Login item stuff
- (NSURL *)appPath;
- (BOOL)willStartAtLogin:(NSURL *)appPath;
- (void)startAtLogin;
- (void)disableStartAtLogin;



@end
