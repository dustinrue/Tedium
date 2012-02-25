//
//  NetworkBrowser.m
//  Tedium
//
//  Created by Dustin Rue on 2/9/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "NetworkBrowser.h"

@implementation NetworkBrowser

@synthesize netBrowser;
@synthesize foundServers;

- (NetworkBrowser *)init {
    if ((self = [super init])) {
        [self setNetBrowser:[[NSNetServiceBrowser alloc] init]];
        [[self netBrowser] setDelegate:self];
        
        [self setFoundServers:[[NSMutableArray alloc] init]];
    }
    
    return self;
}

- (void) start {
    [[self netBrowser] searchForServicesOfType:@"_adisk._tcp" inDomain:@"local."];
}

- (void) stop {
    [[self netBrowser] stop];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {

    [[self foundServers] addObject:netService];
    [netService resolveWithTimeout:0.5];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [[self foundServers] removeObject:aNetService];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    
}


- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    
}

@end
