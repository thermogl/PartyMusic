//
//  SearchViewController.m
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "SearchField.h"
#import "MusicContainer.h"
#import "DevicesManager.h"
#import "SoundCloud.h"
#import "YouTube.h"

@interface SearchViewController ()
@property (nonatomic, copy) NSString * currentSearch;
@property (weak, nonatomic, readonly) SearchResultsViewController * rootResultsViewController;
@end

@interface SearchViewController (Private)
- (void)showLocalMusicLibraryContentMatchingSubstring:(NSString *)substring;
- (void)showRemoveMusicLibraryContentMatchingSubstring:(NSString *)substring;
- (void)showYouTubeContentMatchingSubstring:(NSString *)substring;
- (void)showSoundCloudContentMatchingSubstring:(NSString *)substring;
- (void)updateArtists:(NSArray *)artists albums:(NSArray *)albums songs:(NSArray *)songs youTubes:(NSArray *)youTubes
		  soundClouds:(NSArray *)soundClouds searchString:(NSString *)searchString;
@end

@implementation SearchViewController {
	
	UINavigationController * _navigationController;
	NSInteger _spinnerCount;
	
	UIView * _overlayView;
	UIView * _optionsView;
	
	BOOL _shouldResign;
}
@synthesize searchSources = _searchSources;
@synthesize searchField = _searchField;
@synthesize currentSearch = _currentSearch;

- (id)init {
	
	if ((self = [super init])){
		_searchSources = (SearchSourceLocalLibrary | SearchSourceRemoteLibraries | SearchSourceYouTube | SearchSourceSoundCloud);
	}
	
	return self;
}

- (SearchResultsViewController *)rootResultsViewController {
	return (SearchResultsViewController *)[_navigationController.viewControllers objectAtIndex:0];
}

- (void)viewDidLoad {
	
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	_overlayView = [[UIView alloc] initWithFrame:CGRectZero];
	[_overlayView setBackgroundColor:[UIColor blackColor]];
	[_overlayView setAlpha:0];
	[self.view addSubview:_overlayView];
	
	_optionsView = [[UIView alloc] initWithFrame:CGRectZero];
	[_optionsView setBackgroundColor:[UIColor pm_darkLightColor]];
	[self.view addSubview:_optionsView];
	
	SearchResultsViewController * searchResultsViewController = [[SearchResultsViewController alloc] init];
	_navigationController = [[UINavigationController alloc] initWithRootViewController:searchResultsViewController];
	
	[self addChildViewController:_navigationController];
	
	[_navigationController setNavigationBarHidden:YES];
	[self.view addSubview:_navigationController.view];
	[_navigationController.view setHidden:YES];
	
	UITapGestureRecognizer * dismissRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
	[_overlayView addGestureRecognizer:dismissRecognizer];
	
	[_searchField setDelegate:self];
	[_searchField addTarget:self action:@selector(searchFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultsTableViewScrolled:) name:SearchResultsViewControllerScrolledNotificationName object:nil];
	
	_shouldResign = NO;
}

- (void)viewDidResizeToNewOrientation {
	[_overlayView setFrame:self.view.bounds];
	[_navigationController.view setFrame:self.view.bounds];
	[self.rootResultsViewController viewDidResizeToNewOrientation];
}

- (void)viewWasTapped:(UITapGestureRecognizer *)sender {
	_shouldResign = YES;
	[_searchField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	[UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		[_searchField setShadowHidden:NO];
		[_overlayView setAlpha:0.5];
	}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	
	[UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		if (_shouldResign) [_searchField setShadowHidden:YES];
		[_overlayView setAlpha:0];
	} completion:^(BOOL finished) {
		if (_shouldResign){
			_shouldResign = NO;
			[self.view removeFromSuperview];
		}
	}];
}

- (void)resultsTableViewScrolled:(NSNotification *)notification {
	[_searchField resignFirstResponder];
}

#pragma mark - SearchField Control Events
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self showContentMatchingSubstring:textField.text];
	if (_currentSearch.isNotEmpty) [textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[self showContentMatchingSubstring:nil];
	return YES;
}

- (void)searchFieldTextDidChange:(NSNotification *)notification {
	if (_searchField.text.length == 0) [self showContentMatchingSubstring:_searchField.text];
}

