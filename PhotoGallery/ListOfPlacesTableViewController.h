//
//  ListOfPlacesTableViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListOfPlacesTableViewController : UITableViewController<UISplitViewControllerDelegate>

@property (nonatomic, strong)NSArray *topPlaces;
@property (nonatomic, strong)NSArray *simpleDataStructureAllPlaces;
@property (nonatomic, strong) NSMutableArray *countryNames;

@end
