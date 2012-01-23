//
//  AppleScript.m
//  Tedium
//
//  Created by Dustin Rue on 1/17/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AppleScript.h"
#import "AppDelegate.h"

@implementation NSApplication (AppleScript)

- (NSString *) currentDestination 
{
    return [[NSApp delegate] currentDestination];
}

- (void) setCurrentDestination:(NSString *)newDestination
{
    [[NSApp delegate] setCurrentDestination:newDestination];
}

- (NSString *) getAllDestinations
{

    NSArray *tmp = [[NSApp delegate] allConfiguredDestinations];

    NSString *error;
    return [[NSString alloc] initWithData:[NSPropertyListSerialization dataFromPropertyList:tmp format:NSPropertyListXMLFormat_v1_0 errorDescription:&error] encoding:NSUTF8StringEncoding];
}

@end
