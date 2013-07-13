//
//  MusicQueueItem.m
//  PartyMusic
//
//  Created by Tom Irving on 18/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "MusicQueueItem.h"

NSString * const kMusicQueueItemTitleKey = @"MusicQueueItemTitleKey";
NSString * const kMusicQueueItemSubtitleKey = @"MusicQueueItemSubtitleKey";
NSString * const kMusicQueueItemSongIdentifierKey = @"MusicQueueItemSongIdentifierKey";
NSString * const kMusicQueueItemTypeKey = @"MusicQueueItemTypeKey";
NSString * const kMusicQueueItemDeviceUUIDKey = @"MusicQueueItemDeviceUUIDKey";
NSString * const kMusicQueueItemCurrentTimeKey = @"MusicQueueItemCurrentTimeKey";

@implementation MusicQueueItem
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize songIdentifier = _songIdentifier;
@synthesize type = _type;
@synthesize deviceUUID = _deviceUUID;
@synthesize currentTime = _currentTime;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary {
	
	if ((self = [super init])){
		_title = [[dictionary objectForKey:kMusicQueueItemTitleKey] copy];
		_subtitle = [[dictionary objectForKey:kMusicQueueItemSubtitleKey] copy];
		_songIdentifier = [[dictionary objectForKey:kMusicQueueItemSongIdentifierKey] copy];
		_type = [[dictionary objectForKey:kMusicQueueItemTypeKey] integerValue];
		_deviceUUID = [[dictionary objectForKey:kMusicQueueItemDeviceUUIDKey] copy];
	}
	
	return self;
}

- (NSDictionary *)JSONDictionary {
	return (@{kMusicQueueItemTitleKey : _title ?: @"",
			kMusicQueueItemSubtitleKey : _subtitle ?: @"",
			kMusicQueueItemSongIdentifierKey : _songIdentifier,
			kMusicQueueItemTypeKey : [NSNumber numberWithInteger:_type],
			kMusicQueueItemDeviceUUIDKey : _deviceUUID ?: @""});
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<MusicQueueItem %p; title = \"%@\"; type = %d; identifier = \"%@\", deviceUUID = \"%@\">", self, _title, _type, _songIdentifier, _deviceUUID];
}


@end