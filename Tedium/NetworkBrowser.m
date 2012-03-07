//
//  NetworkBrowser.m
//  Tedium
//
//  Created by Dustin Rue on 2/9/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "NetworkBrowser.h"


@implementation NetworkBrowser

@synthesize netBrowser;
@synthesize foundServers;
@synthesize delegate;

- (NetworkBrowser *)init {
    if ((self = [super init])) {
        [self setNetBrowser:[[NSNetServiceBrowser alloc] init]];
        [[self netBrowser] setDelegate:self];
        
        [self setFoundServers:[[NSMutableArray alloc] init]];
    }
    
    return self;
}

- (void) start {
    [[self netBrowser] searchForServicesOfType:@"_adisk._tcp." inDomain:@"local."];
}

- (void) stop {
    [[self netBrowser] stop];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {

    NSLog(@"found service %@", netService);
    [[self foundServers] addObject:netService];
    
    if (!moreServicesComing) {
        [netService setDelegate:self];
        [netService resolveWithTimeout:1.5];
    }
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    NSLog(@"service is leaving %@", aNetService);
    [[self foundServers] removeObject:aNetService];
    
    if (!moreComing) {
        if ([[self delegate] respondsToSelector:@selector(foundDisksDidChange)])
            [[self delegate] foundDisksDidChange];
    }

}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"resolved address for %@", sender);
    if ([[self delegate] respondsToSelector:@selector(foundDisksDidChange)])
        [[self delegate] foundDisksDidChange];
}


- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"failed to resolve found services!");
}


- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    if ([[self delegate] respondsToSelector:@selector(foundDisksDidChange)])
        [[self delegate] foundDisksDidChange];
}

@end
