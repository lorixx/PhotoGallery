//
//  PlacesOnMapAnnotation.h
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceOnMapAnnotation : NSObject<MKAnnotation>

+(PlaceOnMapAnnotation *)annotationForPlace:(NSDictionary *)place;

@property (nonatomic, strong) NSDictionary *place;

@end
