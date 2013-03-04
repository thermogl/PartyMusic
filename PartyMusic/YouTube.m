//
//  YouTube.m
//  PartyMusic
//
//  Created by Tom Irving on 17/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "YouTube.h"
#import "MusicContainer.h"
#import "DevicesManager.h"

NSString * const kYouTubeAPIEndpoint = @"http://gdata.youtube.com/feeds/api/videos/?alt=json&format=1,6&category=Music&";
NSString * const kYouTubeInfoURL = @"http://www.youtube.com/get_video_info?video_id=";
NSString * const kYouTubeUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4";


@interface NSString (QueryString)
- (NSMutableDictionary *)dictionaryFromQueryStringComponents;
@end

@implementation YouTube

+ (void)searchForTracksWithSubstring:(NSString *)substring callback:(void (^)(NSError * error, NSArray * tracks))callback {
	
	if (callback){
		NSURL * URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@", kYouTubeAPIEndpoint, substring.encodedURLParameterString]];
		
		NSURLRequest * request = [NSURLRequest requestWithURL:URL];
		NSOperationQueue * queue = [[[NSOperationQueue alloc] init] autorelease];
		
		[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data, NSError * err){
			
			NSMutableArray * tracks = [[NSMutableArray alloc] init];
			
			if (!err){
				
				NSDictionary * resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
				NSDictionary * feedDictionary = [resultsDictionary objectForKey:@"feed"];
				NSArray * videos = [feedDictionary objectForKey:@"entry"];
				[videos enumerateObjectsUsingBlock:^(NSDictionary * videoDict, NSUInteger idx, BOOL *stop) {
					
					MusicContainer * container = [[MusicContainer alloc] init];
					[container setType:MusicContainerTypeSong];
					[container setSongType:DeviceSongTypeYouTube];
					[container setDevice:[[DevicesManager sharedManager] ownDevice]];
					[container setTitle:[[videoDict objectForKey:@"title"] objectForKey:@"$t"]];
					[container setSubtitle:[[[[videoDict objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"]];
					[container setIdentifier:[[[videoDict objectForKey:@"id"] objectForKey:@"$t"] lastPathComponent]];
					[tracks addObject:container];
					[container release];
				}];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{callback(err, tracks);});
			[tracks autorelease];
		}];
	}
}

+ (void)getH264videosWithYoutubeID:(NSString *)youtubeID callback:(void (^)(NSDictionary * results))callback {
	
    if (youtubeID && callback){
		
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kYouTubeInfoURL, youtubeID]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:kYouTubeUserAgent forHTTPHeaderField:@"User-Agent"];
        [request setHTTPMethod:@"GET"];
		
		NSOperationQueue * queue = [[[NSOperationQueue alloc] init] autorelease];
		[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response , NSData * responseData, NSError * error) {
			
			if (!error) {
				
				NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
				NSMutableDictionary * parts = [responseString dictionaryFromQueryStringComponents];
				[responseString release];
				
				if (parts) {
					
					NSString *fmtStreamMapString = [[parts objectForKey:@"url_encoded_fmt_stream_map"] objectAtIndex:0];
					NSArray *fmtStreamMapArray = [fmtStreamMapString componentsSeparatedByString:@","];
					
					NSMutableDictionary *videoDictionary = [NSMutableDictionary dictionary];
					
					for (NSString *videoEncodedString in fmtStreamMapArray) {
						NSMutableDictionary *videoComponents = [videoEncodedString dictionaryFromQueryStringComponents];
						NSString *type = [[[videoComponents objectForKey:@"type"] objectAtIndex:0] decodedURLString];
						NSString *signature = nil;
						if ([videoComponents objectForKey:@"sig"]) {
							signature = [[videoComponents objectForKey:@"sig"] objectAtIndex:0];
						}
						
						if ([type rangeOfString:@"mp4"].length > 0) {
							NSString * url = [[[videoComponents objectForKey:@"url"] objectAtIndex:0] decodedURLString];
							url = [NSString stringWithFormat:@"%@&signature=%@", url, signature];
							
							NSString *quality = [[[videoComponents objectForKey:@"quality"] objectAtIndex:0] decodedURLString];
							[videoDictionary setObject:url forKey:quality];
						}
					}
					
					dispatch_async(dispatch_get_main_queue(), ^{callback(videoDictionary);});
				}
			}
		}];
	}
}

+ (void)getTrackURLFromVideoID:(NSString *)videoID callback:(void (^)(NSURL * URL))callback {
	
	if (callback){
		[self getH264videosWithYoutubeID:videoID callback:^(NSDictionary *results) {
			
			NSURL * URL = (results.allKeys.count ? [NSURL URLWithString:[results objectForKey:[results.allKeys objectAtIndex:0]]] : nil);
			callback(URL);
		}];
	}
}

@end

@implementation NSString (QueryString)

- (NSMutableDictionary *)dictionaryFromQueryStringComponents {
	
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
	
	[[self componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString * keyValue, NSUInteger idx, BOOL *stop) {
		
		NSArray * keyValueArray = [keyValue componentsSeparatedByString:@"="];
        if (keyValueArray.count > 1){
			
			NSString * key = [[keyValueArray objectAtIndex:0] decodedURLString];
			NSString * value = [[keyValueArray objectAtIndex:1] decodedURLString];
			
			NSMutableArray * results = [parameters objectForKey:key];
			
			if (!results){
				results = [NSMutableArray arrayWithCapacity:1];
				[parameters setObject:results forKey:key];
			}
			
			[results addObject:value];
		}
	}];
	
    return [parameters autorelease];
}

@end