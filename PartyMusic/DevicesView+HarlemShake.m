//
//  DevicesView+HarlemShake.m
//  PartyMusic
//
//  Created by Tom Irving on 18/03/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "DevicesView+HarlemShake.h"
#import "DeviceView.h"
#import <objc/runtime.h>

NSString * const HarlemPlayerKeyName = @"com.devicesview.harlemplayer";
NSString * const HarlemViewsKeyName = @"com.devicesview.harlemviews";
NSString * const HarlemShakingKeyName = @"com.devicesview.harlemshaking";
NSString * const HarlemCompletionKeyName = @"com.devicesview.harlemcompletion";

typedef enum {
    VLMShakeStyleOne = 0,
    VLMShakeStyleTwo,
    VLMShakeStyleThree,
    VLMShakeStyleEnd
} VLMShakeStyle;

@interface DevicesView () <AVAudioPlayerDelegate>
@property (nonatomic, retain) AVAudioPlayer * harlemPlayer;
@property (nonatomic, retain) NSMutableArray * harlemViews;
@property (nonatomic, assign) BOOL harlemShaking;
@property (nonatomic, copy) void (^harlemCompletion)();
@end

@interface DevicesView (HarlemShakePrivate)
- (void)shakeView:(UIView *)view withShakeStyle:(VLMShakeStyle)style randomSeed:(CGFloat)seed;
- (void)randomlyShakeView:(UIView *)view;
- (CAAnimation *)animationForStyleOneWithSeed:(CGFloat)seed;
- (CAAnimation *)animationForStyleTwoWithSeed:(CGFloat)seed;
- (CAAnimation *)animationForStyleThreeWithSeed:(CGFloat)seed;
@end

@implementation DevicesView (HarlemShake)

- (AVAudioPlayer *)harlemPlayer {
	return objc_getAssociatedObject(self, HarlemPlayerKeyName);
}

