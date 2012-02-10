//
//  NetworkBrowser.h
//  Tedium
//
//  Created by Dustin Rue on 2/9/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkBrowser : NSObject <NSNetServiceBrowserDelegate>

@property (readwrite, retain) NSNetServiceBrowser *netBrowser;
@property (readwrite, retain) NSMutableArray *foundServers;

- (void) start;
- (void) stop;

@end
