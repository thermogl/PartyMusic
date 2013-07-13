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
#import "SearchSourcesViewController.h"
#import "MusicQueueController.h"

CGFloat const kSearchBarHeight = 44;
CGFloat const kQueueControlViewHeight = 56;

@implementation RootViewController {
	RootScrollView * _scrollView;
	
	SearchViewController * _searchViewController;
	SearchField * _searchField;
	
	DevicesView * _devicesView;
	
	QueueControlView * _queueControlView;
	QueueViewController * _queueViewController;
}

- (void)viewDidLoad {
	
	_scrollView = [[RootScrollView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_scrollView];
	
	_devicesView = [[DevicesView alloc] initWithFrame:_scrollView.bounds];
	[_scrollView addSubview:_devicesView];
	
	_searchField = [[SearchField alloc] initWithFrame:CGRectZero];
	[_searchField addTarget:self action:@selector(searchFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
	[_scrollView addSubview:_searchField];
	
	UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonWasLongPressed:)];
	[_searchField.searchButton addGestureRecognizer:longPressRecognizer];
	
	_searchViewController = [[SearchViewController alloc] init];
	[_searchViewController setSearchField:_searchField];
	[self addChildViewController:_searchViewController];
	
	DeviceView * deviceView = [[DeviceView alloc] initWithDevice:[[DevicesManager sharedManager] ownDevice]];
	[_devicesView addDeviceView:deviceView];
	
	_queueControlView = [[QueueControlView alloc] initWithFrame:CGRectZero];
	[_queueControlView.queueButton addTarget:self action:@selector(queueButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_queueControlView];
	
	_queueViewController = [[QueueViewController alloc] init];
	[_scrollView addSubview:_queueViewController.view];
	[self addChildViewController:_queueViewController];
	
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
	
	[_scrollView setFrame:self.view.bounds];
	
	[_searchField setFrame:CGRectMake(0, 0, _scrollView.bounds.size.width, kSearchBarHeight)];
	[_devicesView setFrame:CGRectMake(0, CGRectGetMaxY(_searchField.frame), _scrollView.bounds.size.width, _scrollView.bounds.size.height - kSearchBarHeight - kQueueControlViewHeight)];
	
	[_queueControlView setFrame:CGRectMake(0, CGRectGetMaxY(_devicesView.frame), _scrollView.bounds.size.width, kQueueControlViewHeight)];
	
	[_searchViewController.view setFrame:_devicesView.frame];
	[_searchViewController viewDidResizeToNewOrientation];
	
	[_queueViewController.view setFrame:CGRectMake(0, CGRectGetMaxY(_queueControlView.frame), _scrollView.bounds.size.width, _scrollView.bounds.size.height - kQueueControlViewHeight)];
	[_queueViewController viewDidResizeToNewOrientation];
	
	[_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, CGRectGetMaxY(_queueViewController.view.frame))];
}

- (void)searchFieldDidBeginEditing:(NSNotification *)notification {
	[_scrollView addSubview:_searchViewController.view];
	[_scrollView bringSubviewToFront:_searchField];
	[_scrollView bringSubviewToFront:_queueControlView];
	[self viewDidResizeToNewOrientation];
}

- (void)searchButtonWasLongPressed:(UILongPressGestureRecognizer *)sender {
	
	SearchSourcesViewController * viewController = [[SearchSourcesViewController alloc] init];
	[viewController setSearchSources:_searchViewController.searchSources];
	ViewControllerContainer * container = [[ViewControllerContainer alloc] initWithViewController:viewController dismissHandler:^{
		[_searchViewController setSearchSources:viewController.searchSources];
	}];
	
	[self presentViewController:container animated:YES completion:nil];
}

- (void)queueButtonWasTapped:(UIButton *)sender {
	if (_scrollView.contentOffset.y == 0) [_scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(_queueControlView.frame)) animated:YES];
	else [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)windowDidShake:(NSNotification *)notification {
	
	[[DevicesManager sharedManager] broadcastAction:DeviceActionShake];
	[_devicesView.ownDeviceView shake];
}

- (void)deviceAudioOutputDidChange:(NSNotification *)notfication {
	
	if ([[UIDevice currentDevice] audioOutputConnected]){
		if (![[[DevicesManager sharedManager] ownDevice] isOutput]){
			[_devicesView.ownDeviceView showOutputPrompt];
		}
	}
}

- (void)deviceOutputStatusDidChange:(NSNotification *)notification {
	[_queueControlView setPlayerControlsHidden:![[[DevicesManager sharedManager] ownDevice] isOutput]];
}

#pragma mark - Device Controller Stuff
- (void)deviceControllerDidAddDevice:(NSNotification *)notification {
	
	DeviceView * deviceView = [[DeviceView alloc] initWithDevice:notification.object];
	[_devicesView addDeviceView:deviceView];
}

- (void)deviceControllerDidRemoveDevice:(NSNotification *)notification {
	
	__block DeviceView * targetView = nil;
	[_devicesView.subviews enumerateObjectsUsingBlock:^(DeviceView * deviceView, NSUInteger idx, BOOL *stop) {
		if ([deviceView.device isEqual:notification.object]){
			targetView = deviceView;
			*stop = YES;
		}
	}];
	
	[_devicesView removeDeviceView:targetView];
}

- (void)deviceDidReceiveHarlem:(NSNotification *)notification {
	
	BOOL playing = [[MusicQueueController sharedController] playStatus] == AVPlayerPlayStatusPlaying;
	if (playing) [[MusicQueueController sharedController] pause];
	[_devicesView harlemShakeWithAudio:YES completion:^{
		if (playing) [[MusicQueueController sharedController] play];
	}];
}

@end