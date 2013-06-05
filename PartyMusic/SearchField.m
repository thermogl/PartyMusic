//
//  SearchField.m
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "SearchField.h"

@implementation SearchField {
	UIActivityIndicatorView * _spinner;
	NSInteger _spinnerCount;
}
@synthesize searchButton = _searchButton;
@synthesize shadowHidden = _shadowHidden;
@synthesize spinnerVisible = _spinnerVisible;

#pragma mark - Instance Methods
- (id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])){
		
		_searchButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_searchButton setImage:[[UIImage imageNamed:@"Search"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		
		_spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
		[_spinner setColor:[UIColor pm_darkColor]];
		
		[self setSpinnerVisible:NO];
		
		[self setLeftViewMode:UITextFieldViewModeAlways];
		[self setClearButtonMode:UITextFieldViewModeWhileEditing];
		[self setReturnKeyType:UIReturnKeySearch];
		[self setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self setKeyboardAppearance:UIKeyboardAppearanceAlert];
		
		[self.layer setShadowColor:[[UIColor pm_darkColor] CGColor]];
		[self.layer setShadowOpacity:0];
		[self.layer setShadowRadius:5];
		[self.layer setMasksToBounds:NO];
		
		[self setBackgroundColor:[UIColor pm_darkLightColor]];
		[self setTextColor:[UIColor pm_darkColor]];
		[self setPlaceholder:Localized(@"Artists, Albums, Songs...")];
		[self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
	CGSize imageSize = {18, 44};
	return (CGRect){{10, (bounds.size.height - imageSize.height) / 2}, imageSize};
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	return CGRectInset([super textRectForBounds:bounds], 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

#pragma mark - Property Overrides
- (void)setShadowHidden:(BOOL)flag {
	_shadowHidden = flag;
	[self.layer setShadowOpacity:(flag ? 0 : 1)];
}

- (void)setSpinnerVisible:(BOOL)flag {
	
	_spinnerVisible = flag;
	if (_spinnerVisible) [_spinner startAnimating];
	else [_spinner stopAnimating];
	
	[self setLeftView:(_spinnerVisible ? _spinner : _searchButton)];
}

#pragma mark - Dealloc
- (void)dealloc {
	[_searchButton release];
	[_spinner release];
	[super dealloc];
}

@end