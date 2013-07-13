//
//  ViewControllerContainer.m
//  PartyMusic
//
//  Created by Tom Irving on 23/03/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "ViewControllerContainer.h"

@implementation ViewControllerContainer {
	UIViewController * _viewController;
	UIView * _navigationBar;
	void (^_dismissHandler)();
}

- (id)initWithViewController:(UIViewController *)controller dismissHandler:(void (^)(void))handler {
	
	if ((self = [super init])){
		_viewController = controller;
		[self addChildViewController:controller];
		[self.view addSubview:controller.view];
		
		_dismissHandler = [handler copy];
		
		_navigationBar = [[UIView alloc] init];
		[_navigationBar setBackgroundColor:[UIColor pm_darkColor]];
		[self.view addSubview:_navigationBar];
		
		UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarWasTapped:)];
		[_navigationBar addGestureRecognizer:tapRecognizer];
	}
	
	return self;
}

- (void)viewDidResizeToNewOrientation {
	
	[_navigationBar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 22)];
	[_viewController.view setFrame:CGRectMake(0, CGRectGetHeight(_navigationBar.frame), CGRectGetWidth(_navigationBar.frame),
														  CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_navigationBar.frame))];
}

- (void)navigationBarWasTapped:(UITapGestureRecognizer *)sender {
	if (self.navigationController) [self.navigationController popToRootViewControllerAnimated:YES];
	else [self dismissViewControllerAnimated:YES completion:_dismissHandler];
}


@end
