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
@property (nonatomic, readonly) SearchResultsViewController * rootResultsViewController;
@end

@interface SearchViewController (Private)
- (void)showLocalMusicLibraryContentMatchingSubstring:(NSString *)substring;
- (void)showRemoveMusicLibraryContentMatchingSubstring:(NSString *)substring;
- (void)showYouTubeContentMatchingSubstring:(NSString *)substring;
- (void)showSoundCloudContentMatchingSubstring:(NSString *)substring;
- (void)updateArtists:(NSArray *)artists albums:(NSArray *)albums songs:(NSArray *)songs youTubes:(NSArray *)youTubes
		  soundClouds:(NSArray *)soundClouds searchString:(NSString *)searchString;
@end

@implementation SearchViewController
@synthesize searchField;
@synthesize currentSearch;

- (SearchResultsViewController *)rootResultsViewController {
	return (SearchResultsViewController *)[navigationController.viewControllers objectAtIndex:0];
}

- (void)viewDidLoad {
	
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	overlayView = [[UIView alloc] initWithFrame:CGRectZero];
	[overlayView setBackgroundColor:[UIColor blackColor]];
	[overlayView setAlpha:0];
	[self.view addSubview:overlayView];
	[overlayView release];
	
	optionsView = [[UIView alloc] initWithFrame:CGRectZero];
	[optionsView setBackgroundColor:[UIColor pm_darkLightColor]];
	[self.view addSubview:optionsView];
	[optionsView release];
	
	SearchResultsViewController * searchResultsViewController = [[SearchResultsViewController alloc] init];
	navigationController = [[UINavigationController alloc] initWithRootViewController:searchResultsViewController];
	[searchResultsViewController release];
	
	[self addChildViewController:navigationController];
	[navigationController release];
	
	[navigationController setNavigationBarHidden:YES];
	[self.view addSubview:navigationController.view];
	[navigationController.view setHidden:YES];
	
	UITapGestureRecognizer * dismissRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
	[overlayView addGestureRecognizer:dismissRecognizer];
	[dismissRecognizer release];
	
	[searchField setDelegate:self];
	[searchField addTarget:self action:@selector(searchFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultsTableViewScrolled:) name:SearchResultsViewControllerScrolledNotificationName object:nil];
	
	shouldResign = NO;
}

- (void)viewDidResizeToNewOrientation {
	[overlayView setFrame:self.view.bounds];
	[navigationController.view setFrame:self.view.bounds];
	[self.rootResultsViewController viewDidResizeToNewOrientation];
}

- (void)viewWasTapped:(UITapGestureRecognizer *)sender {
	shouldResign = YES;
	[searchField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	[UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		[searchField setShadowHidden:NO];
		[overlayView setAlpha:0.5];
	}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	
	[UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		if (shouldResign) [searchField setShadowHidden:YES];
		[overlayView setAlpha:0];
	} completion:^(BOOL finished) {
		if (shouldResign){
			shouldResign = NO;
			[self.view removeFromSuperview];
		}
	}];
}

- (void)resultsTableViewScrolled:(NSNotification *)notification {
	[searchField resignFirstResponder];
}

#pragma mark - SearchField Control Events
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self showContentMatchingSubstring:textField.text];
	if (currentSearch.isNotEmpty) [textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[self showContentMatchingSubstring:nil];
	return YES;
}

- (void)searchFieldTextDidChange:(NSNotification *)notification {
	if (searchField.text.length == 0) [self showContentMatchingSubstring:searchField.text];
}

#pragma mark - Search
- (void)showContentMatchingSubstring:(NSString *)substring {
	
	[self setCurrentSearch:substring];
	[searchField setSpinnerVisible:currentSearch.isNotEmpty];
	[navigationController.view setHidden:!substring.isNotEmpty];
	[navigationController popToRootViewControllerAnimated:NO];
	
	if (currentSearch.isNotEmpty){
		[self.rootResultsViewController setArtists:nil albums:nil songs:nil youTubes:nil soundClouds:nil];
#if !TARGET_IPHONE_SIMULATOR
		[self showLocalMusicLibraryContentMatchingSubstring:currentSearch];
#endif
		[self showRemoveMusicLibraryContentMatchingSubstring:currentSearch];
		[self showSoundCloudContentMatchingSubstring:currentSearch];
		[self showYouTubeContentMatchingSubstring:currentSearch];
	}
}