- (void)setHarlemPlayer:(AVAudioPlayer *)player {
	objc_setAssociatedObject(self, HarlemPlayerKeyName, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)harlemViews {
	return objc_getAssociatedObject(self, HarlemViewsKeyName);
}

- (void)setHarlemViews:(NSMutableArray *)views {
	objc_setAssociatedObject(self, HarlemViewsKeyName, views, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)harlemShaking {
	NSNumber * number = objc_getAssociatedObject(self, HarlemShakingKeyName);
	return number.boolValue;
}

- (void)setHarlemShaking:(BOOL)flag {
	objc_setAssociatedObject(self, HarlemShakingKeyName, [NSNumber numberWithBool:flag], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)(void))harlemCompletion {
	return objc_getAssociatedObject(self, HarlemCompletionKeyName);
}

- (void)setHarlemCompletion:(void (^)())harlemCompletion {
	objc_setAssociatedObject(self, HarlemCompletionKeyName, harlemCompletion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)harlemShakeWithAudio:(BOOL)withAudio completion:(void (^)(void))completionHandler {
	
	if (!self.harlemShaking){
		[self setHarlemShaking:YES];
		[self setHarlemCompletion:completionHandler];
		
		NSURL * audioURL = [[NSBundle mainBundle] URLForResource:@"HarlemShake" withExtension:@"mp3"];
		AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:NULL];
		[player setDelegate:self];
		[player prepareToPlay];
		[self setHarlemPlayer:player];
		[player release];
		
		if (!withAudio) [player setVolume:0];
		[player play];
		
		[self shakeView:self.ownDeviceView withShakeStyle:VLMShakeStyleThree randomSeed:(arc4random() / (CGFloat)RAND_MAX)];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (15.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			
			NSMutableArray * views = [[NSMutableArray alloc] init];
			[self setHarlemViews:views];
			[views release];
			
			[self.subviews enumerateObjectsUsingBlock:^(DeviceView * deviceView, NSUInteger idx, BOOL *stop) {
				[views addObject:deviceView];
				[self randomlyShakeView:deviceView];
			}];
			
			for (int i = 0; i < 20; i++){
				
				CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
				CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
				CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
				
				DeviceView * deviceView  = [[DeviceView alloc] initWithDevice:nil];
				[deviceView setScreenColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
				[views addObject:deviceView];
				[deviceView release];
				
				[self addSubview:deviceView];
				[self sendSubviewToBack:deviceView];
				
				CGPoint randomCenter = CGPointMake(100 + (arc4random() % (int)self.bounds.size.width - 100), 100 + (arc4random() % (int)self.bounds.size.height - 100));
				[deviceView setRestCenter:randomCenter];
				
				[self randomlyShakeView:deviceView];
			}
		});
	}
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	
    if (flag) {
		
		NSMutableArray * views = self.harlemViews;
		[views enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DeviceView * deviceView, NSUInteger idx, BOOL *stop) {
			if (deviceView.device) [deviceView.layer removeAllAnimations];
			else [deviceView removeFromSuperview];
			[views removeObjectAtIndex:idx];
		}];
		
		[self setHarlemShaking:NO];
		[self setHarlemPlayer:nil];
		[self setHarlemViews:nil];
		
		[self.ownDeviceView.layer removeAllAnimations];
		
		if (self.harlemCompletion) self.harlemCompletion();
    }
}

- (void)randomlyShakeView:(UIView *)view {
	
	[self shakeView:view withShakeStyle:(rand() % VLMShakeStyleEnd) randomSeed:(arc4random() / (CGFloat)RAND_MAX)];
	[self shakeView:view withShakeStyle:(rand() % VLMShakeStyleEnd) randomSeed:(arc4random() / (CGFloat)RAND_MAX)];
}

- (void)shakeView:(UIView *)view withShakeStyle:(VLMShakeStyle)style randomSeed:(CGFloat)seed {
	
    if (style == VLMShakeStyleOne) [view.layer addAnimation:[self animationForStyleOneWithSeed:seed] forKey:@"styleOne"];
	else if (style == VLMShakeStyleTwo) [view.layer addAnimation:[self animationForStyleTwoWithSeed:seed] forKey:@"styleTwo"];
	else if (style == VLMShakeStyleThree) [view.layer addAnimation:[self animationForStyleThreeWithSeed:seed] forKey:@"styleThree"];
}

- (CAAnimation *)animationForStyleOneWithSeed:(CGFloat)seed {
    
    CABasicAnimation * rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	[rotate setFromValue:(seed < 0.5 ? @(M_PI * 2) : @(0))];
	[rotate setToValue:(seed < 0.5 ? @(0) : @(M_PI * 2))];
	[rotate setDuration:(1.0 + seed)];
    
    CABasicAnimation * pop = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	[pop setFromValue:@(1)];
	[pop setToValue:@(1.2)];
	[pop setBeginTime:rotate.duration];
	[pop setDuration:(0.5 + seed)];
	[pop setAutoreverses:YES];
	[pop setRepeatCount:1];
	
	CAAnimationGroup * styleOneGroup = [CAAnimationGroup animation];
	[styleOneGroup setRepeatCount:10];
	[styleOneGroup setAutoreverses:YES];
	[styleOneGroup setDuration:(rotate.duration + pop.duration)];
	[styleOneGroup setAnimations:@[rotate, pop]];
    
    return styleOneGroup;
}

- (CAAnimation *)animationForStyleTwoWithSeed:(CGFloat)seed {
    
	CGFloat negative = (seed < 0.5 ? 0.5 : -0.5);
    
    CATransform3D startingScale = CATransform3DIdentity;
    CATransform3D secondScale = CATransform3DScale(CATransform3DIdentity, 1.0f + (seed * negative), 1.0f + (seed * negative), 1.0f);
    CATransform3D thirdScale = CATransform3DScale(CATransform3DIdentity, 1.0f + (seed * -negative), 1.0f + (seed * -negative), 1.0f);
    CATransform3D finalScale = CATransform3DIdentity;
    
	CAKeyframeAnimation * keyFrameShake = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [keyFrameShake setValues:@[[NSValue valueWithCATransform3D:startingScale],
	 [NSValue valueWithCATransform3D:secondScale],
	 [NSValue valueWithCATransform3D:thirdScale],
	 [NSValue valueWithCATransform3D:finalScale]
	 ]];
    [keyFrameShake setKeyTimes:@[@(0), @(0.4), @(0.7), @(1.0)]];
	[keyFrameShake setTimingFunctions:@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
	 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
	 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
	 ]];
	[keyFrameShake setDuration:(1.0 + seed)];
	[keyFrameShake setRepeatCount:100];
    
    return keyFrameShake;
}

- (CAAnimation *)animationForStyleThreeWithSeed:(CGFloat)seed {
    
    CGFloat negative = (seed < 0.5 ? 1 : -1);
    NSInteger offsetOne = (NSInteger)((10 + 20 * seed) * negative);
    NSInteger offsetTwo = -offsetOne;
    
    NSValue * startingOffset = [NSValue valueWithCGSize:CGSizeZero];
    NSValue * firstOffset = [NSValue valueWithCGSize:CGSizeMake(offsetOne, 0)];
    NSValue * secondOffset = [NSValue valueWithCGSize:CGSizeMake(offsetTwo, 0)];
    NSValue * thirdOffset = [NSValue valueWithCGSize:CGSizeZero];
    NSValue * fourthOffset = [NSValue valueWithCGSize:CGSizeMake(0, offsetOne)];
    NSValue * fifthOffset = [NSValue valueWithCGSize:CGSizeMake(0, offsetTwo)];
    NSValue * finalOffset = [NSValue valueWithCGSize:CGSizeZero];
    
	CAKeyframeAnimation * keyFrameShake = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation"];
    [keyFrameShake setValues:@[startingOffset, firstOffset, secondOffset, thirdOffset, fourthOffset, fifthOffset, finalOffset]];
    [keyFrameShake setKeyTimes:@[@(0), @(0.1), @(0.3), @(0.4), @(0.5), @(0.7), @(0.8), @(1.0)]];
	[keyFrameShake setTimingFunctions:@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
	 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
	 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
	 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
	 ]];
	[keyFrameShake setDuration:(1.0 + seed)];
	[keyFrameShake setRepeatCount:100];
    
    return keyFrameShake;
}

@end
