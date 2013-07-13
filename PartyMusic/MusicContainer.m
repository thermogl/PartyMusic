//
//  MusicContainer.m
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "MusicContainer.h"
#import "DevicesManager.h"

NSString * const kDictionaryTypeKey = @"DictionaryTypeKey";
NSString * const kDictionarySongTypeKey = @"DictionarySongTypeKey";
NSString * const kDictionaryIdentifierKey = @"DictionaryIdentifierKey";
NSString * const kDictionaryTitleKey = @"DictionaryTitleKey";
NSString * const kDictionarySubtitleKey = @"DictionarySubtitleKey";

@interface MusicContainer (Private)
+ (NSArray *)artistsWithFilterPredicates:(NSSet *)filterPredicates dictionary:(BOOL)dictionary;
+ (NSArray *)albumsWithFilterPredicates:(NSSet *)filterPredicates dictionary:(BOOL)dictionary;
+ (NSArray *)songsWithFilterPredicates:(NSSet *)filterPredicates dictionary:(BOOL)dictionary;
@end

@implementation MusicContainer
@synthesize type = _type;
@synthesize songType = _songType;
@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize device = _device;

#pragma mark - Instance Methods
- (id)initWithJSONDictionary:(NSDictionary *)dictionary {
	
	if ((self = [super init])){
		_type = [[dictionary objectForKey:kDictionaryTypeKey] integerValue];
		_songType = [[dictionary objectForKey:kDictionarySongTypeKey] integerValue];
		_identifier = [[dictionary objectForKey:kDictionaryIdentifierKey] copy];
		_title = [[dictionary objectForKey:kDictionaryTitleKey] copy];
		_subtitle = [[dictionary objectForKey:kDictionarySubtitleKey] copy];
	}
	
	return self;
}

- (NSDictionary *)JSONDictionary {
	return (@{kDictionaryTypeKey : [NSNumber numberWithInteger:_type],
			kDictionarySongTypeKey : [NSNumber numberWithInteger:_songType],
			kDictionaryIdentifierKey : _identifier,
			kDictionaryTitleKey : (_title ?: @""),
			kDictionarySubtitleKey : (_subtitle ?: @"")});
}

#pragma mark - General Queries
+ (NSArray *)artistsWithFilterPredicates:(NSSet *)filterPredicates dictionary:(BOOL)dictionary {
	
	MPMediaQuery * artistsQuery = [MPMediaQuery artistsQuery];
	[artistsQuery setFilterPredicates:filterPredicates];
	
	NSMutableArray * containers = [NSMutableArray array];
	[artistsQuery.collections enumerateObjectsUsingBlock:^(MPMediaItemCollection * collection, NSUInteger idx, BOOL *stop) {
		
		MusicContainer * container = [[MusicContainer alloc] init];
		[container setIdentifier:[collection.representativeItem valueForProperty:MPMediaItemPropertyArtistPersistentID]];
		[container setTitle:[collection.representativeItem valueForProperty:MPMediaItemPropertyArtist]];
		[container setType:MusicContainerTypeArtist];
		[container setDevice:[[DevicesManager sharedManager] ownDevice]];
		[containers addObject:(dictionary ? container.JSONDictionary : container)];
	}];
	
	return containers;
}

+ (NSArray *)albumsWithFilterPredicates:(NSSet *)filterPredicates dictionary:(BOOL)dictionary {
	
	MPMediaQuery * albumsQuery = [MPMediaQuery albumsQuery];
	[albumsQuery setFilterPredicates:filterPredicates];
	
	NSMutableArray * containers = [NSMutableArray array];
	[albumsQuery.collections enumerateObjectsUsingBlock:^(MPMediaItemCollection * collection, NSUInteger idx, BOOL *stop) {
		
		MusicContainer * container = [[MusicContainer alloc] init];
		[container setIdentifier:[collection.representativeItem valueForProperty:MPMediaItemPropertyAlbumPersistentID]];
		[container setTitle:[collection.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle]];
		[container setType:MusicContainerTypeAlbum];
		[container setDevice:[[DevicesManager sharedManager] ownDevice]];
		[containers addObject:(dictionary ? container.JSONDictionary : container)];
	}];
	
	return containers;
}

