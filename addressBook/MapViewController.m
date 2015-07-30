//
//  MapViewController.m
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "MapViewController.h"
#import "CustomAnnotation.h"
#import "UIView+MKAnnotationView.h"
#import "CDPerson.h"
#import "CDManager.h"
#import "CDCoordinate.h"
#import "NSArray+Converter.h"


@interface MapViewController ()

@property (strong, nonatomic) CLGeocoder* geoCoder;
@property (strong, nonatomic) MKDirections* directions;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.map.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeHomeLocation:)];
    lpgr.minimumPressDuration = 0.3;
    [self.map addGestureRecognizer:lpgr];


    self.geoCoder = [[CLGeocoder alloc] init];
    self.map.showsUserLocation = YES;
    
    NSUInteger size = 20;
    UIFont * font = [UIFont boldSystemFontOfSize:size];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    
    NSUInteger sizeHome = 30;
    UIFont * fontHome = [UIFont boldSystemFontOfSize:sizeHome];
    NSDictionary * attributesHome = @{NSFontAttributeName: fontHome};

    UIBarButtonItem* searchMySelfButton = [[UIBarButtonItem alloc] initWithTitle:@"Me" style:UIBarButtonItemStylePlain target:self action:@selector(actionSearchMySelf:)];
    UIBarButtonItem* searchHomeButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2302" style:UIBarButtonItemStylePlain target:self action:@selector(actionSearchHome:)];
    
    [searchMySelfButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [searchHomeButton setTitleTextAttributes:attributesHome forState:UIControlStateNormal];
    
    [self.navigationItem setRightBarButtonItems:@[searchMySelfButton, searchHomeButton]];
    
    [self setValidSizesOfControllers];
}

- (void) setValidSizesOfControllers {
    
    CGRect frameMap = self.map.frame;
    frameMap.size.width = self.view.frame.size.width;
    self.map.frame = frameMap;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.map removeAnnotations:[self.map annotations]];
    [self.map addAnnotations:self.annotations];
    [self.map showHomeOnMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
}

- (void)changeHomeLocation:(UIGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.vc == EDITVIEWCONTROLLER) {

            CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
            CLLocationCoordinate2D touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
            CustomAnnotation *point = [[CustomAnnotation alloc] init];
            point.title = @"Home";

            
            point.coordinate = touchMapCoordinate;
            for (id annotation in self.map.annotations) {
                if ([annotation isKindOfClass:[CustomAnnotation class]]) {
                    [self.map removeAnnotation:annotation];
                    [self.annotations removeLastObject];
                    CDCoordinate* coordinate = [[self.person coordinate] anyObject];
                    [[[CDManager sharedManager] managedObjectContext] deleteObject:coordinate];
                }
            }
            
            [self.map addAnnotation:point];
            [self.annotations addObject:point];
            
            [self getAddressFromCoordinates:point.coordinate.latitude andLongitude:point.coordinate.longitude showAlert:NO];
            [self addAnnotationToPerson:point];
            [self.map removeOverlays:self.map.overlays];

        } else if (self.vc == DETAILVIEWCONTROLLER) {
            [self showAlertWithTitle:@"Warning" andMessage:@"You can change homelocation only in edit mode"];
        }
    }
}

-(void) getAddressFromCoordinates:(double) latitude andLongitude:(double) longitude showAlert:(BOOL) needToShow{

    CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude
                                                      longitude:longitude];
    [self.geoCoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                  
              NSString* message = nil;
              
              if (error) {
                  
                  message = [NSString stringWithFormat:@"%@", [error localizedDescription]];
                  
              } else {
                  if ([placemarks count] > 0) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];

                      self.fullAddress = [self makeFormatedAddress:placemark];
                      message = self.fullAddress;
                      [self addFullAddressToPerson];
                  } else {
                       message = @"No Placemarks Found";
                  }
              }
              if (needToShow) {
                  [self showAlertWithTitle:@"Address" andMessage:self.fullAddress];
              }
                
              }];
}

