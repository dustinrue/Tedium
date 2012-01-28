//
//  DOTediumApp.h
//  Tedium
//
//  Created by David Jennes on 27/01/12.
//  Copyright (c) 2012. All rights reserved.
//

@protocol DOTediumApp <NSObject>

@property (nonatomic, readwrite, retain) NSString *currentDestination;
@property (nonatomic, readonly) NSArray *allDestinations;

@end
