//
//  EditContactTableView.m
//  addressBook
//
//  Created by Pavel Kubitski on 17.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "EditContactTableView.h"
#import "EditCell.h"
#import "CDEmail.h"
#import "CDPhoneNumber.h"
#import "LabelAndInfo.h"
#import "CDManager.h"

NSString* const SizeOfTableViewChangedNotification = @"SizeOfTableViewChangedNotification";

NSString* const OperationInfoKey = @"OperationInfoKey";

@implementation EditContactTableView

- (void) awakeFromNib {
    [super awakeFromNib];
    [self addObservers];

    self.scrollEnabled = YES;

    
}

- (void)dealloc
{
    [self removeObservers];
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(EditCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.typeLabel.text = @"Add new number";
            cell.typeLabel.userInteractionEnabled = NO;
            cell.infoTextField.userInteractionEnabled = NO;
            cell.infoTextField.placeholder = @"";
            cell.infoTextField.text = @"";
        } else {
            NSIndexPath* indexpath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
            CDPhoneNumber *cdPhoneNumber = [self.numberFetchedResultsController objectAtIndexPath:indexpath];
            cell.typeLabel.userInteractionEnabled = YES;
            cell.infoTextField.userInteractionEnabled = YES;
            cell.typeLabel.text = cdPhoneNumber.typeLabel;
            cell.infoTextField.text = cdPhoneNumber.number;
            [cell.infoTextField setPlaceholder:@"Number"];
        }
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.typeLabel.text = @"Add new email";
            cell.typeLabel.userInteractionEnabled = NO;
            cell.infoTextField.userInteractionEnabled = NO;
            cell.infoTextField.placeholder = @"";
            cell.infoTextField.text = @"";
        } else {
            NSIndexPath* indexpath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
            CDEmail *cdEmail = [self.emailFetchedResultsController objectAtIndexPath:indexpath];
            cell.typeLabel.userInteractionEnabled = YES;
            cell.infoTextField.userInteractionEnabled = YES;
            cell.typeLabel.text = cdEmail.typeLabel;
            cell.infoTextField.text = cdEmail.email;
            [cell.infoTextField setPlaceholder:@"Email"];
        }
        
        
        
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* editCellIdentifier = @"editCell";
    
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier: editCellIdentifier];
    
    if (!cell) {
        cell = [[EditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:editCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [[[self.numberFetchedResultsController sections] objectAtIndex:0] numberOfObjects] + 1;
    } else if (section == 1) {
        return [[[self.emailFetchedResultsController sections] objectAtIndex:0] numberOfObjects] + 1;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [[CDManager sharedManager] managedObjectContext];
        NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
        if (indexPath.section == 0) {
            [context deleteObject:[self.numberFetchedResultsController objectAtIndexPath:path]];
        } else if (indexPath.section == 1) {
            [context deleteObject:[self.emailFetchedResultsController objectAtIndexPath:path]];
        }
        
        [[CDManager sharedManager] saveContext];
        
        [self postChangeSizeNotification];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
    if (indexPath.section == 0) {
        CDPhoneNumber* cdNumber = [NSEntityDescription insertNewObjectForEntityForName:@"CDPhoneNumber"
                                                                inManagedObjectContext:[[CDManager sharedManager] managedObjectContext]];
        cdNumber.typeLabel = @"Type";
        cdNumber.number = @"";
        [self.cdPerson addPhoneNumberObject:cdNumber];

        
        [[CDManager sharedManager] saveContext];
    } else
    
        if (indexPath.section == 1) {
            CDEmail* cdEmail = [NSEntityDescription insertNewObjectForEntityForName:@"CDEmail"
                                                             inManagedObjectContext:[[CDManager sharedManager] managedObjectContext]];
            cdEmail.typeLabel = @"Type";
            cdEmail.email = @"";
            [self.cdPerson addEmailObject:cdEmail];
            
            [[CDManager sharedManager] saveContext];
        }

        
        [self postChangeSizeNotification];
    }
    
}

#pragma mark - Notifications

- (void)textFieldDidEndEditing:(NSNotification*)notification {
    
    NSDictionary* dc = [notification userInfo];
    NSIndexPath* indexpath = [dc objectForKey:IndexPathInfoKey];
    NSString* infoText = [dc objectForKey:InfoTextInfoKey];


    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:indexpath.row-1 inSection:0];
    
    if (indexpath.section == 0) {

        CDPhoneNumber* managedObj = [self.numberFetchedResultsController objectAtIndexPath:indexPath];
        managedObj.number = infoText;
        
    } else if (indexpath.section == 1) {

        CDEmail* managedObj = [self.emailFetchedResultsController objectAtIndexPath:indexPath];
        managedObj.email = infoText;
    }
    
    
    [[CDManager sharedManager] saveContext];
    
}

