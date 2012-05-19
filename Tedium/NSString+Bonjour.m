//
//  NSString+ADisk.m
//  Tedium
//
//  Created by Dustin Rue on 2/26/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "NSString+Bonjour.h"

@implementation NSString (ADisk)


- (NSString *) shareType {
    NSArray *exploded = [self componentsSeparatedByString:@"="];
    
    if ([exploded count] != 2)
        return @"";
    
    return [exploded objectAtIndex:0];
}

- (NSString *) shareValue {
    NSArray *exploded = [self componentsSeparatedByString:@"="];
    
    if ([exploded count] != 2)
        return @"";
    
    return [exploded objectAtIndex:1];
}

- (NSString *) withTrailingPeriodRemoved {
    if ([[self substringFromIndex:[self length] - 1] isEqualToString:@"."]) {
        return [self substringToIndex:[self length] - 1];
    }
    return self;
}

@end
