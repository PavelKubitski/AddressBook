//
//  LoginViewController.h
//  addressBook
//
//  Created by Pavel Kubitski on 12.08.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AccessToken;

typedef void(^LoginCompletionBlock)(AccessToken* token);

@interface LoginViewController : UIViewController

- (id) initWithCompletionBlock:(LoginCompletionBlock) completionBlock;

@end
