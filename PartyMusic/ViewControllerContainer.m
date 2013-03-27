//
//  ViewControllerContainer.m
//  PartyMusic
//
//  Created by Tom Irving on 23/03/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "ViewControllerContainer.h"

@implementation ViewControllerContainer

- (id)initWithViewController:(UIViewController *)controller dismissHandler:(void (^)(void))handler {
	
	if ((self = [super init])){
		viewController = controller;
		[self addChildViewController:controller];
		[self.view addSubview:controller.view];
		
		dismissHandler = [handler copy];
		
		navigationBar = [[UIView alloc] init];
		[navigationBar setBackgroundColor:[UIColor pm_darkColor]];
		[self.view addSubview:navigationBar];
		[navigationBar release];
		
		UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarWasTapped:)];
		[navigationBar addGestureRecognizer:tapRecognizer];
		[tapRecognizer release];
	}
	
	return self;
}

- (void)viewDidResizeToNewOrientation {
	
	[navigationBar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 22)];
	[viewController.view setFrame:CGRectMake(0, CGRectGetHeight(navigationBar.frame), CGRectGetWidth(navigationBar.frame),
														  CGRectGetHeight(self.view.bounds) - CGRectGetHeight(navigationBar.frame))];
}

- (void)navigationBarWasTapped:(UITapGestureRecognizer *)sender {
	if (self.navigationController) [self.navigationController popToRootViewControllerAnimated:YES];
	else [self dismissViewControllerAnimated:YES completion:dismissHandler];
}

- (void)dealloc {
	[dismissHandler release];
	[super dealloc];
}

@end
