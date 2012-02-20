//
//  SubstitutableDetailViewController.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SubstitutableDetailViewController <NSObject>
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end
