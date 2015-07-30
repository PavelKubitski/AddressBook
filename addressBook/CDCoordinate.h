//
//  CDCoordinate.h
//  addressBook
//
//  Created by Pavel Kubitski on 25.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDObject.h"
#import "CustomAnnotation.h"

@class CDPerson;

@interface CDCoordinate : CDObject

@property (nonatomic, retain) NSString * nameOfLocation;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * subTitleOfLocation;
@property (nonatomic, retain) NSString * fullAddress;
@property (nonatomic, retain) CDPerson *person;


+ (CDCoordinate*) coordinateWithCustomAnnotation:(CustomAnnotation*) customAnnotation;

@end
