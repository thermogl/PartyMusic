//
//  RootViewController.h
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "OrientationAwareViewController.h"

@class DevicesView, SearchField, SearchViewController, QueueControlView, QueueViewController;
@interface RootViewController : OrientationAwareViewController {
	
	UIScrollView * scrollView;
	
	SearchViewController * searchViewController;
	SearchField * searchField;
	
	DevicesView * devicesView;
	
	QueueControlView * queueControlView;
	QueueViewController * queueViewController;
}

@end