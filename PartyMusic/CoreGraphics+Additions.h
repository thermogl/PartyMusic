//
//  CoreGraphics+Additions.h
//  Friendz
//
//  Created by Tom Irving on 17/02/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import <Foundation/Foundation.h>

void CGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat radius);

CGRect CGRectFromImage(CGImageRef imageRef, CGFloat scale);
CGContextRef CGBitmapContextCreateFromImage(CGImageRef imageRef, CGSize size, BOOL grayColorSpace, CGFloat scale);
CGImageRef CGImageCreateMaskFromImage(CGImageRef imageRef, BOOL inverted, CGFloat scale);
CGImageRef CGImageCreatePadded(CGImageRef imageRef, CGFloat padding, CGFloat scale);
CGImageRef CGImageCreateInnerShadow(CGImageRef sourceRef, CGSize offset, CGFloat radius, CGColorRef shadowColor, CGColorRef backgroundColor, CGFloat scale);