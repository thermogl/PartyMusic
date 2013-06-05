//
//  DevicesManager.h
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "Device.h"

extern NSString * const DevicesManagerDidAddDeviceNotificationName;
extern NSString * const DevicesManagerDidRemoveDeviceNotificationName;
extern NSString * const DevicesManagerDidReceiveShakeEventNotificationName;
extern NSString * const DevicesManagerDidReceiveHarlemNotificationName;
extern NSString * const DevicesManagerDidReceiveOrientationChangeNotificationName;
extern NSString * const DevicesManagerDidReceiveOutputChangeNotificationName;
extern NSString * const kUserInterfaceIdiomTXTRecordKeyName;

typedef void (^DevicesManagerSearchCallback)(Device * device, NSDictionary * results);
@interface DevicesManager : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, DeviceDelegate>

@property (nonatomic, readonly) OwnDevice * ownDevice;
@property (nonatomic, readonly) Device * outputDevice;
@property (nonatomic, readonly) NSArray * devices;

- (void)startSearching;
- (void)stopSearching;

- (void)broadcastDictionary:(NSDictionary *)dictionary payloadType:(DevicePayloadType)payloadType;
- (void)broadcastSearchRequest:(NSString *)searchString callback:(DevicesManagerSearchCallback)callback;
- (void)broadcastQueueStatus:(NSDictionary *)queueStatus;
- (void)broadcastAction:(DeviceAction)action;

- (Device *)deviceWithUUID:(NSString *)UUID;

+ (DevicesManager *)sharedManager;

@end