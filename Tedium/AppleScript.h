//
//  AppleScript.h
//  Tedium
//
//  Created by Dustin Rue on 1/17/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSApplication (AppleScript)

- (NSString *) currentDestination;
- (void) setCurrentDestination:(NSString *)newDestination;
- (NSString *) getAllDestinations;

@end



