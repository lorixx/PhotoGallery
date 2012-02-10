//
//  SingletonNetworkSpinner.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingletonNetworkSpinner : UIActivityIndicatorView

+(UIActivityIndicatorView *)sharedNetworkWaitSpinner;

@end
