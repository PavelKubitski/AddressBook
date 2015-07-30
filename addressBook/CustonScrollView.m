//
//  CustonScrollView.m
//  addressBook
//
//  Created by Pavel Kubitski on 08.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CustonScrollView.h"


NSString* const ScrollViewTouchedNotification = @"ScrollViewTouchedNotification";

NSString* const TouchesInfoKey = @"TouchesInfoKey";
NSString* const EventInfoKey = @"EventInfoKey";

@implementation CustonScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    
    NSDictionary* dc = [NSDictionary dictionaryWithObjectsAndKeys:touches,TouchesInfoKey,event, EventInfoKey, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollViewTouchedNotification
                                                        object:nil
                                                      userInfo:dc];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesMoved: touches withEvent:event];
    }
    else {
        [super touchesMoved: touches withEvent: event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesEnded: touches withEvent:event];
    }
    else{
        [super touchesEnded: touches withEvent: event];
    }
}

@end
