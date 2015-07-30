//
//  CDCoordinate.m
//  addressBook
//
//  Created by Pavel Kubitski on 25.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CDCoordinate.h"
#import "CDPerson.h"
#import "CDManager.h"


@implementation CDCoordinate

@dynamic nameOfLocation;
@dynamic latitude;
@dynamic longitude;
@dynamic subTitleOfLocation;
@dynamic fullAddress;
@dynamic person;

+ (CDCoordinate*) coordinateWithCustomAnnotation:(CustomAnnotation*) customAnnotation {
    CDCoordinate* coordinate = [NSEntityDescription insertNewObjectForEntityForName:@"CDCoordinate"
                                           inManagedObjectContext:[[CDManager sharedManager] managedObjectContext]];
    coordinate.nameOfLocation = customAnnotation.title;
    coordinate.longitude = @(customAnnotation.coordinate.longitude);
    coordinate.latitude = @(customAnnotation.coordinate.latitude);
    coordinate.fullAddress = customAnnotation.fullAddress;
    return coordinate;
}




@end
