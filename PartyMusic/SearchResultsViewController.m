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

@implementation SearchResultsViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
	
    [super viewDidLoad];
	[self.tableView setBackgroundColor:[UIColor pm_lightColor]];
	[self.tableView setSeparatorColor:[UIColor pm_darkLightColor]];
	
	artists = [[NSMutableArray alloc] init];
	albums = [[NSMutableArray alloc] init];
	songs = [[NSMutableArray alloc] init];
	youTubes = [[NSMutableArray alloc] init];
	soundClouds = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceControllerDidRemoveDevice:) name:DevicesManagerDidRemoveDeviceNotificationName object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[NSNotificationCenter defaultCenter] postNotificationName:SearchResultsViewControllerScrolledNotificationName object:nil];
}

- (void)deviceControllerDidRemoveDevice:(NSNotification *)notification {
	
	Device * removedDevice = [notification.object retain];
	[artists enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MusicContainer * container, NSUInteger idx, BOOL *stop) {
		if ([container.device isEqual:removedDevice]) [artists removeObjectAtIndex:idx];
	}];
	
	[albums enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MusicContainer * container, NSUInteger idx, BOOL *stop) {
		if ([container.device isEqual:removedDevice]) [albums removeObjectAtIndex:idx];
	}];
	
	[songs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MusicContainer * container, NSUInteger idx, BOOL *stop) {
		if ([container.device isEqual:removedDevice]) [songs removeObjectAtIndex:idx];
	}];
	
	[removedDevice release];
	[self.tableView reloadData];
}

- (MusicContainer *)containerForIndexPath:(NSIndexPath *)indexPath {
	
	MusicContainer * container = nil;
	if (indexPath.section == 0) container = [artists objectAtIndex:indexPath.row];
	else if (indexPath.section == 1) container = [albums objectAtIndex:indexPath.row];
	else if (indexPath.section == 2) container = [songs objectAtIndex:indexPath.row];
	else if (indexPath.section == 3) container = [youTubes objectAtIndex:indexPath.row];
	else if (indexPath.section == 4) container = [soundClouds objectAtIndex:indexPath.row];
	return container;
}

#pragma mark - Property Overrides
- (void)setArtists:(NSArray *)newArtists albums:(NSArray *)newAlbums songs:(NSArray *)newSongs youTubes:(NSArray *)newYouTubes soundClouds:(NSArray *)newSoundClouds {
	
	if (!newArtists) [artists removeAllObjects];
	else [artists addObjectsFromArray:newArtists];
	
	if (!newAlbums) [albums removeAllObjects];
	else [albums addObjectsFromArray:newAlbums];
	
	if (!newSongs) [songs removeAllObjects];
	else [songs addObjectsFromArray:newSongs];
	
	if (newYouTubes){
		[youTubes removeAllObjects];
		[youTubes addObjectsFromArray:newYouTubes];
	}
	
	if (newSoundClouds){
		[soundClouds removeAllObjects];
		[soundClouds addObjectsFromArray:newSoundClouds];
	}
	
	[self.tableView reloadData];
}

#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return artists.count;
	else if (section == 1) return albums.count;
	else if (section == 2) return songs.count;
	else if (section == 3) return youTubes.count;
	else return soundClouds.count;
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
	if (container.type == MusicContainerTypeSong){
		
		MusicQueueItem * item = [[MusicQueueItem alloc] init];
		[item setSongIdentifier:container.identifier];
		[item setType:container.songType];
		[item setDeviceUUID:container.device.UUID];
		[item setTitle:container.title];
		[item setSubtitle:container.subtitle];
		[[[DevicesManager sharedManager] outputDevice] queueItem:item];
		[item release];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString * title = [self tableView:tableView titleForHeaderInSection:section];
	return title ? [SearchResultsHeaderView headerViewWithTitle:title] : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return (artists.count ? Localized(@"Artists") : nil);
	else if (section == 1) return (albums.count ? Localized(@"Albums") : nil);
	else if (section == 2) return (songs.count ? Localized(@"Songs") : nil);
	else if (section == 3) return (youTubes.count ? @"YouTube" : nil);
	else return (soundClouds.count ? @"SoundCloud" : nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self tableView:tableView titleForHeaderInSection:section] ? 22 : 0;
}

#pragma mark - Dealloc
- (void)dealloc {
	[artists release];
	[albums release];
	[songs release];
	[soundClouds release];
	[youTubes release];
	[super dealloc];
}

@end