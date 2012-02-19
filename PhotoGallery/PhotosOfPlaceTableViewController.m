//
//  PhotosOfPlaceTableViewController.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosOfPlaceTableViewController.h"
#import "PhotoScrollViewController.h"
#import "FlickrFetcher.h"
#import <QuartzCore/QuartzCore.h>
#import "PhotosMapViewController.h"
#import "PhotoOnMapAnnotation.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "PlaceMapViewController.h"



@interface PhotosOfPlaceTableViewController()<PhotosMapViewControllerDelegate, IpadMapViewControllerDelegate>
@end


@implementation PhotosOfPlaceTableViewController

@synthesize place = _place;
@synthesize photos = _photos;

#pragma mark - split view delegate methods

-(id<SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject] ; //current one is the mapview controller
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
    PlaceMapViewController *pmvc = [self.splitViewController.viewControllers lastObject]; 
    [pmvc.navBar.topItem setLeftBarButtonItem:nil animated:NO];
    
}


/* This is the method we check if we have this in iPad */
-(PlaceMapViewController*) splitViewPlaceMapViewController
{
    id pmvc = [self.splitViewController.viewControllers lastObject] ;
    if (![pmvc isKindOfClass:[PlaceMapViewController class]]) {
        pmvc = nil;
    }
    return pmvc;
}


#pragma mark - initialize
-(id) initWithPlace: (NSDictionary*)currentPlace
{
    self = [super init ];
    if (self) {
        self.place = currentPlace;
    }
    return self;
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


#pragma mark - PhotosMapViewControllerDelegate
- (UIImage *)photoMapViewController:(PhotosMapViewController *)sender iamgeForAnnotation:(id <MKAnnotation>)annotation
{
    PhotoOnMapAnnotation *photoAnnotation = annotation;
    NSDictionary *photo = photoAnnotation.photo;
    NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}


#pragma mark -IpadMapViewControllerDelegate    /* this is for ipad  */
- (UIImage *)ipadMapViewController:(IpadMapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    PhotoOnMapAnnotation *photoAnnotation = annotation;
    NSDictionary *photo = photoAnnotation.photo;
    NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self.splitViewController.viewControllers lastObject] ) {  //if we are not in iPad

        UIBarButtonItem *mapViewBtn = [[UIBarButtonItem alloc] initWithTitle:@"Map View"  style:UIBarButtonItemStylePlain target:self action:@selector(buttonMapViewClicked)];
        self.navigationItem.rightBarButtonItem = mapViewBtn;
    }
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    self.photos = nil;
    _refreshHeaderView=nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PlaceMapViewController *pmvc = [self splitViewPlaceMapViewController];
    if (pmvc) {
        
        NSMutableArray *photonnotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
        
        for (NSDictionary *photo in self.photos) {
            
            [photonnotations addObject:[PhotoOnMapAnnotation annotationForPhoto:photo]];
            
        }
        pmvc.photos = self.photos;
        pmvc.photoAnnotations = photonnotations;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photos count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    NSString * title = [photo objectForKey: PHOTO_TITLE_KEY];
    if ([title isEqualToString:@""]) {
        title = @"Untitled";
    }
    
    //cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [photo objectForKey:OWNER_NAME_KEY];
    cell.imageView.frame = CGRectMake(15, 6, 58, 58);
    cell.imageView.layer.cornerRadius = 6.0;
    cell.imageView.layer.masksToBounds = YES;
    [cell bringSubviewToFront:[cell.imageView superview]];
    
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"Placeholder" ofType:@"png"];

    cell.imageView.image = [[UIImage alloc]initWithContentsOfFile:thePath];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("getThumbnail", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *photoData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UITableViewCell *cell  = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.imageView.image = [UIImage imageWithData:photoData];
            [cell setNeedsLayout];  //call this to reload image for this cell
        });
    });
    dispatch_release(downloadQueue);
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"haha");
//}


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


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    
    dispatch_queue_t  downloadPhotoInfos = dispatch_queue_create("getPhotosForPlace", NULL);
    dispatch_async(downloadPhotoInfos, ^{
        self.photos = [FlickrFetcher photosInPlace:self.place maxResults:MAX_PHOTOS_FOR_PLACE];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    dispatch_release(downloadPhotoInfos);
    
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
    PhotoScrollViewController *photoViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoScrollViewController"];
    photoViewController.photo = [self.photos objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:photoViewController animated:YES];
}



#pragma mark - onClick right bar button item

-(IBAction)buttonMapViewClicked
{
    //set up map view controller and initialize here    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
    
    PhotosMapViewController *photosMap = [storyboard instantiateViewControllerWithIdentifier:@"PhotosMapViewController"];
    
    NSMutableArray *allAnnotation = [NSMutableArray arrayWithCapacity:[self.photos count]];
    
    for (id photo in self.photos){
        [allAnnotation addObject: [PhotoOnMapAnnotation annotationForPhoto:photo]];
    }
    
    photosMap.annotations = allAnnotation;
    photosMap.photos = self.photos;
    photosMap.delegate = self;
    
    [self.navigationController pushViewController:photosMap animated:YES];  
    
}


@end
