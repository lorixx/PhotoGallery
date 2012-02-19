//
//  PhotoScrollViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"


@interface PhotoScrollViewController : UIViewController<SplitViewBarButtonItemPresenter>

@property (strong, nonatomic) NSDictionary *photo;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;

-(NSInteger) calculateSizeForAllFiles:(NSArray *)files onDirectoryPath: (NSString *)directoryPath;
@end