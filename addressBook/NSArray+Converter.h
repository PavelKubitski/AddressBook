//
//  NSArray+Converter.h
//  addressBook
//
//  Created by Pavel Kubitski on 25.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Converter)

- (NSMutableArray*) convertCDCoordArrayToAnnotationArray;
- (NSSet*) convertAnnotationArrayToCDSet;


@end
