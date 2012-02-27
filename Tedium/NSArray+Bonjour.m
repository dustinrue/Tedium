//
//  NSArray+Bonjour.m
//  Tedium
//
//  Created by Dustin Rue on 2/26/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "NSArray+Bonjour.h"
#import "NSString+Bonjour.h"

@implementation NSArray (Bonjour)

- (NSDictionary *) dictionary {
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for (NSString *item in self) {
        [tmp setValue:[item shareValue] forKey:[item shareType]];
    }
    
    return tmp;
}

@end
