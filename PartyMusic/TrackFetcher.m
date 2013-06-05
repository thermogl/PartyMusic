//
//  TrackFetcher.m
//  PartyMusic
//
//  Created by Tom Irving on 28/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "TrackFetcher.h"

@implementation TrackFetcher
@synthesize completionHandler = _completionHandler;
@synthesize cancelled = _cancelled;

- (void)getTrackDataForPersistentID:(NSNumber *)persistentID callback:(void (^)(NSData *, BOOL))callback {
	
	if (persistentID && callback){
		
		dispatch_queue_t fetchQueue = dispatch_queue_create("com.partymusic.fetchtrackdata", NULL);
		dispatch_async(fetchQueue, ^{
			
			MPMediaPropertyPredicate * predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID.stringValue.unsignedLongLongNumber
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
				[output setAlwaysCopiesSampleData:NO];
				
				[reader addOutput:output];
				[output release];
				
				[reader startReading];
				while (reader.status == AVAssetReaderStatusReading){
					
					if (!_cancelled){
						
						CMSampleBufferRef sampleBufferRef = [output copyNextSampleBuffer];
						if (sampleBufferRef){
							
							CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
							size_t length = CMBlockBufferGetDataLength(blockBufferRef);
							if (length > 0){
								
								NSMutableData * buffer = [[NSMutableData alloc] initWithLength:length];
								CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, buffer.mutableBytes);
								dispatch_async(dispatch_get_main_queue(), ^{callback(buffer, YES);});
								[buffer release];
							}
							
							CMSampleBufferInvalidate(sampleBufferRef);
							CFRelease(sampleBufferRef);
						}
					}
					else [reader cancelReading];
				}
				
				if (_cancelled || reader.status == AVAssetReaderStatusCompleted) dispatch_async(dispatch_get_main_queue(), ^{callback(nil, NO);});
				else if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown) NSLog(@"Track getting error: %@", error);
				
				[reader release];
			}
			else dispatch_async(dispatch_get_main_queue(), ^{callback(nil, NO);});
			
			[songsQuery release];
			
			if (_completionHandler) dispatch_async(dispatch_get_main_queue(), ^{_completionHandler();});
		});
		
		dispatch_release(fetchQueue);
	}
}

- (void)dealloc {
	[_completionHandler release];
	[super dealloc];
}

@end