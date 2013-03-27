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
		
		[self setScrollEnabled:NO];
		[self setDelaysContentTouches:NO];
		[self setBackgroundColor:[UIColor pm_lightColor]];
		[self setPagingEnabled:YES];
		[self setShowsVerticalScrollIndicator:NO];
		[self setScrollsToTop:NO];
	}
	
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return [touch.view isKindOfClass:[QueueControlView class]] || [touch.view.superview isKindOfClass:[QueueControlView class]];
}

@end
