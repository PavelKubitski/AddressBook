//
//  ViewController.h
//  addressBook
//
//  Created by Pavel Kubitski on 15.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABManager.h"
#import "ContactsTableView.h"
@class CDWriter;

@interface PersonsViewController : UIViewController

@property (strong, nonatomic) NSMutableArray* personsArray;
@property (weak, nonatomic) IBOutlet ContactsTableView *tableView;
@property (strong, nonatomic) ABManager* abManager;
@property (strong, nonatomic) CDWriter* cdWriter;

@end

