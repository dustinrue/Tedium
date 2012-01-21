//
//  AppDelegate+HelperTool.h
//  From ControlPlane
//
//  Created by David Jennes on 05/09/11.
//  Modified for use with Tedium by Dustin Rue
//  Copyright 2011. All rights reserved.
//

#import "AppDelegate.h"
#import "TediumHelpertoolCommon.h"

@interface AppDelegate (HelperTool)

- (BOOL) helperToolPerformAction: (NSString *) action;
- (BOOL) helperToolPerformAction: (NSString *) action withParameter: (id) parameter;

@end
