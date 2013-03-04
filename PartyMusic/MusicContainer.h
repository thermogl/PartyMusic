//
//  MusicContainer.h
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "Device.h"

@class Device;

typedef NS_ENUM(NSInteger, MusicContainerType) {
	MusicContainerTypeArtist = 0,
	MusicContainerTypeAlbum = 1,
	MusicContainerTypeSong = 2,
};

@interface MusicContainer : NSObject {
	
	MusicContainerType type;
	DeviceSongType songType;
	id identifier;
	NSString * title;
	NSString * subtitle;
	Device * device;
}

@property (nonatomic, assign) MusicContainerType type;
@property (nonatomic, assign) DeviceSongType songType;
@property (nonatomic, copy) id identifier;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, readonly) NSDictionary * JSONDictionary;
@property (nonatomic, assign) Device * device;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary;

+ (NSArray *)artistsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary;
+ (NSArray *)albumsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary;
+ (NSArray *)songsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary;

+ (NSArray *)containersFromJSONDictionaries:(NSArray *)jsonDictionaries device:(Device *)device;

@end