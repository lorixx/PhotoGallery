//
//  PhotosOfPlaceTableViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


#import "EGORefreshTableHeaderView.h"
#import "IpadMapViewController.h"





@interface PhotosOfPlaceTableViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource,UISplitViewControllerDelegate>{

    EGORefreshTableHeaderView *_refreshHeaderView;

//  Reloading var should really be your tableviews datasource
//  Putting it here for demo purposes 
    BOOL _reloading;
}


@property (nonatomic, weak) NSDictionary *place;
@property (nonatomic, strong) NSArray *photos;

-(id) initWithPlace: (NSDictionary*)currentPlace;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
