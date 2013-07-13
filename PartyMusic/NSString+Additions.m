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
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"?=&+",
																kCFStringEncodingUTF8));
}

- (NSString *)encodedURLParameterString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@":/=,!$&'()*+;[]@#?",
																kCFStringEncodingUTF8));
}

- (NSString *)decodedURLString {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""),
																				kCFStringEncodingUTF8));
}

- (NSNumber *)unsignedLongLongNumber {
	return [NSNumber numberWithUnsignedLongLong:strtoull(self.UTF8String, NULL, 0)];
}

+ (NSString *)UT8StringWithBytes:(const char *)bytes length:(NSUInteger)length {
	return bytes ? [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding] : nil;
}

+ (NSString *)UUID {
	
	CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
	CFStringRef UUIDString = CFUUIDCreateString(NULL, UUIDRef);
	CFRelease(UUIDRef);
	
	return (__bridge NSString *)UUIDString;
}

NSString * Localized(NSString * key) {
	return NSLocalizedString(key, @"");
}

NSString * LocalizedFormat(NSString * formatKey, ...) {
	
	va_list args;
    va_start(args, formatKey);
	
    NSString * string = [[NSString alloc] initWithFormat:Localized(formatKey) arguments:args];
    va_end(args);
	
    return string;
}

@end