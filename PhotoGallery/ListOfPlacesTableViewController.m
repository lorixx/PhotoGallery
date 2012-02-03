//
//  ListOfPlacesTableViewController.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListOfPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotosOfPlaceTableViewController.h"

@implementation ListOfPlacesTableViewController

@synthesize topPlaces = _topPlaces;
@synthesize countryNames = _countryNames;

/* Lazy initialization for getting the top places */
-(NSArray*)topPlaces
{
    if (!_topPlaces) {
        
        NSArray* allPlaces = [FlickrFetcher topPlaces];
        
        
        NSMutableDictionary *countryMap = [[NSMutableDictionary alloc]init ];
        
        for (id place in allPlaces) {
            NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
            NSArray *nameItems = [placeName componentsSeparatedByString:@", "];
            NSString *countryName = [nameItems lastObject];
            
            if (![countryMap objectForKey:countryName]) {
                NSMutableArray *placesForCountry = [[NSMutableArray alloc]initWithObjects:place, nil ];
                [countryMap setObject:placesForCountry forKey:countryName];
            } else {
                NSMutableArray *currentPlacesForCountry = [countryMap objectForKey:countryName];
                [currentPlacesForCountry addObject:place];
                [countryMap setObject:currentPlacesForCountry forKey:countryName];
            }
        }
        
        //now we have the places array
        NSMutableArray *topPlaces = [NSMutableArray array ];
        NSArray *sortedKeys = [[countryMap allKeys] sortedArrayUsingSelector: @selector(compare:)];
        for (NSString *key in sortedKeys ) {
            [topPlaces addObject: [countryMap objectForKey:key]];
            [self.countryNames addObject:key];
        }
        
        _topPlaces = topPlaces;
        
    }
    return _topPlaces;
}

-(NSMutableArray*)countryNames{
    if (!_countryNames) {
        _countryNames = [NSMutableArray array];
    }
    return _countryNames;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    
    
    self.topPlaces = nil;
    self.countryNames = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.topPlaces count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.topPlaces objectAtIndex:section]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top places";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSDictionary *place = [[self.topPlaces objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [place valueForKey:FLICKR_PLACE_NAME];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [self.countryNames objectAtIndex:section];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    PhotosOfPlaceTableViewController *photoOfPlaceTableViewController = [[PhotosOfPlaceTableViewController alloc]initWithPlace: [[self.topPlaces objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:photoOfPlaceTableViewController animated:YES];
}

@end
