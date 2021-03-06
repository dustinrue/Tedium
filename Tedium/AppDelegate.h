//
//  AppDelegate.h
//  Tedium
//
//  Created by Dustin Rue on 1/16/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "BWQuincyManager.h"
#import "NetworkBrowser.h"

@class Destination;

#define STATUS_BAR_LINGER	10

@interface AppDelegate : NSObject <NSApplicationDelegate,GrowlApplicationBridgeDelegate,NSTableViewDataSource,BWQuincyManagerDelegate, DRNetworkBrowserDelegate,NSMenuDelegate, NSOpenSavePanelDelegate> {
    NSImage *menuBarImage;
    NSStatusItem *menuBarStatusItem;
    NSProcessInfo *processInfo;
    NSNotification *windowCloseNotification;
    NSDistributedNotificationCenter *notifications;
	NSTimer *sbHideTimer;

    

    IBOutlet NSWindow *prefsWindow;
    IBOutlet NSWindow *addNetworkShareSheet;
    IBOutlet NSWindow *bonjourBasedShareSheet;
    IBOutlet NSWindow *usernamePasswordSheet;
    IBOutlet NSWindow *aboutWindow;
    IBOutlet NSTableView *destinationsTableView;
    IBOutlet NSTableView *foundSharesTableView;
    IBOutlet NSButton *startAtLoginStatusForMenu;
    IBOutlet NSButton *hideMenuBarIconStatusForMenu;
    IBOutlet NSButton *localSnapshotsStatusForMenu;

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
@property (strong) IBOutlet NSMenu *menuBarMenu;
@property (readwrite, retain,nonatomic) NSString *currentDestination;
@property (readwrite, retain) NSURL *currentDestinationAsNSURL;
@property (readwrite, assign) NSWindow *activeSheet;
@property (assign) NSString *destinationValueFromSheet;
@property (retain) NSMutableArray *destinations;
@property (retain) Destination *destination;
@property (assign) BOOL hideMenuBarIconStatus;
@property (assign) BOOL localSnapshotsStatus;
@property (readwrite, retain) NetworkBrowser *networkBrowser;
@property (readwrite, retain) NSMutableArray *foundDisks;
@property (readwrite, retain) NSDictionary *selectedBonjourShare;
@property (readwrite, retain) NSString *usernameFromSheet;
@property (readwrite, retain) NSString *passwordFromSheet;
@property (readonly, retain)  NSString *versionString;
@property (readwrite, retain) NSMutableDictionary *shareToBeAdded;

@property (unsafe_unretained) IBOutlet NSButton *checkForUpdatesStatusForMenu;
@property (unsafe_unretained) IBOutlet NSTextView *creditsFile;
@property (unsafe_unretained) IBOutlet NSMenu *destinationsSubMenu;
@property (weak) IBOutlet NSMenuItem *mobileBackupNowMenuItem;
@property (weak) IBOutlet NSMenuItem *backupNowMenuItem;
@property (weak) IBOutlet NSTextField *usernameFieldControl;


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
- (BOOL) isLocalSnapshotsEnabled;
- (void) toggleMobileBackupMenuItem;
- (void) toggleBackupMenuItem;
- (void) saveSettings;
- (void) addNewDestination:(NSDictionary *)newDestination;
- (NSString *)cleanURL:(NSString *)urlToClean;


- (IBAction)openPreferences:(id)sender;
- (IBAction)addBonjourBasedNetworkShare:(id)sender;
- (IBAction)addNetworkShare:(id)sender;
- (IBAction)addAttachedExternalDrive:(id)sender;
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
- (IBAction)toggleMobileBackups:(id)sender;
- (IBAction)doMobileBackupNow:(id)sender;
- (IBAction)doBackupNow:(id)sender;

// Login item stuff
- (NSURL *)appPath;
- (BOOL)willStartAtLogin:(NSURL *)appPath;
- (void)startAtLogin;
- (void)disableStartAtLogin;



@end
