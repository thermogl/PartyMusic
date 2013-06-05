//
//  SearchResultsViewController.m
//  PartyMusic
//
//  Created by Tom Irving on 15/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "MusicContainer.h"
#import "DevicesManager.h"
#import "SearchResultsHeaderView.h"
#import "YouTube.h"
#import "SearchViewController.h"
#import "SearchField.h"
#import "MusicQueueItem.h"

NSString * const SearchResultsViewControllerScrolledNotificationName = @"SearchResultsViewControllerScrolledNotificationName";

@interface SearchResultsViewController (Private)
- (MusicContainer *)containerForIndexPath:(NSIndexPath *)indexPath;
@end

@implementation SearchResultsViewController {
	NSMutableArray * _artists;
	NSMutableArray * _albums;
	NSMutableArray * _songs;
	NSMutableArray * _youTubes;
	NSMutableArray * _soundClouds;
}
@synthesize hideHeaders = _hideHeaders;

#pragma mark - Property Overrides
- (void)setHideHeaders:(BOOL)flag {
	_hideHeaders = flag;
	[self.tableView reloadData];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
	
    [super viewDidLoad];
	[self.tableView setBackgroundColor:[UIColor pm_lightColor]];
	[self.tableView setSeparatorColor:[UIColor pm_darkLightColor]];
	
	_artists = [[NSMutableArray alloc] init];
	_albums = [[NSMutableArray alloc] init];
	_songs = [[NSMutableArray alloc] init];
	_youTubes = [[NSMutableArray alloc] init];
	_soundClouds = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceControllerDidRemoveDevice:) name:DevicesManagerDidRemoveDeviceNotificationName object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[NSNotificationCenter defaultCenter] postNotificationName:SearchResultsViewControllerScrolledNotificationName object:nil];
}

- (void)deviceControllerDidRemoveDevice:(NSNotification *)notification {
	
	Device * removedDevice = [notification.object retain];
	[_artists enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MusicContainer * container, NSUInteger idx, BOOL *stop) {
		if ([container.device isEqual:removedDevice]) [_artists removeObjectAtIndex:idx];
	}];
	
	[_albums enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MusicContainer * container, NSUInteger idx, BOOL *stop) {
		if ([container.device isEqual:removedDevice]) [_albums removeObjectAtIndex:idx];
	}];
	
	[_songs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MusicContainer * container, NSUInteger idx, BOOL *stop) {
		if ([container.device isEqual:removedDevice]) [_songs removeObjectAtIndex:idx];
	}];
	
	[removedDevice release];
	[self.tableView reloadData];
}

- (MusicContainer *)containerForIndexPath:(NSIndexPath *)indexPath {
	
	MusicContainer * container = nil;
	if (indexPath.section == 0) container = [_artists objectAtIndex:indexPath.row];
	else if (indexPath.section == 1) container = [_albums objectAtIndex:indexPath.row];
	else if (indexPath.section == 2) container = [_songs objectAtIndex:indexPath.row];
	else if (indexPath.section == 3) container = [_youTubes objectAtIndex:indexPath.row];
	else if (indexPath.section == 4) container = [_soundClouds objectAtIndex:indexPath.row];
	return container;
}

#pragma mark - Property Overrides
- (void)setArtists:(NSArray *)newArtists albums:(NSArray *)newAlbums songs:(NSArray *)newSongs youTubes:(NSArray *)newYouTubes soundClouds:(NSArray *)newSoundClouds {
	
	if (!newArtists) [_artists removeAllObjects];
	else [_artists addObjectsFromArray:newArtists];
	
	if (!newAlbums) [_albums removeAllObjects];
	else [_albums addObjectsFromArray:newAlbums];
	
	if (!newSongs) [_songs removeAllObjects];
	else [_songs addObjectsFromArray:newSongs];
	
	if (newYouTubes){
		[_youTubes removeAllObjects];
		[_youTubes addObjectsFromArray:newYouTubes];
	}
	
	if (newSoundClouds){
		[_soundClouds removeAllObjects];
		[_soundClouds addObjectsFromArray:newSoundClouds];
	}
	
	[self.tableView reloadData];
}

