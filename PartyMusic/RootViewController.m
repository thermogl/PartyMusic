//
//  RootViewController.m
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "RootViewController.h"
#import "DevicesView.h"
#import "DeviceView.h"
#import "DevicesManager.h"
#import "SearchField.h"
#import "Device.h"
#import "SearchViewController.h"
#import "QueueControlView.h"
#import "QueueViewController.h"
#import "DevicesView+HarlemShake.h"
#import "RootScrollView.h"

CGFloat const kSearchBarHeight = 44;
CGFloat const kQueueControlViewHeight = 56;

@implementation RootViewController

- (void)viewDidLoad {
	
	scrollView = [[RootScrollView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:scrollView];
	[scrollView release];
	
	devicesView = [[DevicesView alloc] initWithFrame:self.view.bounds];
	[scrollView addSubview:devicesView];
	[devicesView release];
	
	searchField = [[SearchField alloc] initWithFrame:CGRectZero];
	[searchField addTarget:self action:@selector(searchFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
	[scrollView addSubview:searchField];
	[searchField release];
	
	searchViewController = [[SearchViewController alloc] init];
	[searchViewController setSearchField:searchField];
	[self addChildViewController:searchViewController];
	[searchViewController release];
	
	DeviceView * deviceView = [[DeviceView alloc] initWithDevice:[[DevicesManager sharedManager] ownDevice]];
	[devicesView addDeviceView:deviceView];
	[deviceView release];
	
	queueControlView = [[QueueControlView alloc] initWithFrame:CGRectZero];
	[queueControlView.queueButton addTarget:self action:@selector(queueButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:queueControlView];
	[queueControlView release];
	
	queueViewController = [[QueueViewController alloc] init];
	[scrollView addSubview:queueViewController.view];
	[self addChildViewController:queueViewController];
	[queueViewController release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAudioOutputDidChange:) name:UIDeviceAudioOutputDidChangeNotificationName object:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceAudioOutputChangeNotifications];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOutputStatusDidChange:) name:DevicesManagerDidReceiveOutputChangeNotificationName object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidShake:) name:UIWindowDidShakeNotificationName object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceControllerDidAddDevice:) name:DevicesManagerDidAddDeviceNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceControllerDidRemoveDevice:) name:DevicesManagerDidRemoveDeviceNotificationName object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveHarlem:) name:DevicesManagerDidReceiveHarlemNotificationName object:nil];
	[[DevicesManager sharedManager] startSearching];
}

- (void)viewDidResizeToNewOrientation {
	
	[scrollView setFrame:self.view.bounds];
	
	[searchField setFrame:CGRectMake(0, 0, scrollView.bounds.size.width, kSearchBarHeight)];
	[devicesView setFrame:CGRectMake(0, CGRectGetMaxY(searchField.frame), scrollView.bounds.size.width, scrollView.bounds.size.height - kSearchBarHeight - kQueueControlViewHeight)];
	
	[queueControlView setFrame:CGRectMake(0, CGRectGetMaxY(devicesView.frame), scrollView.bounds.size.width, kQueueControlViewHeight)];
	
	[searchViewController.view setFrame:devicesView.frame];
	[searchViewController viewDidResizeToNewOrientation];
	
	[queueViewController.view setFrame:CGRectMake(0, CGRectGetMaxY(queueControlView.frame), scrollView.bounds.size.width, scrollView.bounds.size.height - kQueueControlViewHeight)];
	[queueViewController viewDidResizeToNewOrientation];
	
	[scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, CGRectGetMaxY(queueViewController.view.frame))];
}

- (void)searchFieldDidBeginEditing:(NSNotification *)notification {
	[scrollView addSubview:searchViewController.view];
	[scrollView bringSubviewToFront:searchField];
	[scrollView bringSubviewToFront:queueControlView];
	[self viewDidResizeToNewOrientation];
}

- (void)queueButtonWasTapped:(UIButton *)sender {
	if (scrollView.contentOffset.y == 0) [scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(queueControlView.frame)) animated:YES];
	else [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)windowDidShake:(NSNotification *)notification {
	
	[[DevicesManager sharedManager] broadcastAction:DeviceActionShake];
	[devicesView.ownDeviceView shake];
}

- (void)deviceAudioOutputDidChange:(NSNotification *)notfication {
	
	if ([[UIDevice currentDevice] audioOutputConnected]){
		if (![[[DevicesManager sharedManager] ownDevice] isOutput]){
			[devicesView.ownDeviceView showOutputPrompt];
		}
	}
}

- (void)deviceOutputStatusDidChange:(NSNotification *)notification {
	[queueControlView setPlayerControlsHidden:![[[DevicesManager sharedManager] ownDevice] isOutput]];
}

#pragma mark - Device Controller Stuff
- (void)deviceControllerDidAddDevice:(NSNotification *)notification {
	
	DeviceView * deviceView = [[DeviceView alloc] initWithDevice:notification.object];
	[devicesView addDeviceView:deviceView];
	[deviceView release];
}

- (void)deviceControllerDidRemoveDevice:(NSNotification *)notification {
	
	__block DeviceView * targetView = nil;
	[devicesView.subviews enumerateObjectsUsingBlock:^(DeviceView * deviceView, NSUInteger idx, BOOL *stop) {
		if ([deviceView.device isEqual:notification.object]){
			targetView = deviceView;
			*stop = YES;
		}
	}];
	
	[devicesView removeDeviceView:targetView];
}

- (void)deviceDidReceiveHarlem:(NSNotification *)notification {
	[devicesView harlemShakeWithAudio:NO];
}

@end