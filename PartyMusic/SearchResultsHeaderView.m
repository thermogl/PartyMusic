//
//  SearchResultsHeaderView.m
//  PartyMusic
//
//  Created by Tom Irving on 17/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "SearchResultsHeaderView.h"

@interface SearchResultsHeaderView ()
@property (nonatomic, copy) NSString * title;
@end

@implementation SearchResultsHeaderView
@synthesize title = _title;

- (void)setTitle:(NSString *)newTitle {
	_title = [newTitle copy];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
	[[UIColor pm_darkerLightColor] set];
	UIRectFill(rect);
	
	CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 1), 1, [[UIColor pm_darkColor] CGColor]);
	
	[[UIColor pm_lightColor] set];
	[_title drawInRect:CGRectInset(rect, 5, 0) withFont:[UIFont boldSystemFontOfSize:16]];
}

+ (SearchResultsHeaderView *)headerViewWithTitle:(NSString *)title {
	
	SearchResultsHeaderView * headerView = [[SearchResultsHeaderView alloc] init];
	[headerView setBackgroundColor:[UIColor clearColor]];
	[headerView setTitle:title];
	return headerView;
}


@end
