//
//  UIImage+Additions.h
//  Friendz
//
//  Created by Tom Irving on 12/03/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

@interface UIImage (TIAdditions)

- (id)initWithName:(NSString *)name extension:(NSString *)extension;
+ (UIImage *)imageNamed:(NSString *)name extension:(NSString *)extension;

- (UIImage *)roundCornerImageWithCornerRadius:(CGFloat)radius;
- (UIImage *)recessedRoundCornerImageWithCornerRadius:(CGFloat)radius;

- (UIImage *)imageByAddingInnerShadowWithOffset:(CGSize)offset radius:(CGFloat)radius shadowColor:(UIColor *)shadowColor 
								backgroundColor:(UIColor *)backgroundColor;

- (UIImage *)imageWithColorOverlay:(UIColor *)overlayColor;
- (UIImage *)imageWithGradientOverlayWithTopColor:(UIColor *)color1 bottomColor:(UIColor *)color2;
- (UIImage *)imageWithShadow;
- (UIImage *)imageWithShadowAtOffset:(CGSize)offset;

- (UIImage *)shadowedImageWithColorOverlay:(UIColor *)overlayColor;
- (UIImage *)shadowedImageWithGradientOverlayWithTopColor:(UIColor *)color1 bottomColor:(UIColor *)color2;

@end

