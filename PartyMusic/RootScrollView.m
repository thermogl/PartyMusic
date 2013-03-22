//
//  RootScrollView.m
//  PartyMusic
//
//  Created by Tom Irving on 22/03/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "RootScrollView.h"
#import "QueueControlView.h"

@implementation RootScrollView

- (id)initWithFrame:(CGRect)frame {
	
	if ((self =	[super initWithFrame:frame])){
		
		[self setBackgroundColor:[UIColor pm_lightColor]];
		[self setDelaysContentTouches:NO];
		[self setPagingEnabled:YES];
		[self setShowsVerticalScrollIndicator:NO];
	}
	
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return [touch.view isKindOfClass:[QueueControlView class]] || [touch.view isKindOfClass:[UIButton class]];
}

@end
