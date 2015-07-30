//
//  CustomAnnotation.h
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
@class CDCoordinate;

@interface CustomAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *fullAddress;

- (CustomAnnotation*) initWithCDCoordinate:(CDCoordinate*) coordinate;

@end
