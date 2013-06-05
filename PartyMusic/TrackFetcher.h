//
//  TrackFetcher.h
//  PartyMusic
//
//  Created by Tom Irving on 28/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TrackFetcherCompletionHandler)();

@interface TrackFetcher : NSObject
@property (nonatomic, copy) TrackFetcherCompletionHandler completionHandler;
@property (nonatomic, assign) BOOL cancelled;

- (void)getTrackDataForPersistentID:(NSNumber *)persistentID callback:(void (^)(NSData * chunk, BOOL moreComing))callback;

@end