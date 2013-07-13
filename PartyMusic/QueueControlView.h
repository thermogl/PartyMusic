//
//  QueueControlView.h
//  PartyMusic
//
//  Created by Tom Irving on 25/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueueControlView : UIView
@property (nonatomic, assign) BOOL playerControlsHidden;
@property (nonatomic, assign) BOOL shadowHidden;
@property (weak, nonatomic, readonly) UIButton * queueButton;

- (void)setQueueButtonColor:(UIColor *)color;

@end
