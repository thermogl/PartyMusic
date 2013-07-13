//
//  SoundCloud.m
//  PartyMusic
//
//  Created by Tom Irving on 17/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "SoundCloud.h"
#import "MusicContainer.h"
#import "DevicesManager.h"

NSString * const kSoundCloudAPIEndpoint = @"https://api.soundcloud.com";
NSString * const kSoundCloudClientID = @"0cc97e216c56a543c3eca3cb370fba8c";

@implementation SoundCloud

+ (void)searchForTracksWithSubstring:(NSString *)substring callback:(void (^)(NSError * error, NSArray * tracks))callback {
	
	if (callback){
		
		NSString * APISearchString = [NSString stringWithFormat:@"q=%@&filter=streamable&client_id=%@", substring.encodedURLParameterString, kSoundCloudClientID];
		NSURL * URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tracks.json?%@", kSoundCloudAPIEndpoint, APISearchString]];
		
		NSURLRequest * request = [NSURLRequest requestWithURL:URL];
		NSOperationQueue * queue = [[NSOperationQueue alloc] init];
		
		[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data, NSError * err){
			
			NSMutableArray * tracks = [NSMutableArray array];
			
			if (!err){
				
				NSArray * trackDicts = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
				[trackDicts enumerateObjectsUsingBlock:^(NSDictionary * trackDict, NSUInteger idx, BOOL *stop) {
					
					MusicContainer * musicContainer = [[MusicContainer alloc] init];
					[musicContainer setType:MusicContainerTypeSong];
					[musicContainer	setSongType:DeviceSongTypeSoundCloud];
					[musicContainer setTitle:[trackDict objectForKey:@"title"]];
					[musicContainer setSubtitle:[[trackDict objectForKey:@"user"] objectForKey:@"username"]];
					[musicContainer setDevice:[[DevicesManager sharedManager] ownDevice]];
					[musicContainer setIdentifier:[trackDict objectForKey:@"stream_url"]];
					[tracks addObject:musicContainer];
				}];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{callback(err, tracks);});
		}];
	}
}

+ (NSURL *)trackURLTaggedWithClientID:(NSString *)trackURL {
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@", trackURL, kSoundCloudClientID]];
}

@end
