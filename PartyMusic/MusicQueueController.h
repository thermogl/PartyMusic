//
//  MusicQueueController.h
//  PartyMusic
//
//  Created by Tom Irving on 17/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "MusicContainer.h"
#import "SoundCloud.h"
#import "YouTube.h"
#import "MusicQueueItem.h"

extern NSString * const kMusicQueuePlayerDidChangeStateNotificationName;
extern NSString * const kMusicQueuePlayerDidChangeQueueNotificationName;

typedef NS_ENUM(NSInteger, AVPlayerPlayStatus){
	AVPlayerPlayStatusUnknown = 0,
	AVPlayerPlayStatusPlaying = 1,
	AVPlayerPlayStatusPaused = 2,
};

@class MusicQueueItem;
@interface MusicQueueController : NSObject {
	
	AVPlayer * player;
	
	NSMutableArray * previousSongQueue;
	MusicQueueItem * currentSong;
	NSMutableArray * nextSongQueue;
	
	MusicQueueItem * fetchItem;
}

@property (nonatomic, retain, readonly) MusicQueueItem * currentSong;
@property (nonatomic, readonly) AVPlayerPlayStatus playStatus;
@property (nonatomic, readonly) BOOL canSkipForward;
@property (nonatomic, readonly) BOOL canSkipBackward;
@property (nonatomic, readonly) NSArray * queue;
@property (nonatomic, assign) NSDictionary * JSONQueue;

- (void)queueItem:(MusicQueueItem *)item;

- (void)play;
- (void)pause;
- (void)stop;
- (void)togglePlayPause;
- (void)skipForward;
- (void)skipBackward;

- (void)resignOutputControl;

+ (MusicQueueController *)sharedController;

@end
