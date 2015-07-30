//
//  TypeViewController.h
//  addressBook
//
//  Created by Pavel Kubitski on 28.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditInfoViewController.h"


extern NSString* const TypeVCDismissedNotification;

extern NSString* const TypeVCLabelTextInfoKey;



@interface TypeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSIndexPath* indexpath;
@property (strong, nonatomic)NSString* type;

- (IBAction)actionDoneButtonTouches:(id)sender;
- (IBAction)actionCancelButtonPressed:(id)sender;

- (void) initWithTypeIndexPath:(NSIndexPath*) indexpath typeLabel:(NSString*) type;

@end