#pragma mark - Search
- (void)showContentMatchingSubstring:(NSString *)substring {
	
	[self setCurrentSearch:substring];
	[_searchField setSpinnerVisible:_currentSearch.isNotEmpty];
	[_navigationController.view setHidden:!substring.isNotEmpty];
	[_navigationController popToRootViewControllerAnimated:NO];
	
	if (_currentSearch.isNotEmpty){
		[self.rootResultsViewController setArtists:nil albums:nil songs:nil youTubes:nil soundClouds:nil];
#if !TARGET_IPHONE_SIMULATOR
		if (_searchSources & SearchSourceLocalLibrary) [self showLocalMusicLibraryContentMatchingSubstring:_currentSearch];
#endif
		if (_searchSources & SearchSourceRemoteLibraries) [self showRemoveMusicLibraryContentMatchingSubstring:_currentSearch];
		if (_searchSources & SearchSourceYouTube) [self showYouTubeContentMatchingSubstring:_currentSearch];
		if (_searchSources & SearchSourceSoundCloud) [self showSoundCloudContentMatchingSubstring:_currentSearch];
	}
}

- (void)showLocalMusicLibraryContentMatchingSubstring:(NSString *)substring {
	
	_spinnerCount++;
	dispatch_queue_t searchQueue = dispatch_queue_create("com.partymusic.searchqueue", NULL);
	dispatch_async(searchQueue, ^{
		
		NSArray * artists = [MusicContainer artistsContainingSubstring:substring dictionary:NO];
		NSArray * albums = [MusicContainer albumsContainingSubstring:substring dictionary:NO];
		NSArray * songs = [MusicContainer songsContainingSubstring:substring dictionary:NO];
		dispatch_async(dispatch_get_main_queue(), ^{[self updateArtists:artists albums:albums songs:songs youTubes:nil soundClouds:nil searchString:substring];});
	});
	dispatch_release(searchQueue);
}

- (void)showRemoveMusicLibraryContentMatchingSubstring:(NSString *)substring {
	
	_spinnerCount += [[[DevicesManager sharedManager] devices] count];
	[[DevicesManager sharedManager] broadcastSearchRequest:substring callback:^(Device * device, NSDictionary * results){
		dispatch_queue_t processQueue = dispatch_queue_create("com.partymusic.searchqueue", NULL);
		dispatch_async(processQueue, ^{
			
			NSArray * artists = [MusicContainer containersFromJSONDictionaries:[results objectForKey:kDeviceSearchArtistsKeyName] device:device];
			NSArray * albums = [MusicContainer containersFromJSONDictionaries:[results objectForKey:kDeviceSearchAlbumsKeyName] device:device];
			NSArray * songs = [MusicContainer containersFromJSONDictionaries:[results objectForKey:kDeviceSearchSongsKeyName] device:device];
			dispatch_async(dispatch_get_main_queue(), ^{[self updateArtists:artists albums:albums songs:songs youTubes:nil soundClouds:nil searchString:substring];});
		});
		dispatch_release(processQueue);
	}];
}

- (void)showYouTubeContentMatchingSubstring:(NSString *)substring {
	
	_spinnerCount++;
	[YouTube searchForTracksWithSubstring:substring callback:^(NSError *error, NSArray *tracks) {
		[self updateArtists:[NSArray array] albums:[NSArray array] songs:[NSArray array] youTubes:tracks soundClouds:nil searchString:substring];
	}];
}

- (void)showSoundCloudContentMatchingSubstring:(NSString *)substring {
	
	_spinnerCount++;
	[SoundCloud searchForTracksWithSubstring:substring callback:^(NSError *error, NSArray *tracks) {
		[self updateArtists:[NSArray array] albums:[NSArray array] songs:[NSArray array] youTubes:nil soundClouds:tracks searchString:substring];
	}];
}

- (void)updateArtists:(NSArray *)artists albums:(NSArray *)albums songs:(NSArray *)songs youTubes:(NSArray *)youTubes
		  soundClouds:(NSArray *)soundClouds searchString:(NSString *)searchString {
	
	_spinnerCount--;
	if (_spinnerCount <= 0)
		[_searchField setSpinnerVisible:NO];
	
	if ([searchString isEqualToString:_currentSearch])
		[self.rootResultsViewController setArtists:artists albums:albums songs:songs youTubes:youTubes soundClouds:soundClouds];
}

#pragma mark - Presentation
- (void)presentAnimatedWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
	
	[_overlayView setAlpha:0];
	[UIView animateWithDuration:duration animations:^{
		if (animations) animations();
		[_searchField setShadowHidden:NO];
		[_overlayView setAlpha:0.5];
	} completion:completion];
}

- (void)dismissAnimatedWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
	
	[_navigationController.view setHidden:YES];
	
	[UIView animateWithDuration:duration animations:^{
		if (animations) animations();
		[_searchField setShadowHidden:YES];
		[_overlayView setAlpha:0];
	} completion:completion];
}


@end