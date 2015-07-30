//
//  UIView+MKAnnotationView.m
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "UIView+MKAnnotationView.h"

@implementation UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView {
    
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView*)self;
    }
    
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
    
}



@end
