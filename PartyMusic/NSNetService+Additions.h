//
//  NSNetService+Additions.h
//  PartyMusic
//
//  Created by Tom Irving on 14/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;

@interface NSNetService (Additions)
@property (nonatomic, readonly) NSString * host;
@property (nonatomic, retain) NSDictionary * TXTRecordDictionary;
- (BOOL)hasSameHostAsSocket:(GCDAsyncSocket *)socket;
@end