//
//  NSString+ADisk.h
//  Tedium
//
//  Created by Dustin Rue on 2/26/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ADisk)

- (NSString *) shareType;
- (NSString *) shareValue;
- (NSString *) withTrailingPeriodRemoved;

@end
