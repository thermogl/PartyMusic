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

@implementation MusicContainer
@synthesize type;
@synthesize songType;
@synthesize identifier;
@synthesize title;
@synthesize subtitle;
@synthesize device;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary {
	
	if ((self = [super init])){
		type = [[dictionary objectForKey:kDictionaryTypeKey] integerValue];
		songType = [[dictionary objectForKey:kDictionarySongTypeKey] integerValue];
		identifier = [[dictionary objectForKey:kDictionaryIdentifierKey] copy];
		title = [[dictionary objectForKey:kDictionaryTitleKey] copy];
		subtitle = [[dictionary objectForKey:kDictionarySubtitleKey] copy];
	}
	
	return self;
}

- (NSDictionary *)JSONDictionary {
	return (@{kDictionaryTypeKey : [NSNumber numberWithInteger:type],
			kDictionarySongTypeKey : [NSNumber numberWithInteger:songType],
			kDictionaryIdentifierKey : identifier,
			kDictionaryTitleKey : (title ?: @""),
			kDictionarySubtitleKey : (subtitle ?: @"")});
}

+ (NSArray *)artistsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary {
	
	if (substring){
		MPMediaQuery * artistsQuery = [MPMediaQuery artistsQuery];
		[artistsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:substring forProperty:MPMediaItemPropertyArtist
																	   comparisonType:MPMediaPredicateComparisonContains]];
		
		NSMutableArray * containers = [[NSMutableArray alloc] init];
		[artistsQuery.collections enumerateObjectsUsingBlock:^(MPMediaItemCollection * collection, NSUInteger idx, BOOL *stop) {
			
			MusicContainer * container = [[MusicContainer alloc] init];
			[container setIdentifier:[collection.representativeItem valueForProperty:MPMediaItemPropertyArtistPersistentID]];
			[container setTitle:[collection.representativeItem valueForProperty:MPMediaItemPropertyArtist]];
			[container setType:MusicContainerTypeArtist];
			[container setDevice:[[DevicesManager sharedManager] ownDevice]];
			[containers addObject:(dictionary ? container.JSONDictionary : container)];
			[container release];
		}];
		
		return [containers autorelease];
	}
	
	return [NSArray array];
}

+ (NSArray *)albumsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary {
	
	if (substring){
		
		MPMediaQuery * albumsQuery = [MPMediaQuery albumsQuery];
		[albumsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:substring forProperty:MPMediaItemPropertyAlbumTitle
																	  comparisonType:MPMediaPredicateComparisonContains]];
		NSMutableArray * containers = [[NSMutableArray alloc] init];
		[albumsQuery.collections enumerateObjectsUsingBlock:^(MPMediaItemCollection * collection, NSUInteger idx, BOOL *stop) {
			
			MusicContainer * container = [[MusicContainer alloc] init];
			[container setIdentifier:[collection.representativeItem valueForProperty:MPMediaItemPropertyAlbumPersistentID]];
			[container setTitle:[collection.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle]];
			[container setType:MusicContainerTypeAlbum];
			[container setDevice:[[DevicesManager sharedManager] ownDevice]];
			[containers addObject:(dictionary ? container.JSONDictionary : container)];
			[container release];
		}];
		
		return [containers autorelease];
	}
	
	return [NSArray array];
}

+ (NSArray *)songsContainingSubstring:(NSString *)substring dictionary:(BOOL)dictionary {
	
	if (substring){
		
		MPMediaQuery * songsQuery = [MPMediaQuery songsQuery];
		[songsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:substring forProperty:MPMediaItemPropertyTitle
																	 comparisonType:MPMediaPredicateComparisonContains]];
		NSMutableArray * containers = [[NSMutableArray alloc] init];
		[songsQuery.items enumerateObjectsUsingBlock:^(MPMediaItem * item, NSUInteger idx, BOOL *stop) {
			
			if ([item valueForProperty:MPMediaItemPropertyAssetURL]){
				
				MusicContainer * container = [[MusicContainer alloc] init];
				[container setIdentifier:[item valueForProperty:MPMediaItemPropertyPersistentID]];
				[container setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
				[container setSubtitle:[item valueForProperty:MPMediaItemPropertyAlbumArtist]];
				[container setType:MusicContainerTypeSong];
				[container setDevice:[[DevicesManager sharedManager] ownDevice]];
				[containers addObject:(dictionary ? container.JSONDictionary : container)];
				[container release];
			}
		}];
		
		return [containers autorelease];
	}
	
	return [NSArray array];
}

+ (NSArray *)containersFromJSONDictionaries:(NSArray *)jsonDictionaries device:(Device *)device {
	
	NSMutableArray * containers = [[NSMutableArray alloc] init];
	[jsonDictionaries enumerateObjectsUsingBlock:^(NSDictionary * dict, NSUInteger idx, BOOL *stop) {
		MusicContainer * container = [[MusicContainer alloc] initWithJSONDictionary:dict];
		[container setDevice:device];
		[containers addObject:container];
		[container release];
	}];
	
	return [containers autorelease];
}

- (void)dealloc {
	[identifier release];
	[title release];
	[super dealloc];
}

@end
