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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[application setIdleTimerDisabled:YES];
	[application beginReceivingRemoteControlEvents];
	
	window = [[ShakeDetectingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	RootViewController * rootViewController = [[RootViewController alloc] init];
	[window setRootViewController:rootViewController];
	[rootViewController release];
	
	[window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
	backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		
		UILocalNotification * localNotification = [[UILocalNotification alloc] init];
		[localNotification setAlertBody:@"All My Bros DJ is about to quit. Please relaunch to continue DJ'ing."];
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		[localNotification release];
		
		[[DevicesManager sharedManager] stopSearching];
		backgroundTaskIdentifier = UIBackgroundTaskInvalid;
	}];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
	[[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
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

- (void)dealloc {
	[window release];
    [super dealloc];
}

@end