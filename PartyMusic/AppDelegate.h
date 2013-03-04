//
//  AppDelegate.h
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShakeDetectingWindow;
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
	ShakeDetectingWindow * window;
	UIBackgroundTaskIdentifier backgroundTaskIdentifier;
}

@end