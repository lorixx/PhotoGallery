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

@interface PlaceMapViewController : UIViewController <SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <PlaceMapViewControllerDelegate> delegate;
@property (nonatomic, weak) NSDictionary *place;


@end
