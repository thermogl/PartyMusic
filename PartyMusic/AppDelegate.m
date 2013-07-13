//
//  AppDelegate.m
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "DevicesManager.h"
#import "Device.h"
#import "ShakeDetectingWindow.h"
#import "MusicQueueController.h"

@implementation AppDelegate {
	ShakeDetectingWindow * _window;
	UIBackgroundTaskIdentifier _backgroundTaskIdentifier;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[application setIdleTimerDisabled:YES];
	[application beginReceivingRemoteControlEvents];
	
	_window = [[ShakeDetectingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	RootViewController * rootViewController = [[RootViewController alloc] init];
	[_window setRootViewController:rootViewController];
	
	[_window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
	_backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		[[DevicesManager sharedManager] stopSearching];
		_backgroundTaskIdentifier = UIBackgroundTaskInvalid;
	}];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
	[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
	[[DevicesManager sharedManager] startSearching];
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
	[[[DevicesManager sharedManager] ownDevice] setInterfaceOrientation:application.statusBarOrientation];
	[[[DevicesManager sharedManager] ownDevice] broadcastDeviceStatus];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	
	if (event.subtype == UIEventSubtypeRemoteControlPlay) [[MusicQueueController sharedController] play];
	else if (event.subtype == UIEventSubtypeRemoteControlPause) [[MusicQueueController sharedController] pause];
	else if (event.subtype == UIEventSubtypeRemoteControlStop) [[MusicQueueController sharedController] stop];
	else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) [[MusicQueueController sharedController] togglePlayPause];
	else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) [[MusicQueueController sharedController] skipForward];
	else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) [[MusicQueueController sharedController] skipBackward];
}


@end