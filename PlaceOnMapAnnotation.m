//
//  PlacesOnMapAnnotation.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceOnMapAnnotation.h"
#import "FlickrFetcher.h"

@implementation PlaceOnMapAnnotation
@synthesize place = _place;

+(PlaceOnMapAnnotation *)annotationForPlace:(NSDictionary *)place
{
    PlaceOnMapAnnotation * annotation = [[PlaceOnMapAnnotation alloc]init];
    annotation.place =place;
    return annotation;
}


#pragma mark - MKAnnotation

- (NSString *)title
{
    return [self.place objectForKey:FLICKR_PLACE_NAME];
}

//- (NSString *)subtitle
//{
//    return [self.place valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
//}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
