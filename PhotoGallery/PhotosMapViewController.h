//
//  PhotosMapViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PhotosMapViewController;

@protocol PhotosMapViewControllerDelegate <NSObject>

- (UIImage *)photoMapViewController:(PhotosMapViewController *)sender iamgeForAnnotation:(id <MKAnnotation>)annotation;

@end


@interface PhotosMapViewController : UIViewController

@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <PhotosMapViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *photos;

@end
