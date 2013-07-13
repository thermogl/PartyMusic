//
//  DevicesManager.m
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "DevicesManager.h"
#import "Device.h"
#import "GCDAsyncSocket.h"
#import "NSNetService+Additions.h"
#import "MusicContainer.h"
#import "MusicQueueController.h"
#import "TrackFetcher.h"

NSString * const DevicesManagerDidAddDeviceNotificationName = @"DevicesManagerDidAddDeviceNotificationName";
NSString * const DevicesManagerDidRemoveDeviceNotificationName = @"DevicesManagerDidRemoveDeviceNotificationName";
NSString * const DevicesManagerDidReceiveShakeEventNotificationName = @"DevicesManagerDidReceiveShakeEventNotificationName";
NSString * const DevicesManagerDidReceiveHarlemNotificationName = @"DevicesManagerDidReceiveHarlemNotificationName";
NSString * const DevicesManagerDidReceiveOrientationChangeNotificationName = @"DevicesManagerDidReceiveOrientationChangeNotificationName";
NSString * const DevicesManagerDidReceiveOutputChangeNotificationName = @"DevicesManagerDidReceiveOutputChangeNotificationName";
NSString * const kDeviceServiceType = @"_partymusic._tcp.";
NSString * const kUserInterfaceIdiomTXTRecordKeyName = @"UserInterfaceIdiomTXTRecordKeyName";

@interface DevicesManager () <GCDAsyncSocketDelegate>
@property (nonatomic, strong) NSNetService * ownService;
@end

@implementation DevicesManager {
	
	dispatch_queue_t _socketQueue;
	GCDAsyncSocket * _incomingSocket;
	
	NSMutableArray * _devices;
	NSMutableArray * _pendingConnections;
	NSMutableArray * _services;
	NSNetServiceBrowser * _serviceBrowser;
	
	NSMutableDictionary * _songRequestDictionary;
	
	BOOL _searching;
}
@synthesize ownDevice = _ownDevice;
@synthesize ownService = _ownService;

