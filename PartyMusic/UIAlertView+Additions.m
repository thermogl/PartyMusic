//
//  UIAlertView+Additions.m
//  Friendz
//
//  Created by Tom Irving on 20/08/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "UIAlertView+Additions.h"
#import <objc/runtime.h>

static NSString * BLOCK_KEY = @"com.thermoglobalnuclearwar.alertviewblockkey";

@implementation UIAlertView (TIAdditions)

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle 
  actionButtonTitle:(NSString *)actionButtonTitle block:(UIAlertViewBlock)block {
	
	if ((self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:actionButtonTitle, nil])){
		objc_setAssociatedObject(self, (__bridge const void *)(BLOCK_KEY), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
	}
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	UIAlertViewBlock block = objc_getAssociatedObject(self, (__bridge const void *)(BLOCK_KEY));
	if (block && buttonIndex != alertView.cancelButtonIndex) block();
	
	objc_setAssociatedObject(self, (__bridge const void *)(BLOCK_KEY), nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
	
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message {
	
	UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil 
											   cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

+ (void)showForError:(NSError *)error {
	
	if (error){
		NSString * message = [[NSString alloc] initWithFormat:@"%@ (%d)", error.localizedDescription, error.code];
		[self showWithTitle:@"Error" message:message];
	}
}

@end
