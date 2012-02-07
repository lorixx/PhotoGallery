//
//  SingletonNetworkSpinner.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingletonNetworkSpinner.h"

@implementation SingletonNetworkSpinner


+(UIActivityIndicatorView *)sharedNetworkWaitSpinner {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(id) init {
    self = [super init];
    self.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    return self;
}

@end
