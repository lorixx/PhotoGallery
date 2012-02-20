//
//  IpadMapViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "MKMapView+ZoomLevel.h"
#import "PlaceOnMapAnnotation.h"
#import "PhotoOnMapAnnotation.h"
#import "FlickrFetcher.h"
#import "ListOfPlacesTableViewController.h"
#import "PhotosOfPlaceTableViewController.h"
#import "SubstitutableDetailViewController.h"

@class IpadMapViewController;
@protocol IpadMapViewControllerDelegate <NSObject>    //this delegate should be used in PhotosOfPlaceTableViewController
- (UIImage *)ipadMapViewController:(IpadMapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@end


@interface IpadMapViewController : UIViewController<SplitViewBarButtonItemPresenter, MKMapViewDelegate, SubstitutableDetailViewController>

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSArray *placeAnnotations; // of id <MKAnnotation>, use to show all places in the map
@property (nonatomic, strong) NSArray *photoAnnotations; // of id <MKAnnotation>, use to show all photos in the map

@property (nonatomic, weak) id<IpadMapViewControllerDelegate> iPadImageDelegate; //this will be the photo table

@property (nonatomic, weak) NSArray *currentPhotos; // saving all photos for the current selection

@end
