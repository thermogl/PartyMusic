//
//  UIColor+Theming.m
//  PartyMusic
//
//  Created by Tom Irving on 27/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "UIColor+Theming.h"

@implementation UIColor (Theming)

+ (UIColor *)pm_blueColor {
	return [UIColor colorWithRed:0.110 green:0.643 blue:0.988 alpha:1];
}

+ (UIColor *)pm_redColor {
	return [UIColor colorWithRed:0.988 green:0.271 blue:0.216 alpha:1];
}

+ (UIColor *)pm_lightColor {
	return [UIColor colorWithRed:0.941 green:0.937 blue:0.925 alpha:1];
}

+ (UIColor *)pm_darkLightColor {
	return [UIColor colorWithRed:0.863 green:0.859 blue:0.847 alpha:1];
}

+ (UIColor *)pm_darkerLightColor {
	return [UIColor colorWithRed:0.716 green:0.712 blue:0.7 alpha:0.9];
}

+ (UIColor *)pm_darkColor {
	return [UIColor colorWithRed:0.192 green:0.188 blue:0.176 alpha:1];
}

@end