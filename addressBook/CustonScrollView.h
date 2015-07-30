//
//  CustonScrollView.h
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const ScrollViewTouchedNotification;

extern NSString* const TouchesInfoKey;
extern NSString* const EventInfoKey;


@interface CustonScrollView : UIScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
