//
//  NSString+Additions.m
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)contains:(NSString *)string {
	return (string && [self rangeOfString:string].location != NSNotFound);
}

- (BOOL)isNotEmpty {
	return (self && [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0);
}

- (NSString *)encodedURLString {
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"?=&+",
																kCFStringEncodingUTF8) autorelease];
}

- (NSString *)encodedURLParameterString {
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@":/=,!$&'()*+;[]@#?",
																kCFStringEncodingUTF8) autorelease];
}

- (NSString *)decodedURLString {
	return [(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""),
																				kCFStringEncodingUTF8) autorelease];
}

+ (NSString *)UT8StringWithBytes:(const char *)bytes length:(NSUInteger)length {
	return bytes ? [[[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding] autorelease] : nil;
}

+ (NSString *)UUID {
	
	CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
	CFStringRef UUIDString = CFUUIDCreateString(NULL, UUIDRef);
	CFRelease(UUIDRef);
	
	return [(NSString *)UUIDString autorelease];
}

NSString * Localized(NSString * key) {
	return NSLocalizedString(key, @"");
}

NSString * LocalizedFormat(NSString * formatKey, ...) {
	
	va_list args;
    va_start(args, formatKey);
	
    NSString * string = [[[NSString alloc] initWithFormat:Localized(formatKey) arguments:args] autorelease];
    va_end(args);
	
    return string;
}

@end