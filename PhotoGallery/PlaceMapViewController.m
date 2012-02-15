//
//  PlaceMapViewController.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceMapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "FlickrFetcher.h"
#import "PhotosOfPlaceTableViewController.h"
#import "PlaceOnMapAnnotation.h"


@interface PlaceMapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end


@implementation PlaceMapViewController

#define ZOOM_LEVEL 9

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize place = _place;


#pragma mark - Set mapView center

-(void) setMapViewCenter: (CLLocationCoordinate2D)center
{
    [self.mapView setCenterCoordinate:center zoomLevel:ZOOM_LEVEL animated:YES];
}

-(void)setPlace:(NSDictionary *)place
{
    _place = place;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[place objectForKey:FLICKR_LONGITUDE] doubleValue];
    [self setMapViewCenter: coordinate];
    //[self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];
   
}

#pragma mark - Synchronize Model and View

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
    [self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];

}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        //aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        
        if (![self.splitViewController.viewControllers lastObject] ) {  //if we are not in iPad
            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];;
        }
        
        
    }
    
    aView.annotation = annotation;
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    //UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
    //[(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // To do: hook up another tableView Controller here
    PhotosOfPlaceTableViewController *photoOfPlaceTableViewController = [[PhotosOfPlaceTableViewController alloc]initWithPlace: self.place];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t  getPhotosToSet = dispatch_queue_create("getPhotosToSet", NULL);   
    dispatch_async(getPhotosToSet, ^{
        
        PlaceOnMapAnnotation *placeAnnotation = view.annotation;
        photoOfPlaceTableViewController.photos = [FlickrFetcher photosInPlace: placeAnnotation.place  maxResults:MAX_PHOTOS_FOR_PLACE];
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating]; //stop animating of spinner
            [self.navigationController pushViewController:photoOfPlaceTableViewController animated:YES];
        });
    });
    dispatch_release(getPhotosToSet);
  
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    //self.mapView.mapType = MKMapTypeHybrid;
    

}


- (void)viewDidUnload
{
    self.mapView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
