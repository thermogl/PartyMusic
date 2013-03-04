//
//  CoreAdditions.h
//  Friendz
//
//  Created by Tom Irving on 31/05/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

extern NSString * const UIDeviceAudioOutputDidChangeNotificationName;

@interface UIDevice (TIAdditions)
@property (nonatomic, readonly) NSString * UUID;
@property (nonatomic, readonly) BOOL isPhone;
@property (nonatomic, readonly) BOOL audioOutputConnected;

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation;

- (void)beginGeneratingDeviceAudioOutputChangeNotifications;
- (void)endGeneratingDeviceAudioOutputChangeNotifications;
@end
