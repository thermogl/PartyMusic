//
//  QueueViewController.m
//  PartyMusic
//
//  Created by Tom Irving on 25/02/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "QueueViewController.h"
#import "MusicQueueController.h"

@implementation QueueViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.tableView setBackgroundColor:[UIColor pm_lightColor]];
	[self.tableView setSeparatorColor:[UIColor pm_darkLightColor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicQueueDidChange:) name:kMusicQueuePlayerDidChangeStateNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicQueueDidChange:) name:kMusicQueuePlayerDidChangeQueueNotificationName object:nil];
}

- (void)musicQueueDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[MusicQueueController sharedController] queue] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString * const CellIdentifier = @"CellIdentifier";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	
	MusicQueueItem * item = [[[MusicQueueController sharedController] queue] objectAtIndex:indexPath.row];
	
	[cell.textLabel setText:item.title];
	[cell.detailTextLabel setText:item.subtitle];
	
	UIColor * textColor = [[[MusicQueueController sharedController] currentSong] isEqual:item] ? [UIColor pm_blueColor] : [UIColor pm_darkColor];
	
	[cell.textLabel setTextColor:textColor];
	[cell.detailTextLabel setTextColor:textColor];
	
	[cell.textLabel setHighlightedTextColor:[UIColor pm_lightColor]];
	[cell.detailTextLabel setHighlightedTextColor:[UIColor pm_lightColor]];
	
	UIView * selectedBackgroundView = [[UIView alloc] init];
	[selectedBackgroundView setBackgroundColor:[UIColor pm_darkColor]];
	[cell setSelectedBackgroundView:selectedBackgroundView];
	[selectedBackgroundView release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
