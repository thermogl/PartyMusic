//
//  MusicQueueController.m
//  PartyMusic
//
//  Created by Tom Irving on 17/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "MusicQueueController.h"
#import "SoundCloud.h"
#import "DevicesManager.h"

NSString * const kMusicQueuePlayerDidChangeStateNotificationName = @"MusicQueuePlayerDidChangeStateNotificationName";
NSString * const kMusicQueuePlayerDidChangeQueueNotificationName = @"MusicQueuePlayerDidChangeQueueNotificationName";
NSString * const kMusicQueueControllerPreviousSongsKey = @"MusicQueueControllerPreviousSongsKey";
NSString * const kMusicQueueControllerCurrentSongKey = @"MusicQueueControllerCurrentSongKey";
NSString * const kMusicQueueControllerNextSongsKey = @"MusicQueueControllerNextSongsKey";

@interface MusicQueueController ()
@property (nonatomic, retain) MusicQueueItem * currentSong;
@property (nonatomic, retain) MusicQueueItem * fetchItem;
- (void)playQueueItem:(MusicQueueItem *)item;
- (void)playContentAtURL:(NSURL *)URL identifier:(id)identifier;
- (void)fetchQueueItem:(MusicQueueItem *)item identifier:(id)identifier;
- (void)cancelFetchQueueItem;
@end

@implementation MusicQueueController {
	AVPlayer * _player;
	NSMutableArray * _previousSongQueue;
	NSMutableArray * _nextSongQueue;
}
@synthesize currentSong = _currentSong;
@synthesize fetchItem = _fetchItem;

#pragma mark - Init
- (id)init {
	
	if ((self = [super init])){
		
		_player = [[AVPlayer alloc] initWithURL:nil];
		[_player addObserver:self forKeyPath:@"rate" options:0 context:nil];
		
		_previousSongQueue = [[NSMutableArray alloc] init];
		_currentSong = nil;
		_nextSongQueue = [[NSMutableArray alloc] init];
		
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
		[[AVAudioSession sharedInstance] setActive:YES error:NULL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	}
	
	return self;
}

#pragma mark - Property Overrides
- (AVPlayerPlayStatus)playStatus {
	return (_player.rate ? AVPlayerPlayStatusPlaying : (_fetchItem ? AVPlayerPlayStatusLoading : AVPlayerPlayStatusPaused));
}

- (BOOL)canSkipForward {
	return (_nextSongQueue.count > 0);
}

- (BOOL)canSkipBackward {
	return (_previousSongQueue.count > 0);
}

- (NSArray *)queue {
	
	NSMutableArray * queue = [[NSMutableArray alloc] init];
	[queue addObjectsFromArray:_previousSongQueue];
	if (_currentSong) [queue addObject:_currentSong];
	[queue addObjectsFromArray:_nextSongQueue];
	return [queue autorelease];
}

- (void)setJSONQueue:(NSDictionary *)JSONQueue {
	
	[_previousSongQueue removeAllObjects];
	[_nextSongQueue removeAllObjects];
	
	if ([JSONQueue objectForKey:kMusicQueueControllerCurrentSongKey]){
		MusicQueueItem * item = [[MusicQueueItem alloc] initWithJSONDictionary:[JSONQueue objectForKey:kMusicQueueControllerCurrentSongKey]];
		[self setCurrentSong:item];
		[item release];
	}
	
	if ([JSONQueue objectForKey:kMusicQueueControllerPreviousSongsKey]){
		
		[(NSArray *)[JSONQueue objectForKey:kMusicQueueControllerPreviousSongsKey] enumerateObjectsUsingBlock:^(NSDictionary * itemDict, NSUInteger idx, BOOL *stop) {
			MusicQueueItem * item = [[MusicQueueItem alloc] initWithJSONDictionary:itemDict];
			[_previousSongQueue addObject:item];
			[item release];
		}];
	}
	
	if ([JSONQueue objectForKey:kMusicQueueControllerNextSongsKey]){
		
		[(NSArray *)[JSONQueue objectForKey:kMusicQueueControllerNextSongsKey] enumerateObjectsUsingBlock:^(NSDictionary * itemDict, NSUInteger idx, BOOL *stop) {
			MusicQueueItem * item = [[MusicQueueItem alloc] initWithJSONDictionary:itemDict];
			[_nextSongQueue addObject:item];
			[item release];
		}];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kMusicQueuePlayerDidChangeQueueNotificationName object:nil];
}

- (NSDictionary *)JSONQueue {
	
	NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
	
	if (_currentSong){
		[_currentSong setCurrentTime:_player.currentItem.currentTime];
		[dictionary setObject:_currentSong.JSONDictionary forKey:kMusicQueueControllerCurrentSongKey];
	}
	
	if (self.canSkipBackward){
		
		NSMutableArray * previousSongsDicts = [[NSMutableArray alloc] initWithCapacity:_previousSongQueue.count];
		[_previousSongQueue enumerateObjectsUsingBlock:^(MusicQueueItem * item, NSUInteger idx, BOOL *stop) {
			[previousSongsDicts addObject:item.JSONDictionary];
		}];
		[dictionary setObject:previousSongsDicts forKey:kMusicQueueControllerPreviousSongsKey];
		[previousSongsDicts release];
	}
	
	if (self.canSkipForward){
		
		NSMutableArray * nextSongsDicts = [[NSMutableArray alloc] initWithCapacity:_nextSongQueue.count];
		[_nextSongQueue enumerateObjectsUsingBlock:^(MusicQueueItem * item, NSUInteger idx, BOOL *stop) {
			[nextSongsDicts addObject:item.JSONDictionary];
		}];
		[dictionary setObject:nextSongsDicts forKey:kMusicQueueControllerNextSongsKey];
		[nextSongsDicts release];
	}
	
	return [dictionary autorelease];
}

- (void)setFetchItem:(MusicQueueItem *)item {
	[item retain];
	[_fetchItem release];
	_fetchItem = item;
	[[NSNotificationCenter defaultCenter] postNotificationName:kMusicQueuePlayerDidChangeStateNotificationName object:self];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"rate"]) [[NSNotificationCenter defaultCenter] postNotificationName:kMusicQueuePlayerDidChangeStateNotificationName object:self];
}

