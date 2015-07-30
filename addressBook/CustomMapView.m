//
//  CustomMapView.m
//  addressBook
//
//  Created by Pavel Kubitski on 09.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CustomMapView.h"
#import "CustomAnnotation.h"
#import "CDCoordinate.h"
#import "CDManager.h"
#import "EditInfoViewController.h"
#import "DetailViewController.h"
#import "NSString+PhoneNumber.h"



NSString* const MapViewTouchedNotification = @"MapViewTouchedNotification";

NSString* const TouchesInfoKey = @"TouchesInfoKey";
NSString* const EventInfoKey = @"EventInfoKey";



@implementation CustomMapView

- (void)awakeFromNib {
    self.delegate = self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{


    UIView* next;
    for (next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[EditInfoViewController class]] ||
            [nextResponder isKindOfClass:[DetailViewController class]])
        {
            NSDictionary* dc = [NSDictionary dictionaryWithObjectsAndKeys:touches,TouchesInfoKey,event, EventInfoKey, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MapViewTouchedNotification
                                                                object:nil
                                                              userInfo:dc];
        }
    }
    

}



- (void)showHomeOnMap {
    CustomMapView *mapView = self;
    NSArray* annotations = [mapView annotations];

    for (CustomAnnotation* annotation in annotations) {
        if ([annotation isKindOfClass:[CustomAnnotation class]]) {
            CLLocationCoordinate2D startCoord = annotation.coordinate;
            MKCoordinateRegion adjustedRegion = [mapView regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 400, 400)];
            [mapView setRegion:adjustedRegion animated:YES];
        }

    }
}

#pragma mark - MKMapViewDelegate

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
        pin.canShowCallout = NO;
        pin.draggable = NO;
        
    } else {
        pin.annotation = annotation;
    }
    
    return pin;
}



- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    CustomMapView* map = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocationCoordinate2D ret;
    NSString* validAddress = [address makeValidAddressFromString];

    [geocoder geocodeAddressString: validAddress completionHandler:^(NSArray* placemarks, NSError* error) {
        for (CLPlacemark* aPlacemark in placemarks)
        {

            CLLocationCoordinate2D center;

            center.latitude = aPlacemark.location.coordinate.latitude;
            center.longitude = aPlacemark.location.coordinate.longitude;

            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 50, 50);
            
            region.span.latitudeDelta = 0.01f;
            
            region.span.longitudeDelta = 0.01f;
            
            region.center = center;
            
            
            [map setRegion:region animated:YES];
            

            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
            
            annotation.coordinate = center;
            annotation.title = @"Home";
            
            [map addAnnotation:annotation];
            [self addAnnotationToPerson:(CustomAnnotation*)annotation];
            return ;

        }
    }];

    return ret;
    
}

- (void) addAnnotationToPerson:(CustomAnnotation*) annotation {

    NSManagedObjectContext* context = [[CDManager sharedManager] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CDCoordinate" inManagedObjectContext: context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"person == %@", self.person];
    [request setPredicate: predicate];
    
    NSError *error = nil;
    NSArray *coordinates = [context executeFetchRequest:request error:&error];
    CDCoordinate* coordinate = [coordinates firstObject];
    
    coordinate.nameOfLocation = annotation.title;
    coordinate.subTitleOfLocation = annotation.subtitle;
    coordinate.latitude = @(annotation.coordinate.latitude);
    coordinate.longitude = @(annotation.coordinate.longitude);

    [[CDManager sharedManager] saveContext];
}


@end