#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return _artists.count;
	else if (section == 1) return _albums.count;
	else if (section == 2) return _songs.count;
	else if (section == 3) return _youTubes.count;
	else return _soundClouds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString * const CellIdentifier = @"CellIdentifier";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	
	MusicContainer * container = [self containerForIndexPath:indexPath];
	
	[cell.textLabel setText:container.title];
	[cell.detailTextLabel setText:container.subtitle];
	
	[cell.textLabel setTextColor:[UIColor pm_darkColor]];
	[cell.detailTextLabel setTextColor:[UIColor pm_darkColor]];
	
	[cell.textLabel setHighlightedTextColor:[UIColor pm_lightColor]];
	[cell.detailTextLabel setHighlightedTextColor:[UIColor pm_lightColor]];
	
	UIView * selectedBackgroundView = [[UIView alloc] init];
	[selectedBackgroundView setBackgroundColor:[UIColor pm_darkColor]];
	[cell setSelectedBackgroundView:selectedBackgroundView];
	[selectedBackgroundView release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	MusicContainer * container = [self containerForIndexPath:indexPath];
	if (container.type == MusicContainerTypeArtist || container.type == MusicContainerTypeAlbum){
		
		SearchResultsViewController * viewController = [[SearchResultsViewController alloc] init];
		[viewController setHideHeaders:YES];
		SearchResultsViewControllerContainer * containerController = [[SearchResultsViewControllerContainer alloc] initWithSearchResultsViewController:viewController];
		[viewController release];
		
		[self.navigationController pushViewController:containerController animated:YES];
		[containerController release];
		
		__block Device * weakDevice = container.device;
		if (container.type == MusicContainerTypeArtist){
			[container.device sendAlbumsForArtistRequest:container.identifier callback:^(NSDictionary *results) {
				
				NSArray * testAlbums = [results objectForKey:kDeviceSearchAlbumsKeyName];
				if ([testAlbums.lastObject isKindOfClass:[NSDictionary class]])
					testAlbums = [MusicContainer containersFromJSONDictionaries:testAlbums device:weakDevice];
				
				[viewController setArtists:nil albums:testAlbums songs:nil youTubes:nil soundClouds:nil];
			}];
		}
		else
		{
			[container.device sendSongsForAlbumRequest:container.identifier callback:^(NSDictionary *results) {
				
				NSArray * testSongs = [results objectForKey:kDeviceSearchSongsKeyName];
				if ([testSongs.lastObject isKindOfClass:[NSDictionary class]])
					testSongs = [MusicContainer containersFromJSONDictionaries:testSongs device:weakDevice];
				
				[viewController setArtists:nil albums:nil songs:testSongs youTubes:nil soundClouds:nil];;
			}];
		}
	}
	else if (container.type == MusicContainerTypeSong){
		
		MusicQueueItem * item = [[MusicQueueItem alloc] init];
		[item setSongIdentifier:container.identifier];
		[item setType:container.songType];
		[item setDeviceUUID:container.device.UUID];
		[item setTitle:container.title];
		[item setSubtitle:container.subtitle];
		
		UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
		UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] init];
		[spinner setColor:[UIColor pm_darkColor]];
		[cell setAccessoryView:spinner];
		[spinner sizeToFit];
		[spinner release];
		
		[[[DevicesManager sharedManager] outputDevice] queueItem:item callback:^(BOOL successful) {
			//[cell setAccessoryView:nil];
		}];
		
		[item release];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	NSString * title = [self tableView:tableView titleForHeaderInSection:section];
	return title ? [SearchResultsHeaderView headerViewWithTitle:title] : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (!_hideHeaders){
		if (section == 0) return (_artists.count ? Localized(@"Artists") : nil);
		else if (section == 1) return (_albums.count ? Localized(@"Albums") : nil);
		else if (section == 2) return (_songs.count ? Localized(@"Songs") : nil);
		else if (section == 3) return (_youTubes.count ? @"YouTube" : nil);
		else return (_soundClouds.count ? @"SoundCloud" : nil);
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self tableView:tableView titleForHeaderInSection:section] ? 22 : 0;
}

#pragma mark - Dealloc
- (void)dealloc {
	[_artists release];
	[_albums release];
	[_songs release];
	[_soundClouds release];
	[_youTubes release];
	[super dealloc];
}

@end

@implementation SearchResultsViewControllerContainer {
	UIView * _navigationBar;
	SearchResultsViewController * _searchResultsViewController;
}

- (id)initWithSearchResultsViewController:(SearchResultsViewController *)viewController {
	
	if ((self = [super init])){
		_searchResultsViewController = viewController;
		[self addChildViewController:_searchResultsViewController];
		[self.view addSubview:_searchResultsViewController.view];
		
		_navigationBar = [[UIView alloc] init];
		[_navigationBar setBackgroundColor:[UIColor pm_darkColor]];
		[self.view addSubview:_navigationBar];
		[_navigationBar release];
		
		UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarWasTapped:)];
		[_navigationBar addGestureRecognizer:tapRecognizer];
		[tapRecognizer release];
	}
	
	return self;
}

- (void)viewDidResizeToNewOrientation {
	
	[_navigationBar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 22)];
	[_searchResultsViewController.view setFrame:CGRectMake(0, CGRectGetHeight(_navigationBar.frame), CGRectGetWidth(_navigationBar.frame),
														  CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_navigationBar.frame))];
}

- (void)navigationBarWasTapped:(UITapGestureRecognizer *)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
