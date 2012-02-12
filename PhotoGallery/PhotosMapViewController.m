//
//  PhotosMapViewController.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosMapViewController.h"
#import "PhotoScrollViewController.h"
#import "PhotoOnMapAnnotation.h"
#import "FlickrFetcher.h"

@interface PhotosMapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end


//#define ZOOM_LEVEL 9

@implementation PhotosMapViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize photos = _photos;

#pragma mark - Synchronize Model and View

-(void) setRegion
{
    if ([self.photos count] > 0) {
        @try {
            NSDictionary *firstPhoto = [self.photos objectAtIndex:0];
            double max_long = [[firstPhoto objectForKey:FLICKR_LONGITUDE]doubleValue];
            double min_long = [[firstPhoto objectForKey:FLICKR_LONGITUDE]doubleValue];
            double max_lat =[[firstPhoto objectForKey:FLICKR_LATITUDE]doubleValue];
            double min_lat = [[firstPhoto objectForKey:FLICKR_LATITUDE]doubleValue];
            
            for (NSDictionary *currentPhoto in self.photos) {
                if ([[currentPhoto objectForKey:FLICKR_LATITUDE]doubleValue] > max_lat) {
                    max_lat = [[currentPhoto objectForKey:FLICKR_LATITUDE]doubleValue];
                } 
                
                if ([[currentPhoto objectForKey:FLICKR_LATITUDE]doubleValue] < min_lat) {
                    min_lat = [[currentPhoto objectForKey:FLICKR_LATITUDE]doubleValue];
                } 
                if ([[currentPhoto objectForKey:FLICKR_LONGITUDE]doubleValue] > max_long) {
                    max_long = [[currentPhoto objectForKey:FLICKR_LONGITUDE]doubleValue];
                } 
                
                if ([[currentPhoto objectForKey:FLICKR_LONGITUDE]doubleValue] < min_long) {
                    min_long = [[currentPhoto objectForKey:FLICKR_LONGITUDE]doubleValue];
                }                 
            }
            
            
            double center_long = (max_long + min_long)/2;
            double center_lat = (max_lat + min_lat)/2;
            
            double deltaLat = abs(max_lat - min_lat);
            double deltaLong = abs(max_long - min_long);
            
            if (deltaLat < 2) {deltaLat = 2;}
            if (deltaLong < 2) {deltaLong = 2;}
            
            CLLocationCoordinate2D coord = {latitude: center_lat, longitude: center_long};
            MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat, deltaLong);
            MKCoordinateRegion region = {coord, span};
            [self.mapView setRegion:region];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error calculating new map region: %@", exception);

        }
    }
}

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    [self setRegion];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];  
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
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];;
    }
    
    aView.annotation = annotation;
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    /* Set up Image getting from server */
    UIImage *image = [self.delegate photoMapViewController:self iamgeForAnnotation:aView.annotation];  //maybe there is lag issue
        
    
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // To do: hook up photo view tableView Controller here
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
    PhotoScrollViewController *photoViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoScrollViewController"];
    
    PhotoOnMapAnnotation *photoAnnotation = view.annotation;
    photoViewController.photo = photoAnnotation.photo;
    [self.navigationController pushViewController:photoViewController animated:YES];
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
