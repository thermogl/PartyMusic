//
//  DevicesView.m
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "DevicesView.h"
#import "DeviceView.h"
#import "Device.h"

@interface DevicesView (Private) <AVAudioPlayerDelegate>
- (void)calculateDeviceViewCentersWithCallback:(void (^)(DeviceView * deviceView, CGPoint center, CGFloat scale))callback;
@end

@implementation DevicesView {
	CADisplayLink * _displayLink;
}

- (id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])){
		
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:(id)kCFRunLoopCommonModes];
		
		[self setBackgroundColor:[UIColor pm_lightColor]];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
	[self setNeedsLayout];
}

- (DeviceView *)ownDeviceView {
	return (DeviceView *)[self.subviews objectAtIndex:0];
}

- (void)displayLinkTick:(CADisplayLink *)sender {
	[self.subviews enumerateObjectsUsingBlock:^(DeviceView * deviceView, NSUInteger idx, BOOL *stop){
		[deviceView simulateSpringWithDisplayLink:sender];
	}];
}

- (void)addDeviceView:(DeviceView *)deviceView {
	[self addSubview:deviceView];
	[deviceView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
	[self setNeedsLayout];
}

- (void)removeDeviceView:(DeviceView *)deviceView {
	[deviceView removeFromSuperview];
	[self setNeedsLayout];
}

- (void)calculateDeviceViewCentersWithCallback:(void (^)(DeviceView * deviceView, CGPoint center, CGFloat scale))callback {
	
	if (callback){
		CGFloat scale = [[UIDevice currentDevice] isPhone] ? 1 : 1.5;
		CGFloat padding = (self.subviews.count < 2 ? 100 : (self.subviews.count < 4 ? 75 : 50));
		CGFloat circleRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2 - padding * scale;
		if (self.subviews.count < 2) circleRadius = 0;
		
		CGFloat increments = M_PI * 2 / self.subviews.count;
		__block CGFloat currentAngle = -M_PI / 2;
		
		[self.subviews enumerateObjectsUsingBlock:^(DeviceView * deviceView, NSUInteger idx, BOOL *stop) {
			
			CGPoint restCenter = CGPointMake(circleRadius * cosf(currentAngle), circleRadius * sinf(currentAngle));
			restCenter.x += self.bounds.size.width / 2;
			restCenter.y += self.bounds.size.height / 2;
			currentAngle += increments;
			
			callback(deviceView, restCenter, scale);
		}];
	}
}

- (void)layoutSubviews {
	
	[self calculateDeviceViewCentersWithCallback:^(DeviceView *deviceView, CGPoint center, CGFloat scale) {
		if (deviceView.device){
			[deviceView setRestCenter:center];
			[deviceView setTransform:CGAffineTransformMakeRotation(deviceView.rotation)];
		}
	}];
}

@end
