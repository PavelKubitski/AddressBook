//
//  CustomMapView.h
//  addressBook
//
//  Created by Pavel Kubitski on 09.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CDPerson.h"

extern NSString* const MapViewTouchedNotification ;

extern NSString* const TouchesInfoKey ;
extern NSString* const EventInfoKey ;



@interface CustomMapView : MKMapView <MKMapViewDelegate>


@property (strong, nonatomic) CDPerson* person;


- (void)showHomeOnMap;
- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address;

@end
