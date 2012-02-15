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
#import "SingletonNetworkSpinner.h"
#import "PlaceMapViewController.h"
#import "PlaceOnMapAnnotation.h"

@implementation ListOfPlacesTableViewController

@synthesize topPlaces = _topPlaces;
@synthesize countryNames = _countryNames;
@synthesize simpleDataStructureAllPlaces = _simpleDataStructureAllPlaces;



-(id<SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [[self.splitViewController.viewControllers lastObject] visibleViewController]; //current one is the mapview controller
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}


-(BOOL)splitViewController:(UISplitViewController *)svc 
  shouldHideViewController:(UIViewController *)vc 
             inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter]?UIInterfaceOrientationIsPortrait(orientation):NO;
}


-(void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title; //set a button for it
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
    //tell the detail view to put this button up
    
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //tell the detail view to take the button away
    
}


/* Lazy initialization for getting the top places */
-(NSArray*)topPlaces
{
    if (!_topPlaces) {
        
        NSArray* allPlaces = [FlickrFetcher topPlaces];
        _simpleDataStructureAllPlaces = allPlaces;
        
        
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

/* This is the method we check if we have this in iPad */
-(PlaceMapViewController*) splitViewPlaceMapViewController
{
    id pmvc = [[self.splitViewController.viewControllers lastObject] visibleViewController];
    if (![pmvc isKindOfClass:[PlaceMapViewController class]]) {
        pmvc = nil;
    }
    return pmvc;
}


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
    
    //init map view here if it is in iPad
    
    PlaceMapViewController *pmvc = [self splitViewPlaceMapViewController];
    if (pmvc) {
        
        NSMutableArray *placeAnnotations = [NSMutableArray arrayWithCapacity:[self.topPlaces count]];
        
        for (NSDictionary *place in self.simpleDataStructureAllPlaces) {
            
            [placeAnnotations addObject:[PlaceOnMapAnnotation annotationForPlace:place]];
            
        }
        
        pmvc.annotations =placeAnnotations;
        
        
    }
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
    
    if (![self splitViewPlaceMapViewController]) {
        cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    
    
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *placeSelected = [[self.topPlaces objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]; 
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
    PlaceMapViewController *placeMap = [storyboard instantiateViewControllerWithIdentifier:@"PlaceMapViewController"];
    placeMap.annotations = [NSArray arrayWithObjects:  [PlaceOnMapAnnotation annotationForPlace:placeSelected], nil];

//    NSMutableArray *thisAnnotations = [NSMutableArray arrayWithCapacity:[self.topPlaces count]];
//
////    for (id currentPlace in self.topPlaces) {
////        [annotations addObject:[PlaceOnMapAnnotation annotationForPlace:currentPlace]];
////    }
//    [thisAnnotations addObject:placeSelected];
    //placeMap.annotations = thisAnnotations ;

    [self.navigationController pushViewController:placeMap animated:YES];  
    placeMap.place = placeSelected;


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

    NSDictionary *currentPlace = [[self.topPlaces objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    PhotosOfPlaceTableViewController *photoOfPlaceTableViewController = [[PhotosOfPlaceTableViewController alloc]initWithPlace: currentPlace];
    
    //show spinner
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t  getPhotosToSet = dispatch_queue_create("getPhotosToSet", NULL);
    dispatch_async(getPhotosToSet, ^{
        photoOfPlaceTableViewController.photos = [FlickrFetcher photosInPlace:currentPlace maxResults:MAX_PHOTOS_FOR_PLACE];
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [self.navigationController pushViewController:photoOfPlaceTableViewController animated:YES];
        });
    });
    dispatch_release(getPhotosToSet);
 
}

@end