- (NSString*) makeFormatedAddress:(CLPlacemark*) placemark {

    NSString* formatedAddress = [NSString stringWithFormat:@"Str.-%@ %@_city.-%@_country-%@_countryCode-%@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.country, placemark.ISOcountryCode];
    NSString* resultAddress = [formatedAddress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    return resultAddress;
}

- (void) addAnnotationToPerson:(CustomAnnotation*) annotation {
    CDCoordinate* coordinate = [NSEntityDescription insertNewObjectForEntityForName:@"CDCoordinate"
                                                             inManagedObjectContext:[[CDManager sharedManager] managedObjectContext]];
    coordinate.nameOfLocation = annotation.title;
    coordinate.subTitleOfLocation = annotation.subtitle;
    coordinate.latitude = @(annotation.coordinate.latitude);
    coordinate.longitude = @(annotation.coordinate.longitude);
    [self.person addCoordinateObject:coordinate];
}

-(void) addFullAddressToPerson {
    NSManagedObjectContext* context = [[CDManager sharedManager] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CDCoordinate" inManagedObjectContext: context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"person == %@", self.person];
    [request setPredicate: predicate];
    
    NSError *error = nil;
    NSArray *coordinates = [context executeFetchRequest:request error:&error];
    CDCoordinate* coordinate = [coordinates firstObject];
    coordinate.fullAddress = self.fullAddress;
    
}






#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString* identifier = @"Annotation";
    
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        pin.pinColor = MKPinAnnotationColorPurple;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
        
        UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = descriptionButton;
        
        UIButton* directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
        pin.leftCalloutAccessoryView = directionButton;

    } else {
        pin.annotation = annotation;
    }
    
    return pin;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        return renderer;
    }
    return nil;
}

#pragma mark - actions

- (void)actionSearchMySelf:(UIBarButtonItem*) sender {
    CLLocationCoordinate2D startCoord = self.map.userLocation.coordinate;
    MKCoordinateRegion adjustedRegion = [self.map regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 200, 200)];
    [self.map setRegion:adjustedRegion animated:YES];
}

- (void)actionSearchHome:(UIBarButtonItem*) sender {
    NSArray* annotations = self.map.annotations;
    for (id annotation in annotations) {
        if ([annotation isKindOfClass:[CustomAnnotation class]]) {
            CLLocationCoordinate2D startCoord = [(CustomAnnotation*)annotation coordinate];
            MKCoordinateRegion adjustedRegion = [self.map regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 200, 200)];
            [self.map setRegion:adjustedRegion animated:YES];
        }
        
    }

}

- (void) actionDirection:(UIButton*) sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    request.destination = destination;
    
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    request.requestsAlternateRoutes = YES;
    
    self.directions = [[MKDirections alloc] initWithRequest:request];
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            [self showAlertWithTitle:@"Error" andMessage: [error localizedDescription]];
        } else if ([response.routes count] == 0) {
            [self showAlertWithTitle:@"Error" andMessage:@"No routes found"];
        } else {
            
            [self.map removeOverlays:[self.map overlays]];
            
            NSMutableArray* array = [NSMutableArray array];
            
            for (MKRoute* route in response.routes) {
                [array addObject:route.polyline];
            }
            
            [self.map addOverlays:array level:MKOverlayLevelAboveRoads];
            [self showAllAnnotations];
        }
        
        
    }];
    
}


- (void) actionDescription:(id) sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    [self getAddressFromCoordinates:coordinate.latitude andLongitude:coordinate.longitude showAlert:YES];
    
    

}



- (void) showAllAnnotations {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in self.map.annotations) {
        
        CLLocationCoordinate2D location = annotation.coordinate;
        
        MKMapPoint center = MKMapPointForCoordinate(location);
        
        static double delta = 20000;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    
    zoomRect = [self.map mapRectThatFits:zoomRect];
    
    [self.map setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                           animated:YES];
    
}

- (NSString*) creatingAddressFromPlacemark:(MKPlacemark*) placemark {

    self.fullAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.country];
    return self.fullAddress;
}

- (void) showAlertWithTitle:(NSString*) title andMessage:(NSString*) message {
    [[[UIAlertView alloc]
      initWithTitle:title
      message:message
      delegate:nil
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil] show];
}

#pragma mark - initialising

- (void) initWithPerson:(CDPerson*) person fromVC:(enum viewControllers) vc {
    self.person = person;
    NSMutableArray* annotations = [[self.person.coordinate allObjects] convertCDCoordArrayToAnnotationArray];

    self.annotations = annotations;
    self.vc = vc;
}

@end