+ (NSArray *)songsWithFilterPredicates:(NSSet *)filterPredicates dictionary:(BOOL)dictionary {
	
	MPMediaQuery * songsQuery = [MPMediaQuery songsQuery];
	[songsQuery setFilterPredicates:filterPredicates];
	
	NSMutableArray * containers = [NSMutableArray array];
	[songsQuery.items enumerateObjectsUsingBlock:^(MPMediaItem * item, NSUInteger idx, BOOL *stop) {
		
		if ([item valueForProperty:MPMediaItemPropertyAssetURL]){
			
			MusicContainer * container = [[MusicContainer alloc] init];
			[container setIdentifier:[item valueForProperty:MPMediaItemPropertyPersistentID]];
			[container setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
			[container setSubtitle:[item valueForProperty:MPMediaItemPropertyAlbumArtist]];
			[container setType:MusicContainerTypeSong];
			[container setDevice:[[DevicesManager sharedManager] ownDevice]];
			[containers addObject:(dictionary ? container.JSONDictionary : container)];
		}
	}];
	
	return containers;
}

#pragma mark - Search helpers
+ (NSArray *)artistsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary {
	
	NSSet * set = nil;
	if (substring){
		MPMediaPropertyPredicate * predicate = [MPMediaPropertyPredicate predicateWithValue:substring forProperty:MPMediaItemPropertyArtist
																			 comparisonType:MPMediaPredicateComparisonContains];
		set = [NSSet setWithObject:predicate];
	}
	
	return [self artistsWithFilterPredicates:set dictionary:dictionary];
}

+ (NSArray *)albumsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary {
	
	NSSet * set = nil;
	if (substring){
		MPMediaPropertyPredicate * predicate = [MPMediaPropertyPredicate predicateWithValue:substring forProperty:MPMediaItemPropertyAlbumTitle
																			 comparisonType:MPMediaPredicateComparisonContains];
		set = [NSSet setWithObject:predicate];
	}
	
	return [self albumsWithFilterPredicates:set dictionary:dictionary];
}

+ (NSArray *)songsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary {
	
	NSSet * set = nil;
	if (substring){
		MPMediaPropertyPredicate * predicate = [MPMediaPropertyPredicate predicateWithValue:substring forProperty:MPMediaItemPropertyTitle
																			 comparisonType:MPMediaPredicateComparisonContains];
		set = [NSSet setWithObject:predicate];
	}
	
	return [self songsWithFilterPredicates:set dictionary:dictionary];
}

#pragma mark - Specifics
+ (NSArray *)albumsForArtistPersistentID:(NSNumber *)persistentID dictionary:(BOOL)dictionary {
	
	if (persistentID){
		MPMediaPropertyPredicate * predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID.stringValue.unsignedLongLongNumber
																				forProperty:MPMediaItemPropertyArtistPersistentID];
		return [self albumsWithFilterPredicates:[NSSet setWithObject:predicate] dictionary:dictionary];
	}
	
	return [NSArray array];
}

+ (NSArray *)songsForAlbumPersistentID:(NSNumber *)persistentID dictionary:(BOOL)dictionary {
	
	if (persistentID){
		MPMediaPropertyPredicate * predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID.stringValue.unsignedLongLongNumber
																				forProperty:MPMediaItemPropertyAlbumPersistentID];
		return [self songsWithFilterPredicates:[NSSet setWithObject:predicate] dictionary:dictionary];
	}
	
	return [NSArray array];
}

#pragma mark - Conversion
+ (NSArray *)containersFromJSONDictionaries:(NSArray *)jsonDictionaries device:(Device *)device {
		
	NSMutableArray * containers = [NSMutableArray array];
	[jsonDictionaries enumerateObjectsUsingBlock:^(NSDictionary * dict, NSUInteger idx, BOOL *stop) {
		MusicContainer * container = [[MusicContainer alloc] initWithJSONDictionary:dict];
		[container setDevice:device];
		[containers addObject:container];
	}];
	
	return containers;
}

#pragma mark - Description
- (NSString *)description {
	return [NSString stringWithFormat:@"<MusicContainer %p; title = \"%@\"; identifier = \"%@\">", self, _title, _identifier];
}

#pragma mark - Memory Management

@end
