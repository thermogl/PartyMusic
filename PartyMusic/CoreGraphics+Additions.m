//
//  CoreGraphics+Additions.m
//  Friendz
//
//  Created by Tom Irving on 17/02/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "CoreGraphics+Additions.h"

void CGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat radius){
	
	if (radius > 0){
		
		CGFloat minx = CGRectGetMinX(rect);
		CGFloat midx = CGRectGetMidX(rect);
		CGFloat maxx = CGRectGetMaxX(rect);
		CGFloat miny = CGRectGetMinY(rect);
		CGFloat midy = CGRectGetMidY(rect);
		CGFloat maxy = CGRectGetMaxY(rect);
		
		CGContextBeginPath(context);
		CGContextSaveGState(context);
		CGContextMoveToPoint(context, minx, midy);
		CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
		CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
		CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
		CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
		CGContextClosePath(context);
		CGContextRestoreGState(context);
	}
}

CGRect CGRectFromImage(CGImageRef imageRef, CGFloat scale){
	return CGRectMake(0, 0, CGImageGetWidth(imageRef) / scale, CGImageGetHeight(imageRef) / scale);
}

CGContextRef CGBitmapContextCreateFromImage(CGImageRef imageRef, CGSize size, BOOL grayColorSpace, CGFloat scale){
	
	CGFloat imageWidth = size.width;
	CGFloat imageHeight = size.height;
	
	if (CGSizeEqualToSize(size, CGSizeZero)){
		imageWidth = CGImageGetWidth(imageRef) / scale;
		imageHeight = CGImageGetHeight(imageRef) / scale;
	}
	
	CGColorSpaceRef colorSpace = grayColorSpace ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
	CGFloat bitsPerComponent = grayColorSpace ? 8 : CGImageGetBitsPerComponent(imageRef);
	CGFloat bytesPerRow = grayColorSpace ? imageWidth : 0;
	CGBitmapInfo info = grayColorSpace ? 0 : kCGImageAlphaPremultipliedLast;
	
	CGContextRef context = CGBitmapContextCreate(NULL, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, 
												 colorSpace, info);
	CGColorSpaceRelease(colorSpace);
	
	return context;
}

CGImageRef CGImageCreateMaskFromImage(CGImageRef imageRef, BOOL inverted, CGFloat scale){
	
	CGContextRef context = CGBitmapContextCreateFromImage(imageRef, CGSizeZero, YES, scale);
	CGRect imageRect = CGRectFromImage(imageRef, scale);
	
	CGFloat whiteComponents[4] = {1, 1, 1, 1};
	
	CGContextSaveGState(context);
	
	if (inverted) CGContextSetFillColor(context, whiteComponents);
	
	CGContextFillRect(context, imageRect);
	CGContextRestoreGState(context);
	
	if (!inverted) CGContextSetFillColor(context, whiteComponents);
	
	CGContextClipToMask(context, imageRect, imageRef);
	CGContextFillRect(context, imageRect);
	
	CGImageRef newImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	return newImage;	
}

CGImageRef CGImageCreatePadded(CGImageRef imageRef, CGFloat padding, CGFloat scale){
	
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef) / scale, CGImageGetHeight(imageRef) / scale);
	CGSize newSize = imageSize;
	newSize.height += padding * 2;
	newSize.width += padding * 2;
	
	CGContextRef context = CGBitmapContextCreateFromImage(imageRef, newSize, NO, scale);
	
	CGRect imageRect = CGRectMake(padding, padding, imageSize.width, imageSize.height);
	CGContextDrawImage(context, imageRect, imageRef);
	
	CGImageRef newImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	return newImage;
}

CGImageRef CGImageCreateInnerShadow(CGImageRef sourceRef, CGSize offset, CGFloat radius, CGColorRef shadowColor, CGColorRef backgroundColor, CGFloat scale){
	
	CGFloat padding = ceilf(radius);
	CGImageRef paddedRef = CGImageCreatePadded(sourceRef, padding, scale);
	
	CGContextRef context = CGBitmapContextCreateFromImage(paddedRef, CGSizeZero, NO, scale);
	
	CGContextSaveGState(context);
	{
		CGRect imageRect = CGRectFromImage(paddedRef, scale);
		CGContextClipToMask(context, imageRect, paddedRef);
		CGContextSetShadowWithColor(context, offset, radius, shadowColor);
		
		CGContextBeginTransparencyLayer(context, NULL);
		{
			CGImageRef maskRef = CGImageCreateMaskFromImage(paddedRef, YES, scale);
			CGImageRelease(paddedRef);
			
			CGContextClipToMask(context, imageRect, maskRef);
			CGImageRelease(maskRef);
			
			CGContextSetFillColorWithColor(context, backgroundColor);
			CGContextFillRect(context, imageRect);
		}
		
		CGContextEndTransparencyLayer(context);
	}
	CGContextRestoreGState(context);
	
	CGImageRef fromContext = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	CGImageRef newImage = CGImageCreatePadded(fromContext, -padding, scale);
	CGImageRelease(fromContext);
	
	return newImage;
}