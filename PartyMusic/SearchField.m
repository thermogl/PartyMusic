//
//  SearchField.m
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "SearchField.h"

@implementation SearchField
@synthesize searchButton;
@synthesize shadowHidden;
@synthesize spinnerVisible;

#pragma mark - Instance Methods
- (id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])){
		
		searchButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[searchButton setImage:[[UIImage imageNamed:@"Search"] imageWithColorOverlay:[UIColor pm_darkColor]] forState:UIControlStateNormal];
		
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
		[spinner setColor:[UIColor pm_darkColor]];
		
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
	shadowHidden = flag;
	[self.layer setShadowOpacity:(flag ? 0 : 1)];
}

- (void)setSpinnerVisible:(BOOL)flag {
	
	spinnerVisible = flag;
	if (spinnerVisible) [spinner startAnimating];
	else [spinner stopAnimating];
	
	[self setLeftView:(spinnerVisible ? spinner : searchButton)];
}

#pragma mark - Dealloc
- (void)dealloc {
	[searchButton release];
	[spinner release];
	[super dealloc];
}

@end