//
//  ContactTableView.m
//  addressBook
//
//  Created by Pavel Kubitski on 16.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "ContactsTableView.h"
//#import "CDObject.h"
#import "CDPerson.h"
#import "DetailViewController.h"

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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    CDObject *object = [self.personsFetchedResultsController objectAtIndexPath:indexPath];
    CDPerson *person = (CDPerson*)object;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CDPerson* cdPerson = [self.personsFetchedResultsController objectAtIndexPath:indexPath];
    DetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];

    [self.navigationController pushViewController:vc animated:YES];
    

    vc.cdPerson = cdPerson;
    
}




@end
