//
//  SearchViewController.h
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "OrientationAwareViewController.h"

typedef NS_OPTIONS(NSUInteger, SearchSources){
	SearchSourceLocalLibrary = 1 << 0,
	SearchSourceRemoteLibraries = 1 << 1,
	SearchSourceYouTube = 1 << 2,
	SearchSourceSoundCloud = 1 << 3,
};

@class SearchResultsViewController, SearchField;
@interface SearchViewController : OrientationAwareViewController <UITextFieldDelegate> {
	
	SearchSources searchSources;
	SearchField * searchField;
	UINavigationController * navigationController;
	
	NSString * currentSearch;
	NSInteger spinnerCount;
	
	UIView * overlayView;
	UIView * optionsView;
	
	BOOL shouldResign;
}

@property (nonatomic, assign) SearchSources searchSources;
@property (nonatomic, assign) SearchField * searchField;

@end
