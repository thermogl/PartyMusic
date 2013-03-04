//
//  UIImage+Additions.m
//  Friendz
//
//  Created by Tom Irving on 12/03/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "UIImage+Additions.h"
#import "CoreGraphics+Additions.h"

#define kInnerShadowColor [[UIColor blackColor] colorWithAlphaComponent:0.5]
#define kWhiteDropShadowColor [[UIColor whiteColor] colorWithAlphaComponent:0.5]

@implementation UIImage (TIAdditions)

- (id)initWithName:(NSString *)name extension:(NSString *)extension {
	
	if (!extension) extension = @"png";
	
	NSString * scaledName = (([[UIScreen mainScreen] scale] == 2) ? [name stringByAppendingString:@"@2x"] : name);
	NSString * path = [[NSBundle mainBundle] pathForResource:scaledName ofType:extension];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
		path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
	}
	
	return [self initWithContentsOfFile:path];
}

+ (UIImage *)imageNamed:(NSString *)name extension:(NSString *)extension {
	return [[[self alloc] initWithName:name extension:extension] autorelease];
}

- (UIImage *)roundCornerImageWithCornerRadius:(CGFloat)radius {
	
	CGImageRef imageRef = self.CGImage;
	CGContextRef context = CGBitmapContextCreateFromImage(imageRef, CGSizeZero, NO, self.scale);
	CGRect imageRect = CGRectFromImage(imageRef, self.scale);
	
	CGContextAddRoundedRect(context, imageRect, radius);
	CGContextClip(context);
	CGContextDrawImage(context, imageRect, imageRef);
	
	CGImageRef newImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage * finalImage = [UIImage imageWithCGImage:newImage];
	CGImageRelease(newImage);
	
	return finalImage;
}

- (UIImage *)recessedRoundCornerImageWithCornerRadius:(CGFloat)radius {
	
	UIImage * roundCornerImage = [self roundCornerImageWithCornerRadius:radius];
	UIImage * innerShadowImage = [roundCornerImage imageByAddingInnerShadowWithOffset:CGSizeMake(0, -2) radius:3 
																		  shadowColor:kInnerShadowColor backgroundColor:[UIColor whiteColor]];
	
	CGImageRef imageRef = innerShadowImage.CGImage;
	CGContextRef context = CGBitmapContextCreateFromImage(imageRef, CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef) + 1), NO, self.scale);
	
	CGRect imageRect = CGRectFromImage(imageRef, self.scale);
	imageRect.origin.y += 1;
	
	CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [kWhiteDropShadowColor CGColor]);
	CGContextDrawImage(context, imageRect, imageRef);
	
	CGImageRef newImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage * finalImage = [UIImage imageWithCGImage:newImage];
	CGImageRelease(newImage);
	
	return finalImage;
}

- (UIImage *)imageByAddingInnerShadowWithOffset:(CGSize)offset radius:(CGFloat)radius shadowColor:(UIColor *)shadowColor 
								backgroundColor:(UIColor *)backgroundColor {
	
	CGImageRef imageRef = self.CGImage;
	CGContextRef context = CGBitmapContextCreateFromImage(imageRef, CGSizeZero, NO, self.scale);
	CGRect imageRect = CGRectFromImage(imageRef, self.scale);
	
	CGContextDrawImage(context, imageRect, imageRef);
	
	CGImageRef shadowRef = CGImageCreateInnerShadow(imageRef, offset, radius, shadowColor.CGColor, backgroundColor.CGColor, self.scale);
	CGContextDrawImage(context, imageRect, shadowRef);
	CGImageRelease(shadowRef);
	
	CGImageRef newImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage * finalImage = [UIImage imageWithCGImage:newImage];
	CGImageRelease(newImage);
	
	return finalImage;
}

- (UIImage *)innerShadowWithOffset:(CGSize)offset radius:(CGFloat)radius shadowColor:(UIColor *)shadowColor backgroundColor:(UIColor *)backgroundColor {
	
	CGFloat padding = ceilf(radius);
	CGImageRef paddedRef = CGImageCreatePadded(self.CGImage, padding, self.scale);
	
	CGContextRef context = CGBitmapContextCreateFromImage(paddedRef, CGSizeZero, NO, self.scale);
	
	CGContextSaveGState(context);
	{
		CGRect imageRect = CGRectFromImage(paddedRef, self.scale);
		CGContextClipToMask(context, imageRect, paddedRef);
		CGContextSetShadowWithColor(context, offset, radius, shadowColor.CGColor);
		
		CGContextBeginTransparencyLayer(context, NULL);
		{
			CGImageRef maskRef = CGImageCreateMaskFromImage(paddedRef, YES, self.scale);
			CGImageRelease(paddedRef);
			
			CGContextClipToMask(context, imageRect, maskRef);
			CGImageRelease(maskRef);
			
			CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
			CGContextFillRect(context, imageRect);
		}
		
		CGContextEndTransparencyLayer(context);
	}
	CGContextRestoreGState(context);
	
	CGImageRef fromContext = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	CGImageRef newImage = CGImageCreatePadded(fromContext, -padding, self.scale);
	CGImageRelease(fromContext);
	
	UIImage * finalImage = [UIImage imageWithCGImage:newImage];
	CGImageRelease(newImage);
	
	return finalImage;
}

- (UIImage *)imageWithColorOverlay:(UIColor *)overlayColor {
	return [self imageWithGradientOverlayWithTopColor:overlayColor bottomColor:nil];
}

- (UIImage *)imageWithGradientOverlayWithTopColor:(UIColor *)color1 bottomColor:(UIColor *)color2 {
	
	UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1, -1);
	
	CGRect imageRect = CGRectFromImage(self.CGImage, self.scale);
	CGContextClipToMask(context, imageRect, self.CGImage);
	
	if (color1 && color2){
		
		CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
		
		NSArray * colors = [NSArray arrayWithObjects:(id)[color2 CGColor], (id)[color1 CGColor], nil];	
    
		CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, NULL);
		CGColorSpaceRelease(space);
	
		CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, self.size.height), 0);
		CGGradientRelease(gradient);
	}
	else
	{
		CGContextSetFillColorWithColor(context, color1.CGColor);
		CGContextFillRect(context, imageRect);
	}
	
	UIImage * overlayedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return overlayedImage;
}

- (UIImage *)imageWithShadow {
	return [self imageWithShadowAtOffset:CGSizeMake(0, 1)];
}

- (UIImage *)imageWithShadowAtOffset:(CGSize)offset {
	
	CGFloat imageHeight = self.size.height;
	CGFloat imageWidth = self.size.width;
	
	CGFloat newHeight = imageHeight + offset.height + (offset.height == 0 ? 1 : 4);
	CGFloat newWidth = imageWidth + offset.width + (offset.width == 0 ? 1 : 4);
	
	CGSize newImageSize = CGSizeMake(newWidth, newHeight);
	UIGraphicsBeginImageContextWithOptions(newImageSize, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGColorRef shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
	CGContextSetShadowWithColor(context, offset, 5, shadowColor);
	[self drawInRect:CGRectMake(1, 1, imageWidth, imageHeight)];
	
	UIImage * shadowedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return shadowedImage;
}

- (UIImage *)shadowedImageWithColorOverlay:(UIColor *)overlayColor {
	return [[self imageWithColorOverlay:overlayColor] imageWithShadow];
}

- (UIImage *)shadowedImageWithGradientOverlayWithTopColor:(UIColor *)color1 bottomColor:(UIColor *)color2 {
	return [[self imageWithGradientOverlayWithTopColor:color1 bottomColor:color2] imageWithShadow];
}

@end
