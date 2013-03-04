//
//  NSNetService+Additions.m
//  PartyMusic
//
//  Created by Tom Irving on 14/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "NSNetService+Additions.h"
#import "GCDAsyncSocket.h"
#include <arpa/inet.h>

@implementation NSNetService (Additions)
- (NSString *)host {
	
	struct sockaddr_in * socketAddress = (struct sockaddr_in *)[[self.addresses objectAtIndex:0] bytes];
	return [NSString stringWithFormat:@"%s", inet_ntoa(socketAddress->sin_addr)];
}

- (NSDictionary *)TXTRecordDictionary {
	
	NSMutableDictionary * friendlyDict = [[NSMutableDictionary alloc] init];
	NSDictionary * TXTRecord = [NSNetService dictionaryFromTXTRecordData:self.TXTRecordData];
	
	for (id key in TXTRecord){
		NSString * stringRep = [[NSString alloc] initWithData:[TXTRecord objectForKey:key]
													 encoding:NSUTF8StringEncoding];
		[friendlyDict setObject:stringRep forKey:key];
		[stringRep release];
	}
	
	return [friendlyDict autorelease];
}

- (void)setTXTRecordDictionary:(NSDictionary *)TXTRecordDictionary {
	[self setTXTRecordData:[NSNetService dataFromTXTRecordDictionary:TXTRecordDictionary]];
}

- (BOOL)hasSameHostAsSocket:(GCDAsyncSocket *)socket {
	return [self.host isEqualToString:socket.connectedHost];
}

@end
