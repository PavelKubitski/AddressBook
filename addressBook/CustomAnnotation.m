//
//  CustomAnnotation.m
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CustomAnnotation.h"
#import "CDCoordinate.h"

@implementation CustomAnnotation

- (CustomAnnotation*) initWithCDCoordinate:(CDCoordinate*) coordinate {

    self.title = coordinate.nameOfLocation;
    self.subtitle = coordinate.subTitleOfLocation;
    self.fullAddress = coordinate.fullAddress;
    CLLocationCoordinate2D pinCoordinate;
    if (coordinate.latitude == nil)
        pinCoordinate.latitude = -1;
    else
        pinCoordinate.latitude = [coordinate.latitude doubleValue];
    
    if (coordinate.longitude == nil)
        pinCoordinate.longitude = -1;
    else
        pinCoordinate.longitude = [coordinate.longitude doubleValue];

    self.coordinate = pinCoordinate;
    
    return self;
}




@end
