//
//  Destination.m
//  Tedium
//
//  Created by Dustin Rue on 1/27/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "Destination.h"
#include <sys/types.h>
#include <unistd.h>

@implementation Destination 

@synthesize destinationVolumeName;
@synthesize container;
@synthesize containerProperty;
@synthesize uniqueID;
@synthesize name;

- (NSScriptObjectSpecifier *)objectSpecifier {
	return [[NSUniqueIDSpecifier alloc]
            initWithContainerClassDescription:(NSScriptClassDescription*) [self.container classDescription]
			containerSpecifier:[self.container objectSpecifier]
			key:self.containerProperty uniqueID:self.uniqueID];
    
}

-(id) init {
	if ((self = [super init])) {
		static unsigned long gNameCounter = 1;
		self.uniqueID = [Destination makeId];
        /* we use a global counter to generate unique names */
		self.name = [NSString stringWithFormat:@"Untitled %d", gNameCounter++];
	}

	return self;
}


+ (NSString *)makeId {
	static unsigned long uniqueDestinationCounter;
	static pid_t myPID; /* unique id of our process */
	static BOOL uniqueIdHasBeenInitialized = NO; /* our element id generator */
	NSString *uniqueId;
	
	if (!uniqueIdHasBeenInitialized ) {
		myPID = getpid();
		uniqueDestinationCounter = 1;
		uniqueIdHasBeenInitialized = YES;
	}

	uniqueId = [NSString stringWithFormat:@"SSO-%d-%d", myPID, uniqueDestinationCounter++];

	return uniqueId;
}




@end
