//
//  SearchSourcesViewController.m
//  PartyMusic
//
//  Created by Tom Irving on 23/03/2013.
//  Copyright (c) 2013 Tom Irving. All rights reserved.
//

#import "SearchSourcesViewController.h"

@implementation SearchSourcesViewController
@synthesize searchSources = _searchSources;

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView setBackgroundColor:[UIColor pm_lightColor]];
	[self.tableView setSeparatorColor:[UIColor pm_darkLightColor]];
}

- (SearchSources)searchSourceForIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == 0) return SearchSourceLocalLibrary;
	else if (indexPath.row == 1) return SearchSourceRemoteLibraries;
	else if (indexPath.row == 2) return SearchSourceYouTube;
	else return SearchSourceSoundCloud;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString * const CellIdentifier = @"CellIdentifier";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		[cell.textLabel setTextColor:[UIColor pm_darkColor]];
		[cell.detailTextLabel setTextColor:[UIColor pm_darkColor]];
		
		[cell.textLabel setHighlightedTextColor:[UIColor pm_lightColor]];
		[cell.detailTextLabel setHighlightedTextColor:[UIColor pm_lightColor]];
		
		UIView * selectedBackgroundView = [[UIView alloc] init];
		[selectedBackgroundView setBackgroundColor:[UIColor pm_darkColor]];
		[cell setSelectedBackgroundView:selectedBackgroundView];
	}
	
	if (indexPath.row == 0){
		[cell.textLabel setText:@"Local Library"];
		[cell setAccessoryType:(_searchSources & SearchSourceLocalLibrary ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
	}
	else if (indexPath.row == 1){
		[cell.textLabel setText:@"Remote Libraries"];
		[cell setAccessoryType:(_searchSources & SearchSourceRemoteLibraries ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
	}
	else if (indexPath.row == 2){
		[cell.textLabel setText:@"YouTube"];
		[cell setAccessoryType:(_searchSources & SearchSourceYouTube ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
	}
	else if (indexPath.row == 3){
		[cell.textLabel setText:@"SoundCloud"];
		[cell setAccessoryType:(_searchSources & SearchSourceSoundCloud ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
	SearchSources searchSource = [self searchSourceForIndexPath:indexPath];
	
	if (_searchSources & searchSource) _searchSources = (_searchSources & (~searchSource));
	else _searchSources = (_searchSources | searchSource);
	[cell setAccessoryType:(_searchSources & searchSource ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end