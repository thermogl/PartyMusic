//
//  CoreAdditions.m
//  Friendz
//
//  Created by Tom Irving on 31/05/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "UIDevice+Additions.h"
#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>

NSString * const UIDeviceAudioOutputDidChangeNotificationName = @"UIDeviceAudioOutputDidChangeNotificationName";

@implementation UIDevice (TIAdditions)

- (NSString *)UUID {
	
	NSString * testUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
	
	if (!testUUID){
		testUUID = [NSString UUID];
		[[NSUserDefaults standardUserDefaults] setObject:testUUID forKey:@"UUID"];
	}
	
	return testUUID;
}

- (BOOL)isPhone {
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation {
	return (self.isPhone ? (orientation == UIInterfaceOrientationPortrait) : YES);
}

- (void)beginGeneratingDeviceAudioOutputChangeNotifications {
	
	if (AudioSessionInitialize(NULL, NULL, NULL, self) == noErr){
		AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
	}
}

- (void)endGeneratingDeviceAudioOutputChangeNotifications {
	AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, propListener, self);
}

- (BOOL)audioOutputConnected {
	NSString * newRoute = nil;
	UInt32 size = sizeof(CFStringRef);
	AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
	return [newRoute isEqualToString:@"Headphone"] || [newRoute isEqualToString:@"LineOut"];
}

void propListener(void * inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void * inData){
	if (inID == kAudioSessionProperty_AudioRouteChange){
		[[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceAudioOutputDidChangeNotificationName object:nil];
	}
}

@end
