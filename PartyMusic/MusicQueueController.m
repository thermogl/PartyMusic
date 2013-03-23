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

@implementation MusicQueueController
@synthesize currentSong;
@synthesize fetchItem;

#pragma mark - Init
- (id)init {
	
	if ((self = [super init])){
		
		player = [[AVPlayer alloc] initWithURL:nil];
		[player addObserver:self forKeyPath:@"rate" options:0 context:nil];
		
		previousSongQueue = [[NSMutableArray alloc] init];
		currentSong = nil;
		nextSongQueue = [[NSMutableArray alloc] init];
		
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
		[[AVAudioSession sharedInstance] setActive:YES error:NULL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	}
	
	return self;
}

#pragma mark - Property Overrides
- (AVPlayerPlayStatus)playStatus {
	return (player.rate ? AVPlayerPlayStatusPlaying : (fetchItem ? AVPlayerPlayStatusLoading : AVPlayerPlayStatusPaused));
}

- (BOOL)canSkipForward {
	return (nextSongQueue.count > 0);
}

- (BOOL)canSkipBackward {
	return (previousSongQueue.count > 0);
}

- (NSArray *)queue {
	
	NSMutableArray * queue = [[NSMutableArray alloc] init];
	[queue addObjectsFromArray:previousSongQueue];
	if (currentSong) [queue addObject:currentSong];
	[queue addObjectsFromArray:nextSongQueue];
	return [queue autorelease];
}

- (void)setJSONQueue:(NSDictionary *)JSONQueue {
	
	[previousSongQueue removeAllObjects];
	[nextSongQueue removeAllObjects];
	
	if ([JSONQueue objectForKey:kMusicQueueControllerCurrentSongKey]){
		MusicQueueItem * item = [[MusicQueueItem alloc] initWithJSONDictionary:[JSONQueue objectForKey:kMusicQueueControllerCurrentSongKey]];
		[self setCurrentSong:item];
		[item release];
	}
	
	if ([JSONQueue objectForKey:kMusicQueueControllerPreviousSongsKey]){
		
		[(NSArray *)[JSONQueue objectForKey:kMusicQueueControllerPreviousSongsKey] enumerateObjectsUsingBlock:^(NSDictionary * itemDict, NSUInteger idx, BOOL *stop) {
			MusicQueueItem * item = [[MusicQueueItem alloc] initWithJSONDictionary:itemDict];
			[previousSongQueue addObject:item];
			[item release];
		}];
	}
	
	if ([JSONQueue objectForKey:kMusicQueueControllerNextSongsKey]){
		
		[(NSArray *)[JSONQueue objectForKey:kMusicQueueControllerNextSongsKey] enumerateObjectsUsingBlock:^(NSDictionary * itemDict, NSUInteger idx, BOOL *stop) {
			MusicQueueItem * item = [[MusicQueueItem alloc] initWithJSONDictionary:itemDict];
			[nextSongQueue addObject:item];
			[item release];
		}];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kMusicQueuePlayerDidChangeQueueNotificationName object:nil];
}

- (NSDictionary *)JSONQueue {
	
	NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
	
	if (currentSong){
		[currentSong setCurrentTime:player.currentItem.currentTime];
		[dictionary setObject:currentSong.JSONDictionary forKey:kMusicQueueControllerCurrentSongKey];
	}
	
	if (self.canSkipBackward){
		
		NSMutableArray * previousSongsDicts = [[NSMutableArray alloc] initWithCapacity:previousSongQueue.count];
		[previousSongQueue enumerateObjectsUsingBlock:^(MusicQueueItem * item, NSUInteger idx, BOOL *stop) {
			[previousSongsDicts addObject:item.JSONDictionary];
		}];
		[dictionary setObject:previousSongsDicts forKey:kMusicQueueControllerPreviousSongsKey];
		[previousSongsDicts release];
	}
	
	if (self.canSkipForward){
		
		NSMutableArray * nextSongsDicts = [[NSMutableArray alloc] initWithCapacity:nextSongQueue.count];
		[nextSongQueue enumerateObjectsUsingBlock:^(MusicQueueItem * item, NSUInteger idx, BOOL *stop) {
			[nextSongsDicts addObject:item.JSONDictionary];
		}];
		[dictionary setObject:nextSongsDicts forKey:kMusicQueueControllerNextSongsKey];
		[nextSongsDicts release];
	}
	
	return [dictionary autorelease];
}

- (void)setFetchItem:(MusicQueueItem *)item {
	[item retain];
	[fetchItem release];
	fetchItem = item;
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
	
	[nextSongQueue addObject:item];
	
	if (currentSong) [self notifyQueueChange];
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
	
	if ([currentSong.songIdentifier isEqual:identifier]){
		[player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:URL]];
		[player play];
		
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle : currentSong.title, MPMediaItemPropertyArtist : currentSong.subtitle}];
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
	[[[DevicesManager sharedManager] deviceWithUUID:item.deviceUUID] sendSongRequest:identifier callback:^(NSData * songData, BOOL moreComing) {
		
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
}

- (void)cancelFetchQueueItem {
	[[[DevicesManager sharedManager] deviceWithUUID:fetchItem.deviceUUID] cancelSongRequest:fetchItem.songIdentifier];
}

#pragma mark - Song Playback
- (void)play {
	
	if (player.currentItem) [player play];
	else [self playQueueItem:currentSong];
}

- (void)pause {
	[player pause];
}

- (void)stop {
	
	[self resignOutputControl];
	[self setCurrentSong:nil];
	[previousSongQueue removeAllObjects];
	[nextSongQueue removeAllObjects];
	
	[self notifyQueueChange];
}

- (void)togglePlayPause {
	
	if (self.playStatus == AVPlayerPlayStatusPlaying) [self pause];
	else [self play];
}

- (void)skipForward {
	
	if (self.canSkipForward){
		
		if (currentSong) [previousSongQueue addObject:currentSong];
		[self setCurrentSong:[nextSongQueue objectAtIndex:0]];
		[nextSongQueue removeObjectAtIndex:0];
		
		[self playQueueItem:currentSong];
		[self notifyQueueChange];
	}
}

- (void)skipBackward {
	
	if (self.canSkipBackward){

		if (currentSong) [nextSongQueue insertObject:currentSong atIndex:0];
		[self setCurrentSong:[previousSongQueue lastObject]];
		[previousSongQueue removeLastObject];
		
		[self playQueueItem:currentSong];
		[self notifyQueueChange];
	}
}

- (void)resignOutputControl {
	[player pause];
	[player replaceCurrentItemWithPlayerItem:nil];
	[self notifyQueueChange];
}

#pragma mark - Dealloc
- (void)dealloc {
	[previousSongQueue release];
	[currentSong release];
	[nextSongQueue release];
	[fetchItem release];
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