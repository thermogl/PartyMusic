//
//  TrackFetcher.m
//  PartyMusic
//
//  Created by Tom Irving on 28/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "TrackFetcher.h"

@implementation TrackFetcher
@synthesize completionHandler;
@synthesize cancelled;

- (void)getTrackDataForPersistentID:(NSNumber *)persistentID callback:(void (^)(NSData *, BOOL))callback {
	
	if (persistentID && callback){
		
		dispatch_queue_t fetchQueue = dispatch_queue_create("com.partymusic.fetchtrackdata", NULL);
		dispatch_async(fetchQueue, ^{
			
			MPMediaPropertyPredicate * predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID.stringValue.unsignedLongLongValue
																					forProperty:MPMediaItemPropertyPersistentID];
			
			MPMediaQuery * songsQuery = [[MPMediaQuery alloc] init];
			[songsQuery addFilterPredicate:predicate];
			
			MPMediaItem * item = (songsQuery.items.count ? [songsQuery.items objectAtIndex:0] : nil);
			NSURL * assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
			AVURLAsset * songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
			
			if (songAsset){
				
				NSError * error = nil;
				AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
				
				AVAssetTrack * songTrack = [songAsset.tracks objectAtIndex:0];
				AVAssetReaderTrackOutput * output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:nil];
				[reader addOutput:output];
				[output release];
				
				[reader startReading];
				while (reader.status == AVAssetReaderStatusReading){
					
					if (!cancelled){
						
						AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
						CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
						
						if (sampleBufferRef){
							
							CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
							size_t length = CMBlockBufferGetDataLength(blockBufferRef);
							if (length > 0){
								
								NSMutableData * data = [[NSMutableData alloc] initWithCapacity:length];
								CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
								dispatch_async(dispatch_get_main_queue(), ^{callback(data, YES);});
								[data release];
							}
							
							CMSampleBufferInvalidate(sampleBufferRef);
							CFRelease(sampleBufferRef);
						}
					}
					else [reader cancelReading];
				}
				
				if (cancelled || reader.status == AVAssetReaderStatusCompleted) dispatch_async(dispatch_get_main_queue(), ^{callback(nil, NO);});
				else if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown) NSLog(@"Track getting error: %@", error);
				
				[reader release];
			}
			else dispatch_async(dispatch_get_main_queue(), ^{callback(nil, NO);});
			
			[songsQuery release];
			
			if (completionHandler) dispatch_async(dispatch_get_main_queue(), ^{completionHandler();});
		});
		
		dispatch_release(fetchQueue);
	}
}

- (void)dealloc {
	[completionHandler release];
	[super dealloc];
}

@end