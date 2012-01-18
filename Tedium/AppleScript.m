//
//  AppleScript.m
//  Tedium
//
//  Created by Dustin Rue on 1/17/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AppleScript.h"

@implementation NSApplication (AppleScript)

- (NSString *) currentDestination 
{
    return [[NSApp delegate] currentDestination];
}

- (void) setCurrentDestination:(NSString *)newDestination
{
    [[NSApp delegate] setCurrentDestination:newDestination];
}

@end
