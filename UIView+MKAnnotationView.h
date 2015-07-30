//
//  UIView+MKAnnotationView.h
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotationView.h>

@interface UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView;

@end
