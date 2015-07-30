//
//  NSArray+Converter.m
//  addressBook
//
//  Created by Pavel Kubitski on 25.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "NSArray+Converter.h"
#import "CDCoordinate.h"
#import "CustomAnnotation.h"

@implementation NSArray (Converter)



- (NSMutableArray*) convertCDCoordArrayToAnnotationArray {
    NSArray* coordinates = self;
    NSMutableArray* annotations = [[NSMutableArray alloc] init];
    for (CDCoordinate* coordinate in coordinates) {
        CustomAnnotation* customAnnotation = [[CustomAnnotation alloc] initWithCDCoordinate:coordinate];
        [annotations addObject:customAnnotation];
    }
    return annotations;
}

- (NSSet*) convertAnnotationArrayToCDSet {
    NSMutableSet* coordinateSet = [[NSMutableSet alloc] init];
    NSArray* custAnnotations = self;
    for (CustomAnnotation* custAnnot in custAnnotations) {
        CDCoordinate* coordinate = [CDCoordinate coordinateWithCustomAnnotation:custAnnot];
        [coordinateSet addObject:coordinate];
    }
    return coordinateSet;
}

@end
