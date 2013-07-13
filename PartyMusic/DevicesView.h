//
//  DevicesView.h
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceView;
@interface DevicesView : UIView
@property (weak, nonatomic, readonly) DeviceView * ownDeviceView;

- (void)addDeviceView:(DeviceView *)deviceView;
- (void)removeDeviceView:(DeviceView *)deviceView;

@end