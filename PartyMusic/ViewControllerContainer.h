//
//  ViewControllerContainer.h
//  PartyMusic
//
//  Created by Tom Irving on 23/03/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "OrientationAwareViewController.h"

@interface ViewControllerContainer : OrientationAwareViewController
- (id)initWithViewController:(UIViewController *)controller dismissHandler:(void(^)(void))handler;
@end
