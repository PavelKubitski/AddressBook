//
//  ContactTableView.m
//  addressBook
//
//  Created by Pavel Kubitski on 16.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "ContactsTableView.h"
#import "CDPerson.h"
#import "DetailViewController.h"
#import "PersonCell.h"

@implementation ContactsTableView

@synthesize personsFetchedResultsController = _personsFetchedResultsController;

- (NSFetchedResultsController *)personsFetchedResultsController
{
    if (_personsFetchedResultsController != nil) {
        return _personsFetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"CDPerson"
                inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];
    
    NSSortDescriptor* firstNameDescription =
    [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor* lastNameDescription =
    [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
    
    [fetchRequest setSortDescriptors:@[firstNameDescription, lastNameDescription]];



    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.personsFetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.personsFetchedResultsController performFetch:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _personsFetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(PersonCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    CDObject *object = [self.personsFetchedResultsController objectAtIndexPath:indexPath];
    CDPerson *person = (CDPerson*)object;
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    UIImage* image = [UIImage imageWithData:person.avatarImage];
//    cell.imageView.image = [[UIImage imageWithData:person.avatarImage] size].width = ;
//    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    cell.imageView.clipsToBounds = YES;
    cell.avatarImageView.image = [UIImage imageWithData:person.avatarImage];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* identifier = @"PersonCell";
    
    PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[PersonCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

//записать картинки сразу базу

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CDPerson* cdPerson = [self.personsFetchedResultsController objectAtIndexPath:indexPath];
    DetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];

    [self.navigationController pushViewController:vc animated:YES];
    

    vc.cdPerson = cdPerson;
    
}




@end
