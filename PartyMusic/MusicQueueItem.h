//
//  MusicQueueItem.h
//  PartyMusic
//
//  Created by Tom Irving on 18/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "Device.h"

@interface MusicQueueItem : NSObject
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, copy) id songIdentifier;
@property (nonatomic, assign) DeviceSongType type;
@property (nonatomic, copy) NSString * deviceUUID;
@property (nonatomic, assign) CMTime currentTime;
@property (nonatomic, readonly) NSDictionary * JSONDictionary;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary;

@end