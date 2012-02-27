//
//  NSDictionary+Bonjour.m
//  Tedium
//
//  Created by Dustin Rue on 2/26/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "NSDictionary+Bonjour.h"

@implementation NSDictionary (Bonjour)

- (BOOL) isTimeMachineShare {
    return ([self objectForKey:@"adVF"] && [self objectForKey:@"adVN"]);
}
@end
