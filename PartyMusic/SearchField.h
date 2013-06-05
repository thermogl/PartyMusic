//
//  SearchField.h
//  PartyMusic
//
//  Created by Tom Irving on 12/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchField : UITextField
@property (nonatomic, readonly) UIButton * searchButton;
@property (nonatomic, assign) BOOL shadowHidden;
@property (nonatomic, assign) BOOL spinnerVisible;
@end
