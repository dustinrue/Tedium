//
//  AppleScriptSupport.m
//  Tedium
//
//  Created by Dustin Rue on 1/27/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "AppleScriptSupport.h"
#import "Destination.h"
#import "AppDelegate.h"

@implementation NSApplication (AppleScriptSupport)

- (NSNumber *)ready {
    NSLog(@"derp");
    return [NSNumber numberWithBool:YES];
}

- (void) setCurrentDestination:(NSString *)newDestination
{
    [[NSApp delegate] setCurrentDestination:newDestination];
}

- (NSArray *) destinations {

    NSMutableArray *destinationsToReturn = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in [[NSApp delegate] getDestinationsForScripting]) {
        Destination *tmp = [[Destination alloc] init];
        [tmp setDestinationVolumeName:[dict valueForKey:@"destinationVolumePath"]];
        [destinationsToReturn addObject:tmp];
    }
    
	return destinationsToReturn;
    
}

@end