#pragma mark - Player Notification Handlers
- (void)currentItemDidPlayToEnd:(NSNotification *)notification {
	[self skipForward];
}

#pragma mark - Queuing Methods
- (BOOL)queueItem:(MusicQueueItem *)item {
	
	[_nextSongQueue addObject:item];
	
	if (_currentSong) [self notifyQueueChange];
	else [self skipForward];
	
	return YES;
}

- (void)playQueueItem:(MusicQueueItem *)item {
	
	[self pause];
	
	id identifier = [item.songIdentifier copy];
	if (item.type == DeviceSongTypeMusicLibrary){
		
		if ([item.deviceUUID isEqualToString:[[[DevicesManager sharedManager] ownDevice] UUID]]){
			[[[DevicesManager sharedManager] ownDevice] getSongURLForPersistentID:item.songIdentifier callback:^(NSURL *URL) {
				[self playContentAtURL:URL identifier:identifier];
			}];
		}
		else
		{
			[self cancelFetchQueueItem];
			[self fetchQueueItem:item identifier:identifier];
		}
	}
	else if (item.type == DeviceSongTypeSoundCloud){
		[self playContentAtURL:[SoundCloud trackURLTaggedWithClientID:identifier] identifier:identifier];
	}
	else if (item.type == DeviceSongTypeYouTube){
		[YouTube getTrackURLFromVideoID:identifier callback:^(NSURL *URL){[self playContentAtURL:URL identifier:identifier];}];
	}
	
	[identifier release];
}

- (void)playContentAtURL:(NSURL *)URL identifier:(id)identifier {
	
	if ([_currentSong.songIdentifier isEqual:identifier]){
		[_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:URL]];
		[_player play];
		
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle : _currentSong.title, MPMediaItemPropertyArtist : _currentSong.subtitle}];
	}
}

- (void)notifyQueueChange {
	[[DevicesManager sharedManager] broadcastQueueStatus:self.JSONQueue];
	[[NSNotificationCenter defaultCenter] postNotificationName:kMusicQueuePlayerDidChangeQueueNotificationName object:nil];
}

- (void)fetchQueueItem:(MusicQueueItem *)item identifier:(id)identifier {
	
	[self setFetchItem:item];
	
	NSString * filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@.mp3", item.songIdentifier];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
	
	NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
	Device * device = [[DevicesManager sharedManager] deviceWithUUID:item.deviceUUID];
	[device sendSongRequest:identifier callback:^(NSData *songData, BOOL moreComing) {
		if (moreComing){
			[fileHandle seekToEndOfFile];
			[fileHandle writeData:songData];
		}
		else
		{
			[fileHandle synchronizeFile];
			[fileHandle closeFile];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self setFetchItem:nil];
				[self playContentAtURL:[NSURL fileURLWithPath:filePath] identifier:identifier];
			});
		}
	}];
	
	if (!device){
		[self setFetchItem:nil];
		[self skipForward];
	}
}

- (void)cancelFetchQueueItem {
	[[[DevicesManager sharedManager] deviceWithUUID:_fetchItem.deviceUUID] cancelSongRequest:_fetchItem.songIdentifier];
}

#pragma mark - Song Playback
- (void)play {
	
	if (_player.currentItem) [_player play];
	else [self playQueueItem:_currentSong];
}

- (void)pause {
	[_player pause];
}

- (void)stop {
	
	[self resignOutputControl];
	[self setCurrentSong:nil];
	[_previousSongQueue removeAllObjects];
	[_nextSongQueue removeAllObjects];
	
	[self notifyQueueChange];
}

- (void)togglePlayPause {
	
	if (self.playStatus == AVPlayerPlayStatusPlaying) [self pause];
	else [self play];
}

- (void)skipForward {
	
	if (self.canSkipForward){
		
		if (_currentSong) [_previousSongQueue addObject:_currentSong];
		[self setCurrentSong:[_nextSongQueue objectAtIndex:0]];
		[_nextSongQueue removeObjectAtIndex:0];
		
		[self playQueueItem:_currentSong];
		[self notifyQueueChange];
	}
}

- (void)skipBackward {
	
	if (self.canSkipBackward){

		if (_currentSong) [_nextSongQueue insertObject:_currentSong atIndex:0];
		[self setCurrentSong:[_previousSongQueue lastObject]];
		[_previousSongQueue removeLastObject];
		
		[self playQueueItem:_currentSong];
		[self notifyQueueChange];
	}
}

- (void)resignOutputControl {
	[_player pause];
	[_player replaceCurrentItemWithPlayerItem:nil];
	[self notifyQueueChange];
}

#pragma mark - Dealloc
- (void)dealloc {
	[_previousSongQueue release];
	[_currentSong release];
	[_nextSongQueue release];
	[_fetchItem release];
	[super dealloc];
}

#pragma mark - Singleton Stuff -
+ (MusicQueueController *)sharedController {
	
	static MusicQueueController * shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{shared = [[self alloc] init];});
	
	return shared;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {}

- (id)autorelease {
	return self;
}

@end