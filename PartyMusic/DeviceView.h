//
//  DeviceView.h
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "TISpringLoadedView.h"

@class Device;

@interface DeviceView : TISpringLoadedView
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readonly) Device * device;
@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly) CGSize deviceSize;
@property (nonatomic, readonly) CGRect screenRect;
@property (nonatomic, retain) UIColor * screenColor;

- (id)initWithDevice:(Device *)device;
- (void)shake;
- (void)showOutputPrompt;

@end
