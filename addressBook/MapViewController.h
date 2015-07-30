//
//  MapViewController.h
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomMapView.h"
@class CDPerson;

enum viewControllers {VIEWCONTROLLER, DETAILVIEWCONTROLLER, EDITVIEWCONTROLLER};

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet CustomMapView *map;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *annotations;
@property (assign, nonatomic) enum viewControllers vc;
@property (strong, nonatomic) CDPerson* person;
@property (strong, nonatomic) NSString* fullAddress;


- (void) initWithPerson:(CDPerson*) person fromVC:(enum viewControllers) vc;


@end
