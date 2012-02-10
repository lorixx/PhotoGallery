//
//  RecentPhotosTableViewController.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "PhotoScrollViewController.h"
#import "PhotosOfPlaceTableViewController.h"
#import "FlickrFetcher.h"

@interface RecentPhotosTableViewController () 

@property (nonatomic, strong)NSArray *recentPhotos;

@end


@implementation RecentPhotosTableViewController

@synthesize recentPhotos = _recentPhotos;

-(NSArray*)recentPhotos
{
    //everytime update
    if (!_recentPhotos) {
        NSUserDefaults *defaultDataBase = [NSUserDefaults standardUserDefaults];
        _recentPhotos = [defaultDataBase objectForKey: RECENT_PHOTOS];
    }

    return _recentPhotos;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.recentPhotos = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.recentPhotos = nil;    //set this to nil for re-getting data from defaul database
    [self.tableView reloadData];  //this is important for that we are reloading all the rows in table view
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.recentPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSDictionary *photo = [self.recentPhotos objectAtIndex:indexPath.row];
    
    NSString * title = [photo objectForKey: PHOTO_TITLE_KEY];
    if ([title isEqualToString:@""]) {
        title = @"Untitled";
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [photo objectForKey:OWNER_NAME_KEY];
    


    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //PhotoScrollViewController *photoViewController = [[PhotoScrollViewController alloc]initWithPhoto:[self.recentPhotos objectAtIndex:indexPath.row]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
    PhotoScrollViewController *photoViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoScrollViewController"];
    
    photoViewController.photo = [self.recentPhotos objectAtIndex:indexPath.row];
    
    
    [self.navigationController pushViewController:photoViewController animated:YES];
}

@end