#pragma mark - Init
- (id)init {
	
	if ((self = [super init])){
		
		_ownDevice = [[OwnDevice alloc] init];
		[_ownDevice setDelegate:self];
		
		_devices = [[NSMutableArray alloc] init];
		_services = [[NSMutableArray alloc] init];
		_pendingConnections = [[NSMutableArray alloc] init];
		
		_serviceBrowser = [[NSNetServiceBrowser alloc] init];
		
		_socketQueue = dispatch_queue_create("com.partymusic.devicescontroller.socketqueue", NULL);
		_incomingSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
		_searching = NO;
		
		_songRequestDictionary = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

#pragma mark - Property Overrides
- (Device *)outputDevice {
	
	__block Device * outputDevice = nil;
	[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {
		if (device.isOutput){
			outputDevice = device;
			*stop = YES;
		}
	}];
	
	if (!outputDevice && _ownDevice.isOutput)
		outputDevice = _ownDevice;
	
	return outputDevice;
}

- (NSArray *)devices {
	return _devices;
}

#pragma mark - Instance Methods
- (void)startSearching {
	
	if (!_searching){
		
		NSError * error = nil;
		if ([_incomingSocket acceptOnPort:0 error:&error]){
			
			_searching = YES;
			
			_ownService = [[NSNetService alloc] initWithDomain:@"local" type:kDeviceServiceType name:[[UIDevice currentDevice] name] port:_incomingSocket.localPort];
			
			NSDictionary * TXTRecord = @{kUserInterfaceIdiomTXTRecordKeyName: [NSString stringWithFormat:@"%d", UI_USER_INTERFACE_IDIOM()]};
			[_ownService setTXTRecordDictionary:TXTRecord];
			[_ownService setDelegate:self];
			[_ownService publish];
			
			[_serviceBrowser setDelegate:self];
			[_serviceBrowser searchForServicesOfType:kDeviceServiceType inDomain:@"local"];
		}
		else
		{
			NSLog(@"Unable to accept on port with error: %@", error);
		}
	}
}

- (void)stopSearching {
	
	[_serviceBrowser stop];
	[_ownService stop];
	[_services removeAllObjects];
	[_pendingConnections removeAllObjects];
	[_incomingSocket disconnect];
	
	[_devices enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {
		[_devices removeObjectAtIndex:idx];
		[[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidRemoveDeviceNotificationName object:device];
	}];
	
	_searching = NO;
}

- (void)broadcastDictionary:(NSDictionary *)dictionary payloadType:(DevicePayloadType)payloadType {
	[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {[device sendDictionary:dictionary payloadType:payloadType identifier:nil];}];
}

- (void)broadcastSearchRequest:(NSString *)searchString callback:(DevicesManagerSearchCallback)callback {
	
	if (callback){
		[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {
			[device sendSearchRequest:searchString callback:^(NSDictionary * results){
				callback(device, results);
			}];
		}];
	}
}

- (void)broadcastQueueStatus:(NSDictionary *)queueStatus {
	[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {[device sendQueueStatus:queueStatus];}];
}

- (void)broadcastAction:(DeviceAction)action {
	[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {[device sendAction:action];}];
}

- (Device *)deviceWithUUID:(NSString *)UUID {
	
	__block Device * targetDevice = nil;
	[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {
		if ([device.UUID isEqualToString:UUID]){
			targetDevice = device;
			*stop = YES;
		}
	}];
	
	if (!targetDevice && [_ownDevice.UUID isEqualToString:UUID])
		targetDevice = _ownDevice;
	
	return targetDevice;
}

#pragma mark - incoming socket Delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	
	__block BOOL assignedSocket = NO;
	[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {
		if ([device.netService hasSameHostAsSocket:newSocket]){
			[device setIncomingSocket:newSocket];
			assignedSocket = YES;
			*stop = YES;
		}
	}];
	
	if (!assignedSocket) [_pendingConnections addObject:newSocket];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
	[_pendingConnections removeObject:sock];
}

#pragma mark - Net Server Stuff
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
	NSLog(@"Unable to publish own service: %@", errorDict);
}

#pragma mark - Net Service Browser Stuff
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
	NSLog(@"Service search failed with error dict : %@", errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	
	if (![aNetService isEqual:_ownService]){
		[_services addObject:aNetService];
		[aNetService setDelegate:self];
		[aNetService resolveWithTimeout:0];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	[aNetService stop];
	
	__block Device * targetDevice = nil;
	[_devices enumerateObjectsUsingBlock:^(Device * device, NSUInteger idx, BOOL *stop) {
		if ([device.netService isEqual:aNetService]){
			targetDevice = device;
			*stop = YES;
		}
	}];
	
	[_devices removeObject:targetDevice];
	[_services removeObject:aNetService];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidRemoveDeviceNotificationName object:targetDevice];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	
	Device * device = [[Device alloc] initWithNetService:service];
	[device setDelegate:self];
	[_devices addObject:device];
	
	[_pendingConnections enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(GCDAsyncSocket * connection, NSUInteger idx, BOOL *stop) {
		if ([service hasSameHostAsSocket:connection]){
			[device setIncomingSocket:connection];
			[_pendingConnections removeObject:connection];
			*stop = YES;
		}
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidAddDeviceNotificationName object:device];
	[_services removeObject:service];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	NSLog(@"Service failed to resolve with dict: \n%@\n", errorDict);
	[_services removeObject:sender];
}

#pragma mark - Device Delegate
- (void)device:(Device *)device didChangeInterfaceOrienation:(UIInterfaceOrientation)interfaceOrientation {
	[[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidReceiveOrientationChangeNotificationName object:device];
}

- (void)device:(Device *)device didChangeOutputStatus:(BOOL)isOutput {
	
	if (device.isOwnDevice && !isOutput) [[MusicQueueController sharedController] resignOutputControl];
	[[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidReceiveOutputChangeNotificationName object:device];
}

- (void)device:(Device *)device didReceiveAction:(DeviceAction)action {
	
	if (action == DeviceActionShake) [[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidReceiveShakeEventNotificationName object:device];
	else if (action == DeviceActionVibrate) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
	else if (action == DeviceActionHarlemShake) [[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidReceiveHarlemNotificationName object:nil];
}

- (NSDictionary *)device:(Device *)device didReceiveBrowseRequestWithIdentifier:(NSString *)identifier {
	return [self device:device didReceiveSearchRequest:nil identifier:identifier];
}

- (NSDictionary *)device:(Device *)device didReceiveSearchRequest:(NSString *)searchString identifier:(NSString *)identifier {
#if !TARGET_IPHONE_SIMULATOR
	return (@{kDeviceSearchArtistsKeyName: [MusicContainer artistsContainingSubstring:searchString dictionary:YES],
			kDeviceSearchAlbumsKeyName : [MusicContainer albumsContainingSubstring:searchString dictionary:YES],
			kDeviceSearchSongsKeyName: [MusicContainer songsContainingSubstring:searchString dictionary:YES]});
#endif
	return [NSDictionary dictionary];
}

- (NSArray *)device:(Device *)device didReceiveAlbumsForArtistRequest:(NSNumber *)persistentID identifier:(NSString *)identifier {
#if !TARGET_IPHONE_SIMULATOR
	return [MusicContainer albumsForArtistPersistentID:persistentID dictionary:YES];
#endif
	return [NSArray array];
}

- (NSArray *)device:(Device *)device didReceiveSongsForAlbumRequest:(NSNumber *)persistentID identifier:(NSString *)identifier {
#if !TARGET_IPHONE_SIMULATOR
	return [MusicContainer songsForAlbumPersistentID:persistentID dictionary:YES];
#endif
	return [NSArray array];
}

- (void)device:(Device *)aDevice didReceiveSongRequest:(NSNumber *)persistentID identifier:(NSString *)identifier {
	
	__block TrackFetcher * trackFetcher = [[TrackFetcher alloc] init];
	[trackFetcher setCompletionHandler:^{[_songRequestDictionary removeObjectForKey:persistentID];}];
	[trackFetcher getTrackDataForPersistentID:persistentID callback:^(NSData *chunk, BOOL moreComing) {
		[aDevice sendSongResult:chunk identifier:identifier moreComing:moreComing];
	}];
	[_songRequestDictionary setObject:trackFetcher forKey:persistentID];
}

- (void)device:(Device *)device didReceiveSongCancel:(NSNumber *)persistentID {
	[(TrackFetcher *)[_songRequestDictionary objectForKey:persistentID] setCancelled:YES];
}

- (void)device:(Device *)device didReceiveQueue:(NSDictionary *)queue {
	[[MusicQueueController sharedController] setJSONQueue:queue];
}

#pragma mark - Dealloc
- (void)dealloc {
	dispatch_release(_socketQueue);
}

#pragma mark - Singleton Stuff -
+ (DevicesManager *)sharedManager {
	
	static DevicesManager * shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{shared = [[self alloc] init];});
	
	return shared;
}

@end