//
//  SearchResultsViewController.h
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "OrientationAwareViewController.h"

extern NSString * const SearchResultsViewControllerScrolledNotificationName;

@class SearchViewController;
@interface SearchResultsViewController : OrientationAwareTableViewController {
	
	NSMutableArray * artists;
	NSMutableArray * albums;
	NSMutableArray * songs;
	NSMutableArray * youTubes;
	NSMutableArray * soundClouds;
	BOOL hideHeaders;
}

@property (nonatomic, assign) BOOL hideHeaders;

- (void)setArtists:(NSArray *)artists albums:(NSArray *)albums songs:(NSArray *)songs youTubes:(NSArray *)youTubes soundClouds:(NSArray *)soundClouds;

@end

@interface SearchResultsViewControllerContainer : OrientationAwareViewController {
	
	UIView * navigationBar;
	SearchResultsViewController * searchResultsViewController;
}

- (id)initWithSearchResultsViewController:(SearchResultsViewController *)searchViewController;

@end