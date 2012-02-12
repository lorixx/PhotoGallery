//
//  PlacesMapViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class PlaceMapViewController;

@protocol PlaceMapViewControllerDelegate <NSObject>
- (UIImage *)placeMapViewController:(PlaceMapViewController *)sender iamgeForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface PlaceMapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <PlaceMapViewControllerDelegate> delegate;

-(void) setMapViewCenter: (CLLocationCoordinate2D)center;

@end
