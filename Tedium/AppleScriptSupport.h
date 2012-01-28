//
//  AppleScriptSupport.h
//  Tedium
//
//  Created by Dustin Rue on 1/27/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSApplication (AppleScript)
- (NSNumber *)ready;
- (NSArray *) destinations;
- (void) setCurrentDestination:(NSString *)newDestination;
@end
