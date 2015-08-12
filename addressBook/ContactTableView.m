//
//  ContactTableView.m
//  addressBook
//
//  Created by Pavel Kubitski on 16.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "ContactTableView.h"
#import "CDObject.h"
#import "CDPerson.h"
#import "DetailViewController.h"

@implementation ContactTableView

@synthesize fetchedResultsController = _fetchedResultsController;

- (void) awakeFromNib {

    
    self.delegate = self;
    self.dataSource = self;
}






- (NSFetchedResultsController *)fetchedResultsController
{
//    NSLog(@"");
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
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
                                                   cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//        NSLog(@"");
    CDObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    
    CDPerson* cdPerson = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];

    [self.navigationController pushViewController:vc animated:YES];
    
//        NSInteger index = [self indexInPersonArrayOfCellAtIndexPath:indexPath];
//        vc.person = [self.personsArray objectAtIndex:index];
    
    Person* person = [[Person alloc] initCDPerson:cdPerson];
    vc.person = person;
}




@end
