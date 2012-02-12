//
//  PhotoOnMapAnnotation.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>





@interface PhotoOnMapAnnotation : NSObject<MKAnnotation>

+(PhotoOnMapAnnotation *)annotationForPhoto:(NSDictionary *)photo;

@property (nonatomic, strong) NSDictionary *photo;

@end
