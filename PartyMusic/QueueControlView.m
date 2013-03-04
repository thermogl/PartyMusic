//
//  QueueControlView.m
//  PartyMusic
//
//  Created by Tom Irving on 25/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "QueueControlView.h"
#import "DevicesManager.h"
#import "MusicQueueController.h"

@implementation QueueControlView
@synthesize playerControlsHidden;
@synthesize shadowHidden;
@synthesize queueButton;

- (id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])){
		[self setBackgroundColor:[UIColor pm_darkLightColor]];
		
		[self.layer setShadowColor:[[UIColor pm_darkColor] CGColor]];
		[self.layer setShadowOpacity:0];
		[self.layer setShadowRadius:5];
		[self.layer setMasksToBounds:NO];
		
		timeView = [[UIView alloc] init];
		[timeView setBackgroundColor:[UIColor colorWithRed:0.716 green:0.712 blue:0.708 alpha:0.9]];
		[self addSubview:timeView];
		[timeView release];
		
		queueButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self setQueueButtonColor:[UIColor pm_darkColor]];
		[self addSubview:queueButton];
		
		playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[playPauseButton setHidden:YES];
		[playPauseButton setEnabled:NO];
		[playPauseButton setImage:[[UIImage imageNamed:@"Play"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		[playPauseButton addTarget:self action:@selector(playPauseButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:playPauseButton];
		
		skipBackwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[skipBackwardButton setHidden:YES];
		[skipBackwardButton setEnabled:NO];
		[skipBackwardButton setImage:[[UIImage imageNamed:@"SkipBackward"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		[skipBackwardButton addTarget:self action:@selector(skipBackwardButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:skipBackwardButton];
		
		skipForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[skipForwardButton setHidden:YES];
		[skipForwardButton setEnabled:NO];
		[skipForwardButton setImage:[[UIImage imageNamed:@"SkipForward"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		[skipForwardButton addTarget:self action:@selector(skipForwardButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:skipForwardButton];
		
		[self setNeedsLayout];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicQueueDidChange:) name:kMusicQueuePlayerDidChangeStateNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicQueueDidChange:) name:kMusicQueuePlayerDidChangeQueueNotificationName object:nil];
	}
	
	return self;
}

- (void)layoutSubviews {
	
	[timeView setFrame:CGRectMake(0, self.bounds.size.height - 12, self.bounds.size.width, 12)];
	
	CGRect buttonRect = (CGRect){.size = {44, 44}};
	CGFloat buttonCenterY = (self.bounds.size.height - timeView.bounds.size.height) / 2;
	
	[queueButton setFrame:buttonRect];
	[queueButton setCenter:(CGPoint){19, buttonCenterY}];
	
	[playPauseButton setFrame:buttonRect];
	[playPauseButton setCenter:(CGPoint){CGRectGetMidX(self.bounds), buttonCenterY}];
	
	[skipBackwardButton setFrame:buttonRect];
	[skipBackwardButton setCenter:(CGPoint){(queueButton.center.x + playPauseButton.center.x) / 2, buttonCenterY}];
	
	[skipForwardButton setFrame:buttonRect];
	[skipForwardButton setCenter:(CGPoint){self.bounds.size.width - skipBackwardButton.center.x, buttonCenterY}];
}

#pragma mark - Property Overrides
- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self setNeedsLayout];
}

- (void)setPlayerControlsHidden:(BOOL)flag {
	playerControlsHidden = flag;
	[playPauseButton setHidden:flag];
	[skipBackwardButton setHidden:flag];
	[skipForwardButton setHidden:flag];
}

- (void)setShadowHidden:(BOOL)flag {
	shadowHidden = flag;
	[self.layer setShadowOpacity:(flag ? 0 : 1)];
}

- (void)setQueueButtonColor:(UIColor *)color {
	[queueButton setImage:[[UIImage imageNamed:@"Queue"] imageWithColorOverlay:color] forState:UIControlStateNormal];
}

#pragma mark - Button Actions
- (void)playPauseButtonWasTapped:(UIButton *)sender {
	[[MusicQueueController sharedController] togglePlayPause];
}

- (void)skipBackwardButtonWasTapped:(UIButton *)sender {
	[[MusicQueueController sharedController] skipBackward];
}

- (void)skipForwardButtonWasTapped:(UIButton *)sender {
	[[MusicQueueController sharedController] skipForward];
}

#pragma mark - Notification Handlers
- (void)musicQueueDidChange:(NSNotification *)notification {
	
	NSString * imageName = ([[MusicQueueController sharedController] playStatus] == AVPlayerPlayStatusPlaying ? @"Pause" : @"Play");
	[playPauseButton setImage:[[UIImage imageNamed:imageName] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
	
	[skipBackwardButton setEnabled:[[MusicQueueController sharedController] canSkipBackward]];
	[skipForwardButton setEnabled:[[MusicQueueController sharedController] canSkipForward]];
	[playPauseButton setEnabled:(skipForwardButton.enabled || skipBackwardButton.enabled || [[MusicQueueController sharedController] currentSong])];
	
	[self setQueueButtonColor:(playPauseButton.enabled ? [UIColor pm_blueColor] : [UIColor pm_darkColor])];
}

@end
