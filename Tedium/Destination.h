//
//  Destination.h
//  Tedium
//
//  Created by Dustin Rue on 1/27/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//
// Heavily inspired by http://developer.apple.com/library/mac/#samplecode/SimpleScriptingObjects/Introduction/Intro.html
//

#import <Foundation/Foundation.h>

@interface Destination : NSObject {

    id container; 
    NSString *containerProperty;

}
@property (retain) NSString *destinationVolumeName;
@property (retain,readonly) id container;
@property (retain,readonly) NSString *containerProperty;
@property (copy) NSString *uniqueID;
@property (copy) NSString *name;


-(id)init;
+ (NSString *)makeId;
- (NSScriptObjectSpecifier *)objectSpecifier;

@end
