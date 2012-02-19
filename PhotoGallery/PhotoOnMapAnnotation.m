//
//  PhotoOnMapAnnotation.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoOnMapAnnotation.h"
#import "FlickrFetcher.h"

@implementation PhotoOnMapAnnotation

@synthesize photo = _photo;

+(PhotoOnMapAnnotation *)annotationForPhoto:(NSDictionary *)photo
{
    PhotoOnMapAnnotation * annotation = [[PhotoOnMapAnnotation alloc]init];
    annotation.photo = photo;
    return annotation;
}


#pragma mark - MKAnnotation

- (NSString *)title
{    
    NSString *titleValue = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    if ([titleValue isEqualToString:@""]) {
        titleValue = @"Untitled";
    }
    return titleValue;
}

- (NSString *)subtitle
{
    NSMutableString * author = [[NSMutableString alloc]initWithString:@"By "];
    [author appendString:[self.photo valueForKeyPath:OWNER_NAME_KEY]];
    return author;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
