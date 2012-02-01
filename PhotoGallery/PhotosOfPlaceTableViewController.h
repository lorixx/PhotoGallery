//
//  PhotosOfPlaceTableViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosOfPlaceTableViewController : UITableViewController

@property (nonatomic, weak) NSDictionary *place;

-(id) initWithPlace: (NSDictionary*)currentPlace;


@end
