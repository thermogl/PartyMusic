//
//  DeviceView.m
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "DeviceView.h"
#import "Device.h"
#import "DevicesManager.h"
#import <AudioToolbox/AudioServices.h>
#import "MusicContainer.h"
#import "MusicQueueController.h"

@implementation DeviceView {
	UIImageView * _outputView;
	UIView * _screenView;
}
@synthesize scale = _scale;
@synthesize device = _device;

- (id)initWithDevice:(Device *)aDevice {
	
	if ((self = [super init])){
		
		_device = aDevice;
		_scale = [[UIDevice currentDevice] isPhone] ? 1 : 1.5;
		
		[self setPanDragCoefficient:0.4];
		[self setSpringConstant:550];
		[self setDampingCoefficient:16];
		[self setInheritsPanVelocity:YES];
		
		[self setBounds:(CGRect){.size = self.deviceSize}];
		[self setBackgroundColor:[UIColor pm_darkColor]];
		[self.layer setCornerRadius:5];
		
		_screenView = [[UIView alloc] initWithFrame:self.screenRect];
		[_screenView setBackgroundColor:(_device.isOwnDevice ? [UIColor pm_blueColor] : [UIColor pm_redColor])];
		[self addSubview:_screenView];
		
		_outputView = [[UIImageView alloc] initWithFrame:self.bounds];
		[_outputView setImage:[[UIImage imageNamed:@"Speaker"] imageWithColorOverlay:[UIColor pm_darkColor]]];
		[_outputView setBackgroundColor:[UIColor clearColor]];
		[_outputView setContentMode:UIViewContentModeCenter];
		[_outputView setHidden:!_device.isOutput];
		[self addSubview:_outputView];
		
		if (_device){
			UILongPressGestureRecognizer * longPressRecongizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasLongPressed:)];
			[self addGestureRecognizer:longPressRecongizer];
			
			UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
			[self addGestureRecognizer:tapRecognizer];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveShake:)
														 name:DevicesManagerDidReceiveShakeEventNotificationName object:_device];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveOrientationChange:)
														 name:DevicesManagerDidReceiveOrientationChangeNotificationName object:_device];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveOutputChange:)
														 name:DevicesManagerDidReceiveOutputChangeNotificationName object:_device];
		}
	}
	
	return self;
}

- (void)layoutSubviews {
	[_outputView setFrame:self.bounds];
	[_screenView setFrame:self.screenRect];
}

- (CGFloat)rotation {
	
	CGFloat rotation = 0;
	if (_device.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) rotation = M_PI / 2;
	else if (_device.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) rotation = M_PI;
	else if (_device.interfaceOrientation == UIInterfaceOrientationLandscapeRight) rotation = 3 * M_PI / 2;
	return rotation;
}

- (void)shake {
	
	CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[animation setFromValue:[NSNumber numberWithFloat:(self.rotation - M_PI / 8)]];
	[animation setToValue:[NSNumber numberWithFloat:(self.rotation + M_PI / 8)]];
	[animation setRepeatCount:2];
	[animation setAutoreverses:YES];
	[animation setDuration:0.15];
	[self.layer addAnimation:animation forKey:@"ShakeAnimation"];
}

- (void)showOutputPrompt {
	
	[UIAlertView showWithTitle:@"Become output?" message:nil];
}

#pragma mark - Property Overrides
- (CGSize)deviceSize {
	CGSize baseSize = _device.interfaceIdiom == UIUserInterfaceIdiomPhone ? CGSizeMake(46, 90) : CGSizeMake(73, 95);
	return CGSizeApplyAffineTransform(baseSize, CGAffineTransformMakeScale(_scale, _scale));
}

- (CGRect)screenRect {
	CGRect baseRect = _device.interfaceIdiom == UIUserInterfaceIdiomPhone ? CGRectMake(2, 12, 42, 65) : CGRectMake(5, 9, 63, 78);
	return CGRectApplyAffineTransform(baseRect, CGAffineTransformMakeScale(_scale, _scale));
}

- (void)setScale:(CGFloat)newScale {
	_scale = newScale;
	[self setBounds:(CGRect){.size = self.deviceSize}];
	[self layoutSubviews];
}

- (UIColor *)screenColor {
	return _screenView.backgroundColor;
}

- (void)setScreenColor:(UIColor *)screenColor {
	[_screenView setBackgroundColor:screenColor];
}

#pragma mark - Gesture Handlers
- (void)viewWasTapped:(UITapGestureRecognizer *)sender {
	
	NSMutableArray * items = [NSMutableArray array];
	
	UIMenuItem * browseItem = [[UIMenuItem alloc] initWithTitle:@"Browse Library" action:@selector(browseLibraryMenuItemWasTapped:)];
	[items addObject:browseItem];
	
	if (_device.isOwnDevice){
		if (!_device.isOutput){
			UIMenuItem * menuItem = [[UIMenuItem alloc] initWithTitle:@"Become Output" action:@selector(becomeOutputMenuItemWasTapped:)];
			[items addObject:menuItem];
		}
	}
	else
	{
		UIMenuItem * nudgeItem = [[UIMenuItem alloc] initWithTitle:@"Nudge" action:@selector(vibrateDeviceMenuItemWasTapped:)];
		[items addObject:nudgeItem];
	}
	
	if (items){
		UIMenuController * menuController = [UIMenuController sharedMenuController];
		[menuController setTargetRect:CGRectMake(CGRectGetMidX(self.bounds), 0, 1, 1) inView:self];
		[menuController setMenuItems:items];
		[self becomeFirstResponder];
		[menuController setMenuVisible:YES animated:YES];
	}
	
}

- (void)viewWasLongPressed:(UILongPressGestureRecognizer *)sender {
	
	if (sender.state == UIGestureRecognizerStateBegan){
		
		[self shake];
		
		if (_device.isOwnDevice) [[DevicesManager sharedManager] broadcastAction:DeviceActionShake];
		else [_device sendAction:DeviceActionShake];
	}
}

#pragma mark - UIMenuController stuff
- (void)browseLibraryMenuItemWasTapped:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:DevicesManagerDidReceiveHarlemNotificationName object:nil];
}

- (void)becomeOutputMenuItemWasTapped:(id)sender {
	[[[DevicesManager sharedManager] ownDevice] setIsOutput:YES];
	[[MusicQueueController sharedController] play];
}

- (void)vibrateDeviceMenuItemWasTapped:(id)sender {
	[_device sendAction:DeviceActionVibrate];
}

#pragma mark - Responder Chain
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	return (action == @selector(browseLibraryMenuItemWasTapped:) ||
			action == @selector(becomeOutputMenuItemWasTapped:) ||
			action == @selector(vibrateDeviceMenuItemWasTapped:));
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark Device Notifications
- (void)deviceDidReceiveShake:(NSNotification *)notification {
	[self shake];
}

- (void)deviceDidReceiveOrientationChange:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^{[self setTransform:CGAffineTransformMakeRotation(self.rotation)];}];
}

- (void)deviceDidReceiveOutputChange:(NSNotification *)notification {
	[_outputView setHidden:!_device.isOutput];
}

#pragma mark - Dealloc

@end
