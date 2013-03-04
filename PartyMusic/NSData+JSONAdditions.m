//
//  NSData+JSONAdditions.m
//  PartyMusic
//
//  Created by Tom Irving on 19/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "NSData+JSONAdditions.h"

@implementation NSData (JSONAdditions)

- (id)JSONValue {
	return [NSJSONSerialization JSONObjectWithData:self options:0 error:NULL];
}

@end
