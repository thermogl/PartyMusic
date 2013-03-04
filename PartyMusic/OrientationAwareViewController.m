//
//  OrientationAwareViewController.m
//  Friendz
//
//  Created by Tom Irving on 05/11/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "OrientationAwareViewController.h"

@implementation OrientationAwareViewController

- (void)viewWillAppear:(BOOL)animated {
	[self viewDidResizeToNewOrientation];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[self viewDidResizeToNewOrientation];
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [[UIDevice currentDevice] shouldRotateToOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self viewDidResizeToNewOrientation];}];
}

- (void)viewDidResizeToNewOrientation {
	// Subclass implements this.
	// Everything inside here that can be animated (frame, etc), will be.
}

@end

@implementation OrientationAwareTableViewController

- (void)viewWillAppear:(BOOL)animated {
	[self viewDidResizeToNewOrientation];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[self viewDidResizeToNewOrientation];
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [[UIDevice currentDevice] shouldRotateToOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self viewDidResizeToNewOrientation];}];
}

- (void)viewDidResizeToNewOrientation {
	// Subclass implements this.
	// Everything inside here that can be animated (frame, etc), will be.
}


@end
