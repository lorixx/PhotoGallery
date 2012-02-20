//
//  IpadPlaceMapViewController.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IpadMapViewController.h"

@implementation IpadMapViewController
@synthesize navBar = _navBar;
@synthesize mapView = _mapView;
@synthesize placeAnnotations = _placeAnnotations;
@synthesize photoAnnotations = _photoAnnotations;
@synthesize iPadImageDelegate = _iPadImageDelegate;
@synthesize currentPhotos = _currentPhotos;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;  //this is due to conforming to a protocol

#define ZOOM_LEVEL 9




#pragma mark - setting view
-(void) setRegion
{
    if ([self.currentPhotos count] > 0) {
        @try {
            NSDictionary *firstPhoto = [self.currentPhotos objectAtIndex:0];
            double max_long = [[firstPhoto objectForKey:FLICKR_LONGITUDE]doubleValue];
            double min_long = [[firstPhoto objectForKey:FLICKR_LONGITUDE]doubleValue];
            double max_lat =[[firstPhoto objectForKey:FLICKR_LATITUDE]doubleValue];
            double min_lat = [[firstPhoto objectForKey:FLICKR_LATITUDE]doubleValue];
            
            for (NSDictionary *currentPhoto in self.currentPhotos) {
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
            
            double deltaLat = fabs(max_lat - min_lat) ;
            double deltaLong = fabs(max_long - min_long) ;
            
            //if (deltaLat < 2) {deltaLat = 2;}
            //if (deltaLong < 2) {deltaLong = 2;}
            
            CLLocationCoordinate2D coord;
            coord.latitude = center_lat;
            coord.longitude = center_long;
            
            MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat, deltaLong);
            MKCoordinateRegion region = {coord, span};
            [self.mapView setRegion:region animated:YES];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error calculating new map region: %@", exception);
            
        }
    }
}





/* Here is how we set up toobar item for split view in potrait mode */
-(void) setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        [self.navBar.topItem setLeftBarButtonItem:splitViewBarButtonItem animated:NO];
        
    }
}

#pragma mark - Set mapView center

-(void) setMapViewCenter: (CLLocationCoordinate2D)center
{
    [self.mapView setCenterCoordinate:center zoomLevel:ZOOM_LEVEL animated:YES];
}

//-(void)setPlace:(NSDictionary *)place
//{
//    _place = place;
//    
//    CLLocationCoordinate2D coordinate;
//    coordinate.latitude = [[place objectForKey:FLICKR_LATITUDE] doubleValue];
//    coordinate.longitude = [[place objectForKey:FLICKR_LONGITUDE] doubleValue];
//    [self setMapViewCenter: coordinate];
//    //[self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];
//}

#pragma mark - Synchronize Model and View

- (void)updatePlaceMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.placeAnnotations) [self.mapView addAnnotations:self.placeAnnotations];
    [self.mapView selectAnnotation:[self.placeAnnotations lastObject] animated:YES];
    
}

- (void)updatePhotoMapView  //use to update all photos on the map
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    [self setRegion];
    if (self.photoAnnotations) [self.mapView addAnnotations:self.photoAnnotations];    
}


- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updatePlaceMapView];
}

- (void)setPlaceAnnotations:(NSArray *)placeAnnotations
{
    _placeAnnotations = placeAnnotations;
    [self updatePlaceMapView];
}


-(void)setPhotoAnnotations:(NSArray *)photoAnnotations
{
    _photoAnnotations = photoAnnotations;
    [self updatePhotoMapView];
}


#pragma mark - MKMapViewDelegate
/* This is used for generating annotation view for both place or photo annotation */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    
    if ([annotation isKindOfClass:[PhotoOnMapAnnotation class]] ) {  //if this is a photo annotation
        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"PhotosMap"];
        if (!aView) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PhotosMap"];
            aView.canShowCallout = YES; 
            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];    
        } 
        aView.annotation = annotation;
        return aView;
        
    } else { /* This is place annotation */
        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"PlacesMap"];
        if (!aView) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PlacesMap"];
            aView.canShowCallout = YES;  
        }
        aView.annotation = annotation;
        return aView;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    if ([aView.annotation isKindOfClass:[PhotoOnMapAnnotation class]] ) {  //set up image if it is photo
        UIImage *image = [self.iPadImageDelegate ipadMapViewController:self imageForAnnotation:aView.annotation];
        [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // To do: hook up another tableView Controller here, call out right accessory
    if ([view.annotation isKindOfClass:[PhotoOnMapAnnotation class]] ) {  //call out a photo scroll view
        
        
        
        
        
        
    }
    
    
    
    
    
}



#pragma mark - new bar button protocol
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Add the popover button to the left navigation item.
    [self.navBar.topItem setLeftBarButtonItem:barButtonItem animated:NO];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Remove the popover button.
    [self.navBar.topItem setLeftBarButtonItem:nil animated:NO];
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
