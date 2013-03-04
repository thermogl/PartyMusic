//
//  YouTube.h
//  PartyMusic
//
//  Created by Tom Irving on 17/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YouTube : NSObject
+ (void)searchForTracksWithSubstring:(NSString *)substring callback:(void (^)(NSError * error, NSArray * tracks))callback;
+ (void)getTrackURLFromVideoID:(NSString *)videoID callback:(void (^)(NSURL * URL))callback;
@end