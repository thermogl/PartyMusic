//
//  ShakeDetectingWindow.m
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "ShakeDetectingWindow.h"
#import "DevicesManager.h"

NSString * const UIWindowDidShakeNotificationName = @"UIWindowDidShakeNotificationName";

@implementation ShakeDetectingWindow

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake) [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidShakeNotificationName object:self];
	[super motionBegan:motion withEvent:event];
}

@end