//
//  UIAlertView+Additions.h
//  Friendz
//
//  Created by Tom Irving on 20/08/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

@interface UIAlertView (TIAdditions)

typedef void (^UIAlertViewBlock)(void);

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle 
   actionButtonTitle:(NSString *)actionButtonTitle block:(UIAlertViewBlock)block;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showForError:(NSError *)error;

@end
