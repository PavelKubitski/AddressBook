//
//  ContactTableView.h
//  addressBook
//
//  Created by Pavel Kubitski on 16.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CustomTableView.h"

@interface ContactTableView : CustomTableView

@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) UIStoryboard* storyboard;

@end
