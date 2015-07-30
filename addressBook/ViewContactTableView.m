//
//  ViewContactTableView.m
//  addressBook
//
//  Created by Pavel Kubitski on 16.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "ViewContactTableView.h"
#import "CDEmail.h"
#import "CDPhoneNumber.h"
#import "InfoCell.h"
#import "LabelAndInfo.h"
#import "NSString+PhoneNumber.h"

@implementation ViewContactTableView

@synthesize emailFetchedResultsController = _emailFetchedResultsController;
@synthesize numberFetchedResultsController = _numberFetchedResultsController;


- (void) awakeFromNib {
    
    self.delegate = self;
    self.dataSource = self;
    self.allowsSelection = NO;
}

- (void) reloadDataOfCustomTable {
    self.emailFetchedResultsController = nil;
    self.numberFetchedResultsController = nil;
//    [[self emailFetchedResultsController] performFetch:nil];
//    [[self numberFetchedResultsController] performFetch:nil];
    [self reloadData];

}

- (NSFetchedResultsController *)emailFetchedResultsController
{

    if (_emailFetchedResultsController != nil) {
        return _emailFetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"CDEmail"
                inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];
    
    NSArray* array = [[NSArray alloc] init];

    [fetchRequest setSortDescriptors:array];
    

    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"person == %@", self.cdPerson];
    
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.emailFetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.emailFetchedResultsController performFetch:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _emailFetchedResultsController;
}

- (NSFetchedResultsController *)numberFetchedResultsController
{
    //    NSLog(@"");
    if (_numberFetchedResultsController != nil) {
        return _numberFetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"CDPhoneNumber"
                inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];


//    NSSortDescriptor* typeDescription =
//    [[NSSortDescriptor alloc] initWithKey:@"typeLabel" ascending:YES];
    
    
        NSArray* array = [[NSArray alloc] init];
//    [fetchRequest setSortDescriptors:@[typeDescription]];
        [fetchRequest setSortDescriptors:array];
    
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"person == %@", self.cdPerson];
    
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.numberFetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.numberFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _numberFetchedResultsController;
}





#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSInteger i = [[[self.numberFetchedResultsController sections] objectAtIndex:0] numberOfObjects];
        NSLog(@"numberOfRowsInSection %ld %ld",section, (long)i);
        return [[[self.numberFetchedResultsController sections] objectAtIndex:0] numberOfObjects];
    } else if (section == 1) {
        NSInteger i = [[[self.emailFetchedResultsController sections] objectAtIndex:0] numberOfObjects];
        NSLog(@"numberOfRowsInSection %ld %ld",section, (long)i);
        return [[[self.emailFetchedResultsController sections] objectAtIndex:0] numberOfObjects];
    }
    return 0;
}



- (void)configureCell:(InfoCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {

        CDPhoneNumber *cdPhoneNumber = [self.numberFetchedResultsController objectAtIndexPath:indexPath];

        cell.typeLabel.text = cdPhoneNumber.typeLabel;
        cell.infoLabel.text = [cdPhoneNumber.number makeNumberFromString];
    } else if (indexPath.section == 1) {
        NSIndexPath* indexpath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        CDEmail *cdEmail = [self.emailFetchedResultsController objectAtIndexPath:indexpath];

        cell.typeLabel.text = cdEmail.typeLabel;
        cell.infoLabel.text = cdEmail.email;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* infoCellIdentifier = @"infoCell";
    
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
    
    if (!cell) {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:infoCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString* header;
    if (section == 0) {
        header = @"Phone";
    } else if (section == 1){
        header = @"Emails";
    }
    return header;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{

    [self beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{

    UITableView *tableView = self;
    
    NSIndexPath *indexPathForInsert, *indexPathForDelete, *indexPathForUpdate;
    if (controller == self.numberFetchedResultsController) {
        indexPathForInsert = [NSIndexPath indexPathForRow:newIndexPath.row inSection:0];
        indexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        indexPathForUpdate = indexPathForDelete;
    } else if (controller == self.emailFetchedResultsController) {
        indexPathForInsert = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
        indexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
        indexPathForUpdate = indexPathForDelete;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:{
//            NSLog(@"newIndexPath sect = %ld, row = %ld", newIndexPath.section, newIndexPath.row);
//            NSLog(@"indexPathForInsert sect = %ld, row = %ld", indexPathForInsert.section, indexPathForInsert.row);
            [tableView insertRowsAtIndexPaths:@[indexPathForInsert] withRowAnimation:UITableViewRowAnimationFade];
            [self configureCell:[tableView cellForRowAtIndexPath:indexPathForInsert] atIndexPath:indexPathForInsert];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPathForDelete] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:{

            [self configureCell:[tableView cellForRowAtIndexPath:indexPathForUpdate] atIndexPath:indexPathForUpdate];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerDidChangeContent!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    [self endUpdates];
}



@end
