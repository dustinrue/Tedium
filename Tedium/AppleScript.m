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

- (NSArray *) getAllDestinations
{
    NSLog(@"I see you!");
    //return [NSArray arrayWithObjects:@"name","age", nil];
    NSArray *tmp = [[NSApp delegate] allConfiguredDestinations];
    NSLog(@"%@",tmp);
    return tmp;
}

@end
