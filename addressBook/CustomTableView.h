//
//  CustomTableView.h
//  addressBook
//
//  Created by Pavel Kubitski on 16.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ABManager.h"

@interface CustomTableView : UITableView <UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *personsFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) UIStoryboard* storyboard;
@property (strong, nonatomic) ABManager* abManager;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
