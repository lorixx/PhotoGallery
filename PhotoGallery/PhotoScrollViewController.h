//
//  PhotoScrollViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RECENT_PHOTOS @"recentPhotos"

@interface PhotoScrollViewController : UIViewController

-(id)initWithPhoto: (NSDictionary*)photo;

@end