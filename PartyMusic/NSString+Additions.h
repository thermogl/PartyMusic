//
//  NSString+Additions.h
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
@property (nonatomic, readonly) BOOL isNotEmpty;
@property (nonatomic, readonly) NSString * encodedURLString;
@property (nonatomic, readonly) NSString * encodedURLParameterString;
@property (nonatomic, readonly) NSString * decodedURLString;

- (BOOL)contains:(NSString *)string;

+ (NSString *)UT8StringWithBytes:(const char *)bytes length:(NSUInteger)length;
+ (NSString *)UUID;

NSString * Localized(NSString * key);
NSString * LocalizedFormat(NSString * formatKey, ...);
@end