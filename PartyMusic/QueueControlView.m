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

@implementation QueueControlView {
	UIView * _timeView;
	UIButton * _settingsButton;
	UIActivityIndicatorView * _spinner;
	UIButton * _playPauseButton;
	UIButton * _skipBackwardButton;
	UIButton * _skipForwardButton;
}
@synthesize playerControlsHidden = _playerControlsHidden;
@synthesize shadowHidden = _shadowHidden;
@synthesize queueButton = _queueButton;

- (id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])){
		[self setBackgroundColor:[UIColor pm_darkLightColor]];
		
		[self.layer setShadowColor:[[UIColor pm_darkColor] CGColor]];
		[self.layer setShadowOpacity:0];
		[self.layer setShadowRadius:5];
		[self.layer setMasksToBounds:NO];
		
		_timeView = [[UIView alloc] init];
		[_timeView setBackgroundColor:[UIColor colorWithRed:0.716 green:0.712 blue:0.708 alpha:0.9]];
		[self addSubview:_timeView];
		
		_queueButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self setQueueButtonColor:[UIColor pm_darkColor]];
		[self addSubview:_queueButton];
		
		_spinner = [[UIActivityIndicatorView alloc] init];
		[_spinner setColor:[UIColor pm_darkColor]];
		[_spinner setHidesWhenStopped:YES];
		[self addSubview:_spinner];
		
		_playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_playPauseButton setHidden:YES];
		[_playPauseButton setEnabled:NO];
		[_playPauseButton setImage:[[UIImage imageNamed:@"Play"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		[_playPauseButton addTarget:self action:@selector(playPauseButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_playPauseButton];
		
		_skipBackwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_skipBackwardButton setHidden:YES];
		[_skipBackwardButton setEnabled:NO];
		[_skipBackwardButton setImage:[[UIImage imageNamed:@"SkipBackward"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		[_skipBackwardButton addTarget:self action:@selector(skipBackwardButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_skipBackwardButton];
		
		_skipForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_skipForwardButton setHidden:YES];
		[_skipForwardButton setEnabled:NO];
		[_skipForwardButton setImage:[[UIImage imageNamed:@"SkipForward"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		[_skipForwardButton addTarget:self action:@selector(skipForwardButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_skipForwardButton];
		
		[self setNeedsLayout];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicQueueDidChange:) name:kMusicQueuePlayerDidChangeStateNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicQueueDidChange:) name:kMusicQueuePlayerDidChangeQueueNotificationName object:nil];
	}
	
	return self;
}

- (void)layoutSubviews {
	
	[_timeView setFrame:CGRectMake(0, self.bounds.size.height - 12, self.bounds.size.width, 12)];
	
	CGRect buttonRect = (CGRect){.size = {44, 44}};
	CGFloat buttonCenterY = (self.bounds.size.height - _timeView.bounds.size.height) / 2;
	
	[_queueButton setFrame:buttonRect];
	[_queueButton setCenter:(CGPoint){19, buttonCenterY}];
	
	[_playPauseButton setFrame:buttonRect];
	[_playPauseButton setCenter:(CGPoint){CGRectGetMidX(self.bounds), buttonCenterY}];
	[_spinner setFrame:_playPauseButton.frame];
	
	[_skipBackwardButton setFrame:buttonRect];
	[_skipBackwardButton setCenter:(CGPoint){(_queueButton.center.x + _playPauseButton.center.x) / 2, buttonCenterY}];
	
	[_skipForwardButton setFrame:buttonRect];
	[_skipForwardButton setCenter:(CGPoint){self.bounds.size.width - _skipBackwardButton.center.x, buttonCenterY}];
}

#pragma mark - Property Overrides
- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self setNeedsLayout];
}

- (void)setPlayerControlsHidden:(BOOL)flag {
	_playerControlsHidden = flag;
	[_playPauseButton setHidden:flag];
	[_skipBackwardButton setHidden:flag];
	[_skipForwardButton setHidden:flag];
	
	if (flag) [_spinner stopAnimating];
}

- (void)setShadowHidden:(BOOL)flag {
	_shadowHidden = flag;
	[self.layer setShadowOpacity:(flag ? 0 : 1)];
}

- (void)setQueueButtonColor:(UIColor *)color {
	[_queueButton setImage:[[UIImage imageNamed:@"Queue"] imageWithColorOverlay:color] forState:UIControlStateNormal];
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
	
	AVPlayerPlayStatus playStatus = [[MusicQueueController sharedController] playStatus];
	
	if (!_playerControlsHidden){
		if (playStatus == AVPlayerPlayStatusLoading) [_spinner startAnimating];
		else [_spinner stopAnimating];
		
		[_playPauseButton setHidden:(playStatus == AVPlayerPlayStatusLoading)];
	}
	
	NSString * imageName = (playStatus == AVPlayerPlayStatusPlaying ? @"Pause" : @"Play");
	[_playPauseButton setImage:[[UIImage imageNamed:imageName] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
	
	[_skipBackwardButton setEnabled:[[MusicQueueController sharedController] canSkipBackward]];
	[_skipForwardButton setEnabled:[[MusicQueueController sharedController] canSkipForward]];
	[_playPauseButton setEnabled:(_skipForwardButton.enabled || _skipBackwardButton.enabled || [[MusicQueueController sharedController] currentSong])];
	
	[self setQueueButtonColor:(_playPauseButton.enabled ? [UIColor pm_blueColor] : [UIColor pm_darkColor])];
}

@end