- (void) postChangeSizeNotification {

    [[NSNotificationCenter defaultCenter] postNotificationName:SizeOfTableViewChangedNotification
                                                        object:nil
                                                      userInfo:nil];
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
    NSIndexPath *indexPathForInsert, *indexPathForDelete, *indexPathForUpdate , *indexPathForMove;
    if (controller == self.numberFetchedResultsController) {
        indexPathForInsert = [NSIndexPath indexPathForRow:1 inSection:0];
        indexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        indexPathForUpdate = indexPathForDelete;
        indexPathForMove = [NSIndexPath indexPathForRow:newIndexPath.row+1 inSection:0];
    } else if (controller == self.emailFetchedResultsController) {
        indexPathForInsert = [NSIndexPath indexPathForRow:1 inSection:1];
        indexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:1];
        indexPathForMove = [NSIndexPath indexPathForRow:newIndexPath.row+1 inSection:1];
        indexPathForUpdate = indexPathForDelete;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"indexPathForInsert sect = %ld, row = %ld", (long)indexPathForInsert.section, (long)indexPathForInsert.row);
            [tableView insertRowsAtIndexPaths:@[indexPathForInsert] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPathForDelete] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            NSLog(@"indexPathForUpdate sect = %ld, row = %ld", indexPathForUpdate.section, indexPathForUpdate.row);
//            NSLog(@"indexPath sect = %ld, row = %ld", indexPath.section, indexPath.row);

            [self configureCell:[tableView cellForRowAtIndexPath:indexPathForUpdate] atIndexPath:indexPathForUpdate];
            break;
            
        case NSFetchedResultsChangeMove:
//            NSLog(@"indexPath sect = %ld, row = %ld", indexPath.section, indexPath.row);
//            NSLog(@"newIndexPath sect = %ld, row = %ld", newIndexPath.section, newIndexPath.row);

            [tableView deleteRowsAtIndexPaths:@[indexPathForDelete] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[indexPathForMove] withRowAnimation:UITableViewRowAnimationFade];
            break;
            //удалить из нужной строки и вставить в ту же , сохранив индекспас
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self endUpdates];
}

#pragma mark - changes

- (void) changeTypeLabelWithLabel:(NSString*) newLabel atIndexPath:(NSIndexPath*) indexPath {
    
    NSIndexPath* indexPathOfCDObjectInFetch = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
    
    if (indexPath.section == 0) {
        CDPhoneNumber* managedObj = [self.numberFetchedResultsController objectAtIndexPath:indexPathOfCDObjectInFetch];
        managedObj.typeLabel = newLabel;
        
    } else if (indexPath.section == 1) {
        CDEmail* managedObj = [self.emailFetchedResultsController objectAtIndexPath:indexPathOfCDObjectInFetch];
        managedObj.typeLabel = newLabel;
    }

    [[CDManager sharedManager] saveContext];
}

#pragma mark - manage notifications

- (void) addObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(textFieldDidEndEditing:)
               name:TextFieldDidEndEditingNotification
             object:nil];
    
}

- (void) removeObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self
                  name:TextFieldDidEndEditingNotification
                object:nil];
}




@end
