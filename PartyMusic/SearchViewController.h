//
//  SearchViewController.h
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "OrientationAwareViewController.h"

@class SearchResultsViewController, SearchField;
@interface SearchViewController : OrientationAwareViewController <UITextFieldDelegate> {
	
	SearchField * searchField;
	SearchResultsViewController * searchResultsViewController;
	
	NSString * currentSearch;
	NSInteger spinnerCount;
	
	UIView * overlayView;
	UIView * optionsView;
	
	BOOL shouldResign;
}

@property (nonatomic, assign) SearchField * searchField;

@end
