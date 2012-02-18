//
//  PlacesMapViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SplitViewBarButtonItemPresenter.h"


@class PlaceMapViewController;

@protocol PlaceMapViewControllerDelegate <NSObject>
- (UIImage *)placeMapViewController:(PlaceMapViewController *)sender iamgeForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface PlaceMapViewController : UIViewController <SplitViewBarButtonItemPresenter, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>

@property (nonatomic, strong)NSArray *photoAnnotations;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property (nonatomic, weak) id <PlaceMapViewControllerDelegate> delegate;
@property (nonatomic, weak) NSDictionary *place;
@property (nonatomic, weak) NSArray *photos; //saving all photos for the current selection in the view


@end
