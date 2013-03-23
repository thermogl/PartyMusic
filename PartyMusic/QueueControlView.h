//
//  QueueControlView.h
//  PartyMusic
//
//  Created by Tom Irving on 25/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueueControlView : UIView {
	
	UIView * timeView;
	
	UIButton * queueButton;
	UIButton * settingsButton;
	
	UIActivityIndicatorView * spinner;
	UIButton * playPauseButton;
	UIButton * skipBackwardButton;
	UIButton * skipForwardButton;
	
	BOOL playerControlsHidden;
	BOOL shadowHidden;
}

@property (nonatomic, assign) BOOL playerControlsHidden;
@property (nonatomic, assign) BOOL shadowHidden;
@property (nonatomic, readonly) UIButton * queueButton;

- (void)setQueueButtonColor:(UIColor *)color;

@end