- (void)showLocalMusicLibraryContentMatchingSubstring:(NSString *)substring {
	
	spinnerCount++;
	dispatch_queue_t searchQueue = dispatch_queue_create("com.partymusic.searchqueue", NULL);
	dispatch_async(searchQueue, ^{
		
		NSArray * artists = /*nil;/*/ [MusicContainer artistsContainingSubstring:substring dictionary:NO];
		NSArray * albums = /*nil;/*/ [MusicContainer albumsContainingSubstring:substring dictionary:NO];
		NSArray * songs = [MusicContainer songsContainingSubstring:substring dictionary:NO];
		dispatch_async(dispatch_get_main_queue(), ^{[self updateArtists:artists albums:albums songs:songs youTubes:nil soundClouds:nil searchString:substring];});
	});
	dispatch_release(searchQueue);
}

- (void)showRemoveMusicLibraryContentMatchingSubstring:(NSString *)substring {
	
	spinnerCount += [[[DevicesManager sharedManager] devices] count];
	[[DevicesManager sharedManager] broadcastSearchRequest:substring callback:^(Device * device, NSDictionary * results){
		dispatch_queue_t processQueue = dispatch_queue_create("com.partymusic.searchqueue", NULL);
		dispatch_async(processQueue, ^{
			
			NSArray * artists = nil;// [MusicContainer containersFromJSONDictionaries:[results objectForKey:kDeviceSearchArtistsKeyName] device:device];
			NSArray * albums = nil;// [MusicContainer containersFromJSONDictionaries:[results objectForKey:kDeviceSearchAlbumsKeyName] device:device];
			NSArray * songs = [MusicContainer containersFromJSONDictionaries:[results objectForKey:kDeviceSearchSongsKeyName] device:device];
			dispatch_async(dispatch_get_main_queue(), ^{[self updateArtists:artists albums:albums songs:songs youTubes:nil soundClouds:nil searchString:substring];});
		});
		dispatch_release(processQueue);
	}];
}

- (void)showYouTubeContentMatchingSubstring:(NSString *)substring {
	
	spinnerCount++;
	[YouTube searchForTracksWithSubstring:substring callback:^(NSError *error, NSArray *tracks) {
		[self updateArtists:[NSArray array] albums:[NSArray array] songs:[NSArray array] youTubes:tracks soundClouds:nil searchString:substring];
	}];
}

- (void)showSoundCloudContentMatchingSubstring:(NSString *)substring {
	
	spinnerCount++;
	[SoundCloud searchForTracksWithSubstring:substring callback:^(NSError *error, NSArray *tracks) {
		[self updateArtists:[NSArray array] albums:[NSArray array] songs:[NSArray array] youTubes:nil soundClouds:tracks searchString:substring];
	}];
}

- (void)updateArtists:(NSArray *)artists albums:(NSArray *)albums songs:(NSArray *)songs youTubes:(NSArray *)youTubes
		  soundClouds:(NSArray *)soundClouds searchString:(NSString *)searchString {
	
	spinnerCount--;
	if (spinnerCount <= 0)
		[searchField setSpinnerVisible:NO];
	
	if ([searchString isEqualToString:currentSearch])
		[self.rootResultsViewController setArtists:artists albums:albums songs:songs youTubes:youTubes soundClouds:soundClouds];
}

#pragma mark - Presentation
- (void)presentAnimatedWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
	
	[overlayView setAlpha:0];
	[UIView animateWithDuration:duration animations:^{
		if (animations) animations();
		[searchField setShadowHidden:NO];
		[overlayView setAlpha:0.5];
	} completion:completion];
}

- (void)dismissAnimatedWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
	
	[navigationController.view setHidden:YES];
	
	[UIView animateWithDuration:duration animations:^{
		if (animations) animations();
		[searchField setShadowHidden:YES];
		[overlayView setAlpha:0];
	} completion:completion];
}

- (void)dealloc {
	[currentSearch release];
	[super dealloc];
}

@end