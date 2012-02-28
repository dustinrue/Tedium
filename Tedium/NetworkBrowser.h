//
//  NetworkBrowser.h
//  Tedium
//
//  Created by Dustin Rue on 2/9/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DRNetworkBrowserDelegate <NSObject>;

- (void) foundDisksDidChange;

@end

@interface NetworkBrowser : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate>

@property (readwrite, retain) NSNetServiceBrowser *netBrowser;
@property (readwrite, retain) NSMutableArray *foundServers;
@property (nonatomic, assign) id <DRNetworkBrowserDelegate> delegate;

- (void) start;
- (void) stop;

@end


