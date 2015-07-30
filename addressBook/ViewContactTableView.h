//
//  ViewContactTableView.h
//  addressBook
//
//  Created by Pavel Kubitski on 16.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CustomTableView.h"
#import "Person.h"
#import "CDPerson.h"


@interface ViewContactTableView : CustomTableView

@property (strong, nonatomic) NSFetchedResultsController *numberFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *emailFetchedResultsController;

@property (strong, nonatomic) CDPerson* cdPerson;

- (void) reloadDataOfCustomTable;

@end
