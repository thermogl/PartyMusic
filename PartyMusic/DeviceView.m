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

@implementation DeviceView
@synthesize scale;
@synthesize device;

- (id)initWithDevice:(Device *)aDevice {
	
	if ((self = [super init])){
		
		device = [aDevice retain];
		
		scale = [[UIDevice currentDevice] isPhone] ? 1 : 1.5;
		[self setPanDragCoefficient:0.4];
		[self setSpringConstant:550];
		[self setDampingCoefficient:16];
		[self setInheritsPanVelocity:YES];
		
		[self setBounds:(CGRect){.size = self.deviceSize}];
		[self setBackgroundColor:[UIColor pm_darkColor]];
		[self.layer setCornerRadius:5];
		
		screenView = [[UIView alloc] initWithFrame:self.screenRect];
		[screenView setBackgroundColor:(device.isOwnDevice ? [UIColor pm_blueColor] : [UIColor pm_redColor])];
		[self addSubview:screenView];
		[screenView release];
		
		outputView = [[UIImageView alloc] initWithFrame:self.bounds];
		[outputView setImage:[[UIImage imageNamed:@"Speaker"] imageWithColorOverlay:[UIColor pm_darkColor]]];
		[outputView setBackgroundColor:[UIColor clearColor]];
		[outputView setContentMode:UIViewContentModeCenter];
		[outputView setHidden:!device.isOutput];
		[self addSubview:outputView];
		[outputView release];
		
		if (device){
			UILongPressGestureRecognizer * longPressRecongizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasLongPressed:)];
			[self addGestureRecognizer:longPressRecongizer];
			[longPressRecongizer release];
			
			UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
			[self addGestureRecognizer:tapRecognizer];
			[tapRecognizer release];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveShake:)
														 name:DevicesManagerDidReceiveShakeEventNotificationName object:device];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveOrientationChange:)
														 name:DevicesManagerDidReceiveOrientationChangeNotificationName object:device];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveOutputChange:)
														 name:DevicesManagerDidReceiveOutputChangeNotificationName object:device];
		}
	}
	
	return self;
}

- (void)layoutSubviews {
	[outputView setFrame:self.bounds];
	[screenView setFrame:self.screenRect];
}

- (CGFloat)rotation {
	
	CGFloat rotation = 0;
	if (device.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) rotation = M_PI / 2;
	else if (device.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) rotation = M_PI;
	else if (device.interfaceOrientation == UIInterfaceOrientationLandscapeRight) rotation = 3 * M_PI / 2;
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
	velocity = CGPointMake(0, -800);
}

#pragma mark - Property Overrides
- (CGSize)deviceSize {
	CGSize baseSize = device.interfaceIdiom == UIUserInterfaceIdiomPhone ? CGSizeMake(46, 90) : CGSizeMake(73, 95);
	return CGSizeApplyAffineTransform(baseSize, CGAffineTransformMakeScale(scale, scale));
}

- (CGRect)screenRect {
	CGRect baseRect = device.interfaceIdiom == UIUserInterfaceIdiomPhone ? CGRectMake(2, 12, 42, 65) : CGRectMake(5, 9, 63, 78);
	return CGRectApplyAffineTransform(baseRect, CGAffineTransformMakeScale(scale, scale));
}

- (void)setScale:(CGFloat)newScale {
	scale = newScale;
	[self setBounds:(CGRect){.size = self.deviceSize}];
	[self layoutSubviews];
}

- (UIColor *)screenColor {
	return screenView.backgroundColor;
}

- (void)setScreenColor:(UIColor *)screenColor {
	[screenView setBackgroundColor:screenColor];
}

#pragma mark - Gesture Handlers
- (void)viewWasTapped:(UITapGestureRecognizer *)sender {
	
	NSMutableArray * items = [[NSMutableArray alloc] init];
	
	UIMenuItem * browseItem = [[UIMenuItem alloc] initWithTitle:@"Browse Library" action:@selector(browseLibraryMenuItemWasTapped:)];
	[items addObject:browseItem];
	[browseItem release];
	
	if (device.isOwnDevice){
		if (!device.isOutput){
			UIMenuItem * menuItem = [[UIMenuItem alloc] initWithTitle:@"Become Output" action:@selector(becomeOutputMenuItemWasTapped:)];
			[items addObject:menuItem];
			[menuItem release];
		}
	}
	else
	{
		UIMenuItem * nudgeItem = [[UIMenuItem alloc] initWithTitle:@"Nudge" action:@selector(vibrateDeviceMenuItemWasTapped:)];
		[items addObject:nudgeItem];
		[nudgeItem release];
	}
	
	if (items){
		UIMenuController * menuController = [UIMenuController sharedMenuController];
		[menuController setTargetRect:CGRectMake(CGRectGetMidX(self.bounds), 0, 1, 1) inView:self];
		[menuController setMenuItems:items];
		[self becomeFirstResponder];
		[menuController setMenuVisible:YES animated:YES];
	}
	
	[items release];
}

- (void)viewWasLongPressed:(UILongPressGestureRecognizer *)sender {
	
	if (sender.state == UIGestureRecognizerStateBegan){
		
		[self shake];
		
		if (device.isOwnDevice) [[DevicesManager sharedManager] broadcastAction:DeviceActionShake];
		else [device sendAction:DeviceActionShake];
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
	[device sendAction:DeviceActionVibrate];
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
	[outputView setHidden:!device.isOutput];
}

#pragma mark - Dealloc
- (void)dealloc {
	[device release];
	[super dealloc];
}

@end
