//
//  UIViewController+LastViewController.m
//  addressBook
//
//  Created by Pavel Kubitski on 23.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "UIViewController+LastViewController.h"

@implementation UIViewController (LastViewController)

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

@end
