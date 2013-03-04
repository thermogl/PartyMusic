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
@synthesize title;
@synthesize subtitle;
@synthesize songIdentifier;
@synthesize type;
@synthesize deviceUUID;
@synthesize currentTime;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary {
	
	if ((self = [super init])){
		title = [[dictionary objectForKey:kMusicQueueItemTitleKey] copy];
		subtitle = [[dictionary objectForKey:kMusicQueueItemSubtitleKey] copy];
		songIdentifier = [[dictionary objectForKey:kMusicQueueItemSongIdentifierKey] copy];
		type = [[dictionary objectForKey:kMusicQueueItemTypeKey] integerValue];
		deviceUUID = [[dictionary objectForKey:kMusicQueueItemDeviceUUIDKey] copy];
	}
	
	return self;
}

- (NSDictionary *)JSONDictionary {
	return (@{kMusicQueueItemTitleKey : title ?: @"",
			kMusicQueueItemSubtitleKey : subtitle ?: @"",
			kMusicQueueItemSongIdentifierKey : songIdentifier,
			kMusicQueueItemTypeKey : [NSNumber numberWithInteger:type],
			kMusicQueueItemDeviceUUIDKey : deviceUUID ?: @""});
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<MusicQueueItem %p; title = \"%@\"; type = %d; identifier = \"%@\", deviceUUID = \"%@\">", self, title, type, songIdentifier, deviceUUID];
}

- (void)dealloc {
	[songIdentifier release];
	[deviceUUID release];
	[super dealloc];
}

@end